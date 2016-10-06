module MDPs

export MDP, DiscreteMDP, MappedDiscreteMDP, actions, states, numActions, numStates, reward, transition, discount, locals
export nextStates, stateIndex, actionIndex

abstract MDP

actions(mdp::MDP) = error("$(typeof(mdp)) does not implement actions")
states(mdp::MDP) = error("$(typeof(mdp)) does not implement states")
numActions(mdp::MDP) = length(actions(mdp))
numStates(mdp::MDP) = length(states(mdp))
reward(mdp::MDP, s, a) = error("$(typeof(mdp)) does not implement reward")
transition(mdp::MDP, s0, a, s1) = error("$(typeof(mdp)) does not implement transition")
discount(mdp::MDP) = error("$(typeof(mdp)) does not implement discount")
nextStates(mdp::MDP, s, a) = states(mdp)
stateIndex(mdp::MDP, s) = error("$(typeof(mdp)) does not implement stateIndex")
actionIndex(mdp::MDP, a) = error("$(typeof(mdp)) does not implement actionIndex")


function locals(mdp::MDP)
  S = states(mdp)
  A = actions(mdp)
  T = (s0, a, s1) -> transition(mdp, s0, a, s1)
  R = (s, a) -> reward(mdp, s, a)
  gamma = discount(mdp)
  (S, A, T, R, gamma)
end

type DiscreteMDP <: MDP
  numStates::Int
  numActions::Int
  T::Array{Float64,3}
  R::Matrix{Float64}
  discount::Float64
end

DiscreteMDP(numStates::Integer, numActions::Integer; discount=0.9) =
  DiscreteMDP(numStates,
              numActions,
              zeros(numStates, numActions, numStates),
              zeros(numStates, numActions),
              discount)

actions(mdp::DiscreteMDP) = 1:mdp.numActions
states(mdp::DiscreteMDP) = 1:mdp.numStates
reward(mdp::DiscreteMDP, s, a) = mdp.R[s, a]
transition(mdp::DiscreteMDP, s0, a, s1) = mdp.T[s0, a, s1]
discount(mdp::DiscreteMDP) = mdp.discount
numActions(mdp::DiscreteMDP) = mdp.numActions
numStates(mdp::DiscreteMDP) = mdp.numStates
stateIndex(mdp::DiscreteMDP, s) = s
actionIndex(mdp::DiscreteMDP, a) = a


end
