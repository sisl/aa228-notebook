using Distributions
include("gridworld.jl")
include("helpers.jl")

randState(mdp::MDP) = states(mdp)[rand(DiscreteUniform(1,numStates(mdp)))]

function valueIteration(mdp::MDP, iterations::Integer)
  V = zeros(numStates(mdp))
  Q = zeros(numStates(mdp), numActions(mdp))
  valueIteration!(V, Q, mdp, iterations)
  (V, Q)
end

function valueIteration!(V::Vector, Q::Matrix, mdp::MDP, iterations::Integer)
  (S, A, T, R, discount) = locals(mdp)
  Vold = copy(V)
  for i = 1:iterations
    for s0i in 1:numStates(mdp)
      for ai = 1:numActions(mdp)
        s0 = S[s0i]
        a = A[ai]
        Q[s0i,ai] = R(s0, a) + discount * @sum (s1 in nextStates(mdp, s0, a)) T(s0, a, s1)*Vold[stateIndex(mdp, s1)]
      end
      V[s0i] = maximum(Q[s0i,:])
    end
    copy!(Vold, V)
  end
end

function updateParameters!(mdp::MappedDiscreteMDP, N, Nsa, ρ, s, a)
  si = mdp.stateIndex[s]
  ai = mdp.actionIndex[a]
  denom = Nsa[si, ai]
  mdp.T[si, ai, :] = N[si, ai, :] ./ denom
  mdp.R[si, ai] = ρ[si, ai] / denom
end

function isTerminal(mdp::MDP, s0, a)
  S1 = nextStates(mdp, s0, a)
  length(S1) == 0 || 0 == @sum (s1 in S1) transition(mdp, s0, a, s1)
end

nextReward(mdp::MDP, s0, a) = reward(mdp, s0, a)

function nextState(mdp::MDP, s0, a)
  p = @array (s1 in states(mdp)) transition(mdp, s0, a, s1)
  s1i = rand(Categorical(p))
  states(mdp)[s1i]
end
