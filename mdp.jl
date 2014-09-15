include("gridworld.jl")

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
