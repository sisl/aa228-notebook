# Problem based on https://www.cs.ubc.ca/~poole/demos/mdp/vi.html

using TikzPictures

type GridWorld
  S
  A
  T
  R
  gamma
  V
  Q
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

        R[s, 3] = -1
      elseif x == 10
        if y == 1 || y == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 4] = -1
      elseif y == 1
        if x == 1 || x == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 1] = -1
      elseif y == 10
        if x == 1 || x == 10
          R[s, :] = -0.2
        else
          R[s, :] = -0.1
        end
        R[s, 2] = -1
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
  gamma = 0.9
  V = zeros(100)
  Q = zeros(100,4)
  GridWorld(S,A,T,R,gamma,V,Q)
end

function colorval(val, brightness::Real = 1.0)
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

epseq(a, b, eps = 1e-4) = abs(a - b) < eps

function plot(obj::GridWorld)
  V = obj.V
  Q = obj.Q
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
  for s = 1
    (yval, xval) = s2xy(s)
    yval = 10 - yval
    if epseq(V[s], Q[s,1]) # left
      uptriy = [ yval * sqsize + sqsize / 2 - twid, yval * sqsize + sqsize / 2 + twid, yval * sqsize + sqsize / 2 ]
      uptrix = [ xval * sqsize + sqsize / 2, xval * sqsize + sqsize / 2, (xval) * sqsize ] - 1
      println(o, "\\fill ($(uptrix[1]), $(uptriy[1])) -- ($(uptrix[2]), $(uptriy[2])) -- ($(uptrix[3]), $(uptriy[3])) -- cycle;")
    end
    if epseq(V[s], Q[s,2]) # right
      uptriy = 12 - [xval * sqsize + sqsize / 2 - twid, xval * sqsize + sqsize / 2 + twid, xval * sqsize + sqsize / 2] - 1
      uptrix = 10 - [yval * sqsize + sqsize / 2, yval * sqsize + sqsize / 2, yval * sqsize ]
      println(o, "\\fill ($(uptrix[1]), $(uptriy[1])) -- ($(uptrix[2]), $(uptriy[2])) -- ($(uptrix[3]), $(uptriy[3])) -- cycle;")
    end
   if epseq(V[s], Q[s,3]) # up
      uptrix = 10 - [ yval * sqsize + sqsize / 2 - twid, yval * sqsize + sqsize / 2 + twid, yval * sqsize + sqsize / 2 ]
      uptriy = 12 - [ xval * sqsize + sqsize / 2, xval * sqsize + sqsize / 2, xval * sqsize ] - 1
      println(o, "\\fill ($(uptrix[1]), $(uptriy[1])) -- ($(uptrix[2]), $(uptriy[2])) -- ($(uptrix[3]), $(uptriy[3])) -- cycle;")
    end
    if epseq(V[s], Q[s,4]) # down
      uptrix = [ xval * sqsize + sqsize / 2 - twid, xval * sqsize + sqsize / 2 + twid, xval * sqsize + sqsize / 2 ] - 1
      uptriy = [ yval * sqsize + sqsize / 2, yval * sqsize + sqsize / 2, (yval) * sqsize ]
      println(o, "\\fill ($(uptrix[1]), $(uptriy[1])) -- ($(uptrix[2]), $(uptriy[2])) -- ($(uptrix[3]), $(uptriy[3])) -- cycle;")
    end
    vs = @sprintf("%0.2f", V[s])
    println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval) * sqsize)) {\$$(vs)\$};")
  end
  println(o, "\\end{scope}");
  println(o, "\\draw[black] grid(10,10);");
  tikzDeleteIntermediate(false)
  TikzPicture(takebuf_string(o), options="scale=1.5")
end

function backup(obj::GridWorld)
  Vold = copy(obj.V)
  for s in obj.S
    obj.Q[s,:] = obj.R[s, :] + (obj.gamma * squeeze(obj.T[s, :, :], 1) * Vold)'
    obj.V[s] = maximum(obj.Q[s,:])
  end
end

