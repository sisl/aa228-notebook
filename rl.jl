using Distributions
include("gridworld.jl")

randState(mdp::MDP) = rand(DiscreteUniform(1,numStates(mdp)))

function valueIteration!(V::Vector, Q::Matrix, mdp::MDP, iterations::Integer)
  numStates = length(V)
  Vold = copy(V)
  for i = 1:iterations
    for s in 1:numStates
      Q[s,:] = mdp.R[s, :] + (mdp.discount * squeeze(mdp.T[s, :, :], 1) * Vold)'
      V[s] = maximum(Q[s,:])
    end
    copy!(Vold, V)
  end
end

function estimateParameters!(mdp::MDP, N, ρ)
  numStates = size(N, 1)
  numActions = size(N, 2)
  mdp.T = copy(N)
  mdp.R = copy(ρ)
  for s0 = 1:numStates
    for a = 1:numActions
      denom = sum(N[s0, a, :])
      if denom > 0
        mdp.T[s0, a, :] /= denom
        mdp.R[s0, a] /= denom
      end
    end
  end
end

function isTerminal(mdp::MDP, s, a)
  s0i = mdp.stateIndex[s]
  ai = mdp.actionIndex[a]
  sum(mdp.T[s0i, ai, :]) == 0
end

function nextStateReward(mdp::MDP, s, a)
  s0i = mdp.stateIndex[s]
  ai = mdp.actionIndex[a]
  p = squeeze(mdp.T[s0i, ai, :], (1,2))
  if abs(sum(p) - 1) > 0.001
    error("Probabilities sum to $(sum(p))")
  end
  s1i = rand(Categorical(p))
  r = mdp.R[s0i, ai]
  (mdp.S[s1i], r)
end
