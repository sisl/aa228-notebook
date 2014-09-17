type MDP
  S
  A
  T
  R
  discount::Real
  stateIndex
  actionIndex
end

MDP(S, A, T, R; discount=0.9) = MDP(S, A, T, R, discount, [S[i]=>i for i=1:length(S)], [A[i]=>i for i=1:length(A)])

function backup!(V::Vector, Q::Matrix, mdp::MDP)
  Vold = copy(V)
  for s in 1:length(mdp.S)
    Q[s,:] = obj.R[s, :] + (mdp.discount * squeeze(mdp.T[s, :, :], 1) * Vold)'
    V[s] = maximum(Q[s,:])
  end
end

function backupGaussSeidel!(V::Vector, Q::Matrix, mdp::MDP)
  for s in 1:length(mdp.S)
    Q[s,:] = mdp.R[s, :] + (mdp.discount * squeeze(mdp.T[s, :, :], 1) * V)'
    V[s] = maximum(obj.Q[s,:])
  end
end

actions(mdp::MDP) = mdp.A
states(mdp::MDP) = mdp.S
numActions(mdp::MDP) = length(mdp.A)
numStates(mdp::MDP) = length(mdp.S)
reward(mdp::MDP, s, a) = mdp.R[mdp.stateIndex[s], mdp.actionIndex[a]]
transition(mdp::MDP, s0, a, s1) = mdp.T[mdp.stateIndex[s0], mdp.actionIndex[a], mdp.stateIndex[s1]]

function locals(mdp::MDP)
  S = states(mdp)
  A = actions(mdp)
  T = (s0, a, s1) -> transition(mdp, s0, a, s1)
  R = (s, a) -> reward(mdp, s, a)
  (S, A, T, R)
end


# g = GridWorld()

# actionMap = [:left=>1, :right=>2, :up=>3, :down=>4]
# function T(s0, a::Integer, s1)
#   g.T[s0, a, s1]
# end
# function T(s0, a::Symbol, s1)
#   g.T[s0, actionMap[a], s1]
# end
# function R(s, a::Integer)
#   g.R[s, a]
# end
# function R(s, a::Symbol)
#   g.R[s, actionMap[a]]
# end
# S = g.S
# discount = 0.9
