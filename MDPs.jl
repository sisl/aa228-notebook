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

type MappedDiscreteMDP <: MDP
  S::Vector
  A::Vector
  T::Array{Float64,3}
  R::Matrix{Float64}
  discount::Float64
  stateIndex::Dict
  actionIndex::Dict
  nextStates
  function MappedDiscreteMDP(S, A, T, R; discount=0.9)
    stateIndex = [S[i]=>i for i = 1:length(S)]
    actionIndex = [A[i]=>i for i = 1:length(A)]
    nextStates = [(S[si], A[ai])=>S[find(T[si, ai, :])] for si=1:length(S), ai=1:length(A)]
    new(S, A, T, R, discount, stateIndex, actionIndex, nextStates)
  end
end

MappedDiscreteMDP(S, A; discount=0.9) =
  MappedDiscreteMDP(S,
                    A,
                    zeros(length(S), length(A), length(S)),
                    zeros(length(S), length(A)),
                    discount=discount)

actions(mdp::MappedDiscreteMDP) = mdp.A
states(mdp::MappedDiscreteMDP) = mdp.S
reward(mdp::MappedDiscreteMDP, s, a) = mdp.R[mdp.stateIndex[s], mdp.actionIndex[a]]
transition(mdp::MappedDiscreteMDP, s0, a, s1) = mdp.T[mdp.stateIndex[s0], mdp.actionIndex[a], mdp.stateIndex[s1]]
discount(mdp::MappedDiscreteMDP) = mdp.discount
stateIndex(mdp::MappedDiscreteMDP, s) = mdp.stateIndex[s]
actionIndex(mdp::MappedDiscreteMDP, a) = mdp.actionIndex[s]
nextStates(mdp::MappedDiscreteMDP, s, a) = mdp.nextStates[(s, a)]
end
