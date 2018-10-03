using POMDPs

# Problem based on https://www.cs.ubc.ca/~poole/demos/mdp/vi.html

using TikzPictures
using Printf

mutable struct DMUGridWorld <: MDP{Int, Symbol}
  S::Vector{Int}
  A::Vector{Symbol}
  T::Array{Float64,3}
  R::Matrix{Float64}
  discount::Float64
  actionIndex::Dict{Symbol, Int}
  nextStates::Dict{Tuple{Int, Symbol}, Vector{Int}}
end

actions(g::DMUGridWorld) = g.A
states(g::DMUGridWorld) = g.S
n_actions(g::DMUGridWorld) = length(g.A)
n_states(g::DMUGridWorld) = length(g.S)
reward(g::DMUGridWorld, s::Int, a::Symbol) = g.R[s, g.actionIndex[a]]
transition_pdf(g::DMUGridWorld, s0::Int, a::Symbol, s1::Int) = g.T[s0, g.actionIndex[a], s1]
discount(g::DMUGridWorld) = g.discount
next_states(g::DMUGridWorld, s, a) = g.nextStates[(s, a)]
state_index(g::DMUGridWorld, s) = s
action_index(g::DMUGridWorld, a) = g.actionIndex[a]

function locals(mdp::MDP)
  S = states(mdp)
  A = actions(mdp)
  T = (s0, a, s1) -> transition_pdf(mdp, s0, a, s1)
  R = (s, a) -> reward(mdp, s, a)
  gamma = discount(mdp)
  (S, A, T, R, gamma)
end

s2xy(s) = Tuple(CartesianIndices((10,10))[s])

function xy2s(x, y)
  x = max(x, 1)
  y = max(y, 1)
  x = min(x, 10)
  y = min(y, 10)
  LinearIndices((10, 10))[x,y]
end

function DMUGridWorld()
  A = [:left, :right, :up, :down]
  S = 1:100
  T = zeros(length(S), length(A), length(S))
  R = zeros(length(S), length(A))
  for s in S
    (x, y) = s2xy(s)
    if x == 3 && y == 8
      R[s, :] .= 3
    elseif x == 8 && y == 9
      R[s, :] .= 10
    else
      if x == 8 && y == 4
        R[s, :] .= -10
      elseif x == 5 && y == 4
        R[s, :] .= -5
      elseif x == 1
        if y == 1 || y == 10
          R[s, :] .= -0.2
        else
          R[s, :] .= -0.1
        end

        R[s, 3] = -0.7
      elseif x == 10
        if y == 1 || y == 10
          R[s, :] .= -0.2
        else
          R[s, :] .= -0.1
        end
        R[s, 4] = -0.7
      elseif y == 1
        if x == 1 || x == 10
          R[s, :] .= -0.2
        else
          R[s, :] .= -0.1
        end
        R[s, 1] = -0.7
      elseif y == 10
        if x == 1 || x == 10
          R[s, :] .= -0.2
        else
          R[s, :] .= -0.1
        end
        R[s, 2] = -0.7
      end
      for a in A
        if a == :left
          T[s, 1, xy2s(x, y - 1)] += 0.7
          T[s, 1, xy2s(x, y + 1)] += 0.1
          T[s, 1, xy2s(x - 1, y)] += 0.1
          T[s, 1, xy2s(x + 1, y)] += 0.1
        elseif a == :right
          T[s, 2, xy2s(x, y + 1)] += 0.7
          T[s, 2, xy2s(x, y - 1)] += 0.1
          T[s, 2, xy2s(x - 1, y)] += 0.1
          T[s, 2, xy2s(x + 1, y)] += 0.1
        elseif a == :up
          T[s, 3, xy2s(x - 1, y)] += 0.7
          T[s, 3, xy2s(x + 1, y)] += 0.1
          T[s, 3, xy2s(x, y - 1)] += 0.1
          T[s, 3, xy2s(x, y + 1)] += 0.1
        elseif a == :down
          T[s, 4, xy2s(x + 1, y)] += 0.7
          T[s, 4, xy2s(x - 1, y)] += 0.1
          T[s, 4, xy2s(x, y - 1)] += 0.1
          T[s, 4, xy2s(x, y + 1)] += 0.1
        end
      end
    end
  end
  R[1,1] = -0.8
  R[10,1] = -0.8
  R[91,2] = -0.8
  R[100,2] = -0.8
  R[1,3] = -0.8
  R[91,3] = -0.8
  R[10,4] = -0.8
  R[100,4] = -0.8
  discount = 0.9
  nextStates = Dict([(S[si], A[ai])=>findall(x->x!=0, T[si, ai, :]) for si=1:length(S), ai=1:length(A)])
  DMUGridWorld(S, A, T, R, discount, Dict([A[i]=>i for i=1:length(A)]), nextStates)
end

function colorval(val, brightness::Real = 1.0)
  val = convert(Vector{Float64}, val)
  x = 255 .- min.(255, 255 * (abs.(val) ./ 10.0) .^ brightness)
  r = 255 * ones(size(val))
  g = 255 * ones(size(val))
  b = 255 * ones(size(val))
  r[val .>= 0] .= x[val .>= 0]
  b[val .>= 0] .= x[val .>= 0]
  g[val .< 0] .= x[val .< 0]
  b[val .< 0] .= x[val .< 0]
  (r, g, b)
end

function plot(g::DMUGridWorld, f::Function)
  V = map(f, g.S)
  plot(g, V)
end

function plot(obj::DMUGridWorld, V::Vector; curState=0)
  o = IOBuffer()
  sqsize = 1.0
  twid = 0.05
  (r, g, b) = colorval(V)
  for s = obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval
    println(o, "\\definecolor{currentcolor}{RGB}{$(r[s]),$(g[s]),$(b[s])}")
    println(o, "\\fill[currentcolor] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
    if s == curState
      println(o, "\\fill[orange] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
    end
    vs = Printf.@sprintf("%0.2f", V[s])
    println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval) * sqsize)) {\$$(vs)\$};")
  end
  println(o, "\\draw[black] grid(10,10);")
  tikzDeleteIntermediate(false)
  TikzPicture(String(take!(o)), options="scale=1.25")
end

function plot(g::DMUGridWorld, f::Function, policy::Function; curState=0)
  V = map(f, g.S)
  plot(g, V, policy, curState=curState)
end

function plot(obj::DMUGridWorld, V::Vector, policy::Function; curState=0)
  P = map(policy, obj.S)
  plot(obj, V, P, curState=curState)
end

function plot(obj::DMUGridWorld, V::Vector, policy::Vector; curState=0)
  o = IOBuffer()
  sqsize = 1.0
  twid = 0.05
  (r, g, b) = colorval(V)
  for s in obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval
    println(o, "\\definecolor{currentcolor}{RGB}{$(r[s]),$(g[s]),$(b[s])}")
    println(o, "\\fill[currentcolor] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
    if s == curState
      println(o, "\\fill[orange] ($((xval-1) * sqsize),$((yval) * sqsize)) rectangle +($sqsize,$sqsize);")
    end
  end
  println(o, "\\begin{scope}[fill=gray]")
  for s in obj.S
    (yval, xval) = s2xy(s)
    yval = 10 - yval + 1
    c = [xval, yval] * sqsize .- sqsize / 2
    C = [c'; c'; c']'
    RightArrow = [0 0 sqsize/2; twid -twid 0]
    if policy[s] == :left
      A = [-1 0; 0 -1] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == :right
      A = RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == :up
      A = [0 -1; 1 0] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end
    if policy[s] == :down
      A = [0 1; -1 0] * RightArrow + C
      println(o, "\\fill ($(A[1]), $(A[2])) -- ($(A[3]), $(A[4])) -- ($(A[5]), $(A[6])) -- cycle;")
    end

    vs = Printf.@sprintf("%0.2f", V[s])
    println(o, "\\node[above right] at ($((xval-1) * sqsize), $((yval-1) * sqsize)) {\$$(vs)\$};")
  end
  println(o, "\\end{scope}");
  println(o, "\\draw[black] grid(10,10);");
  TikzPicture(String(take!(o)), options="scale=1.25")
end

# simulates taking action a from s
function simulate(g::DMUGridWorld, s::Int, a::Symbol)
    probs = Float64[]
    if length(next_states(g,s,a)) == 0
        println("s = ", s)
        println("a = ", a)
    end
    for sp in next_states(g, s, a)
        push!(probs, transition_pdf(g, s, a, sp) )
    end

    # make sure these sum to 1. They should, but let's be safe.
    probs = probs / sum(probs)

    # sample a random value from next states
    rand_val = rand()
    sampled_idx = 1
    prob_sum = 0.0
    i = 1
    while true
        prob_sum += probs[i]
        if rand_val < prob_sum
            sampled_idx = i
            break
        end
        i += 1
    end
    sp = next_states(g,s,a)[sampled_idx]

    return sp, reward(g,s,a)
end
