# Problem based on https://www.cs.ubc.ca/~poole/demos/mdp/vi.html

using TikzPictures

type GridWorld
  S
  A
  T
  R
end

s2xy(s) = ind2sub((10, 10), s)

function xy2s(x, y)
  x = max(x, 1)
  y = max(y, 1)
  x = min(x, 10)
  y = min(y, 10)
  sub2ind((10, 10), x, y)
end

function GridWorld()
  A = 1:4
  S = 1:100
  T = zeros(length(S), length(A), length(S))
  R = zeros(length(S), length(A))
  for s in S
    (x, y) = s2xy(s)
    if x == 3 && y == 8
      R[s, :] = 3
    elseif x == 8 && y == 9
      R[s, :] = 10
    else
      if x == 8 && y == 4
        R[s, :] = -10
      elseif x == 5 && y == 4
        R[s, :] = -5
      elseif x == 1
        if y == 1 || y == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end

        R[s, 3] = -0.7
      elseif x == 10
        if y == 1 || y == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 4] = -0.7
      elseif y == 1
        if x == 1 || x == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 1] = -0.7
      elseif y == 10
        if x == 1 || x == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 2] = -0.7
      end
      for a in A
        if a == 1 # left
          T[s, a, xy2s(x, y - 1)] += 0.7
          T[s, a, xy2s(x, y + 1)] += 0.1
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x + 1, y)] += 0.1
        elseif a == 2 # right
          T[s, a, xy2s(x, y + 1)] += 0.7
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x + 1, y)] += 0.1
        elseif a == 3 # up
          T[s, a, xy2s(x - 1, y)] += 0.7
          T[s, a, xy2s(x + 1, y)] += 0.1
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x, y + 1)] += 0.1
        elseif a == 4 # down
          T[s, a, xy2s(x + 1, y)] += 0.7
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x, y + 1)] += 0.1
        end
      end
    end
  end
  R[1,1] = -0.8
  R[10,1] = -0.8
  R[91,2] = -0.8
  R[100,2] = -0.8
  GridWorld(S,A,T,R)
end

function colorval(val, brightness::Real = 1.0)
  val = float(val)
  x = 255 - min(255, 255 * (abs(val) ./ 10.0) .^ brightness)
  r = 255 * ones(size(val))
  g = 255 * ones(size(val))
  b = 255 * ones(size(val))
  r[val .>= 0] = x[val .>= 0]
  b[val .>= 0] = x[val .>= 0]
  g[val .< 0] = x[val .< 0]
  b[val .< 0] = x[val .< 0]
  (r, g, b)
end

function plot(obj::GridWorld, f::Function)
  V = map(f, obj.S)
  plot(obj, V)
end

function plot(obj::GridWorld, V::Vector)
  o = IOBuffer()
  sqsize = 1.0
  twid = 0.05
  (r, g, b) = colorval(V)
  for s = obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval
    println(o, "\\definecolor{currentcolor}{RGB}{$(r[s]),$(g[s]),$(b[s])}")
    println(o, "\\fill[currentcolor] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
    vs = @sprintf("%0.2f", V[s])
    println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval) * sqsize)) {\$$(vs)\$};")
  end
  println(o, "\\draw[black] grid(10,10);")
  tikzDeleteIntermediate(false)
  TikzPicture(takebuf_string(o), options="scale=1.25")
end

function plot(obj::GridWorld, V::Vector, policy::Vector)
  o = IOBuffer()
  sqsize = 1.0
  twid = 0.05
  (r, g, b) = colorval(V)
  for s = obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval
    println(o, "\\definecolor{currentcolor}{RGB}{$(r[s]),$(g[s]),$(b[s])}")
    println(o, "\\fill[currentcolor] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
  end
  println(o, "\\begin{scope}[fill=gray]")
  for s in obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval + 1
    c = [xval, yval] * sqsize - sqsize / 2
    C = [c'; c'; c']'
    RightArrow = [0 0 sqsize/2; twid -twid 0]
    if policy[s] == 1 # left
      A = [-1 0; 0 -1] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == 2 # right
      A = RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == 3 # up
      A = [0 -1; 1 0] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == 4 # down
      A = [0 1; -1 0] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end

    vs = @sprintf("%0.2f", V[s])
    println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval-1) * sqsize)) {\$$(vs)\$};")
  end
  println(o, "\\end{scope}");
  println(o, "\\draw[black] grid(10,10);");
  TikzPicture(takebuf_string(o), options="scale=1.25")
end

function backup(obj::GridWorld)
  Vold = copy(obj.V)
  for s in obj.S
    obj.Q[s,:] = obj.R[s, :] + (obj.gamma * squeeze(obj.T[s, :, :], 1) * Vold)'
    obj.V[s] = maximum(obj.Q[s,:])
  end
end

function backupGaussSeidel(obj::GridWorld)
  for s in obj.S
    obj.Q[s,:] = obj.R[s, :] + (obj.gamma * squeeze(obj.T[s, :, :], 1) * obj.V)'
    obj.V[s] = maximum(obj.Q[s,:])
  end
end

g = GridWorld()

actionMap = [:left=>1, :right=>2, :up=>3, :down=>4]
function T(s0, a::Integer, s1)
  g.T[s0, a, s1]
end
function T(s0, a::Symbol, s1)
  g.T[s0, actionMap[a], s1]
end
function R(s, a::Integer)
  g.R[s, a]
end
function R(s, a::Symbol)
  g.R[s, actionMap[a]]
end
S = g.S
A = [:left, :right, :up, :down]
discount = 0.9

