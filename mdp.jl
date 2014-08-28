type GridWorld
  S
  A
  T
  R
  gamma
end


function xy2s(x, y)
  x = max(x, 1)
  y = max(y, 1)
  x = min(x, 10)
  y = min(y, 10)
  sub2ind([10 10], x, y)
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
        if a == 1 % left
          T[s, a, xy2s(x, y - 1)] += 0.7
          T[s, a, xy2s(x, y + 1)] += 0.1
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x + 1, y)] += 0.1
        elseif a == 2 % right
          T[s, a, xy2s(x, y + 1)] += 0.7
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x + 1, y)] += 0.1
        elseif a == 3 % up
          T[s, a, xy2s(x - 1, y)] += 0.7
          T[s, a, xy2s(x + 1, y)] += 0.1
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x, y + 1)] += 0.1
        elseif a == 4 % down
          T[s, a, xy2s(x + 1, y)] += 0.7
          T[s, a, xy2s(x - 1, y)] += 0.1
          T[s, a, xy2s(x, y - 1)] += 0.1
          T[s, a, xy2s(x, y + 1)] += 0.1
        end
      end
    end
  end
  gamma = 0.9
  GridWorld(S,A,T,R,gamma)
end

function colorval(val::Real, brightness::Real)
  x = 255 - min(255, 255 * (abs(val) ./ 10.0) .^ obj.brightness)
  r = 255 * ones(size(val))
  g = 255 * ones(size(val))
  r[val .>= 0] = x(val .>= 0)
  b[val .>= 0] = x(val .>= 0)
  g[val .< 0] = x(val .< 0)
  b[val .< 0] = x(val .< 0)
  (r, g, b)
end

function plot(obj::GridWorld)
  o = IOBuffer()
  sqsize = 1.0
  twid = 0.05
  [r g b] = colorval(V);
  for s = obj.S
    [xval, yval] = s2xy(s)
    println(o, "\\definecolor{currentcolor}{RGB}{$(r(s)),$(g(s)),$(b(s))}")
    println(o, "\\fill[currentcolor] ($(xval * sqsize),$(xval * sqsize)) rectangle +($sqsize,$sqsize);")
  end
  printf(o, "\\begin{scope}[fill=gray]")
#   for s = obj.S
#     [xval, yval] = obj.s2xy(s);
#     if obj.V(s) == obj.Q(s,1)
#       uptrix = [xval * sqsize + sqsize / 2 - twid, xval * sqsize + sqsize / 2 + twid, xval * sqsize + sqsize / 2];
#       uptriy = [yval * sqsize + sqsize / 2, yval * sqsize + sqsize / 2, yval * sqsize ];
#     end
#     if obj.V(s) == obj.Q(s,2)
#       uptriy = [ yval * sqsize + sqsize / 2 - twid, yval * sqsize + sqsize / 2 + twid, yval * sqsize + sqsize / 2 ];
#       uptrix = [ xval * sqsize + sqsize / 2, xval * sqsize + sqsize / 2, (xval + 1) * sqsize ];
#     end
#     if obj.V(s) == obj.Q(s,3)
#       uptrix = [ xval * sqsize + sqsize / 2 - twid, xval * sqsize + sqsize / 2 + twid, xval * sqsize + sqsize / 2 ];
#       uptriy = [ yval * sqsize + sqsize / 2, yval * sqsize + sqsize / 2, (yval + 1) * sqsize ];
#     end
#     if obj.V(s) == obj.Q(s,4)
#       uptriy = [ yval * sqsize + sqsize / 2 - twid, yval * sqsize + sqsize / 2 + twid, yval * sqsize + sqsize / 2 ];
#       uptrix = [ xval * sqsize + sqsize / 2, xval * sqsize + sqsize / 2, xval * sqsize ];
#     end
#     println(o, "\\fill ($uptrix(1), $uptriy(1)) -- ($uptrix(2), $uptriy(2)) -- ($uptrix(3), $uptriy(3)) -- cycle;")
#     println(o, '\\node[above right] at ($(xval * sqsize), $((yval + 1) * sqsize)) {\$$(@sprintf("%0.2f", V(s)))\$};")
#   end
#   println(o, "\\end{scope}");
#   println(o, "\\draw[black] grid(10,10);");
  takebuf_string(o)
end
