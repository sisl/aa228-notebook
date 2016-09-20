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
  V_old = copy(V)
  for i = 1:iterations
    for s0i in 1:numStates(mdp)
      s0 = S[s0i]
      for ai = 1:numActions(mdp)
        a = A[ai]
        Q[s0i,ai] = R(s0, a) + discount * sum([0.0; [T(s0, a, s1)*V_old[stateIndex(mdp, s1)] for s1 in nextStates(mdp, s0, a)]])
      end
      V[s0i] = maximum(Q[s0i,:])
    end
    copy!(V_old, V)
  end
end

function updateParameters!(mdp::MappedDiscreteMDP, N, Nsa, ρ, s, a)
  si = mdp.stateIndex[s]
  ai = mdp.actionIndex[a]
  denom = Nsa[si, ai]
  mdp.T[si, ai, :] = N[si, ai, :] ./ denom
  mdp.R[si, ai] = ρ[si, ai] / denom
  mdp.nextStates[(s, a)]= mdp.S[find(mdp.T[si, ai, :])]
end

function isTerminal(mdp::MDP, s0, a)
  S1 = nextStates(mdp, s0, a)
  length(S1) == 0 || 0 == sum(s1 -> transition(mdp, s0, a, s1), S1)
end

nextReward(mdp::MDP, s0, a) = reward(mdp, s0, a)

function nextState(mdp::MDP, s0, a)
  p = [transition(mdp, s0, a, s1) for s1 in states(mdp)]
  s1i = rand(Categorical(p))
  states(mdp)[s1i]
end

abstract Policy

type MLRL <: Policy
    N::Array{Float64,3} # transition counts
    Nsa::Matrix{Float64} # state-action counts
    ρ::Matrix{Float64} # sum of rewards
    lastState
    lastAction
    lastReward
    newEpisode
    mdp::MappedDiscreteMDP
    Q::Matrix{Float64}
    V::Vector{Float64}
    iterations::Int
    epsilon::Float64 # probability of exploration
    function MLRL(S, A; discount=0.9, iterations=20, epsilon=0.2)
        N = zeros(length(S), length(A), length(S))
        Nsa = zeros(length(S), length(A))
        ρ = zeros(length(S), length(A))
        lastState = nothing
        lastAction = nothing
        lastReward = 0.
        mdp = MappedDiscreteMDP(S, A, discount=discount)
        Q = zeros(length(S), length(A))
        V = zeros(length(S))
        newEpisode = true
        new(N, Nsa, ρ, lastState, lastAction, lastReward, newEpisode, mdp, Q, V, iterations, epsilon)
    end
end

function reset(policy::MLRL)
    if !policy.newEpisode
        s0i = policy.mdp.stateIndex[policy.lastState]
        ai = policy.mdp.actionIndex[policy.lastAction]
        policy.Nsa[s0i, ai] += 1
        policy.ρ[s0i, ai] = policy.lastReward
        # update Q and V
        updateParameters!(policy.mdp, policy.N, policy.Nsa, policy.ρ, policy.lastState, policy.lastAction)
        valueIteration!(policy.V, policy.Q, policy.mdp, policy.iterations)
        policy.newEpisode = true
    end
end

function update(policy::MLRL, s, a, r)
    if policy.newEpisode
        policy.newEpisode = false
    else
        s0i = policy.mdp.stateIndex[policy.lastState]
        ai = policy.mdp.actionIndex[policy.lastAction]
        s1i = policy.mdp.stateIndex[s]
        policy.N[s0i, ai, s1i] += 1
        policy.Nsa[s0i, ai] += 1
        policy.ρ[s0i, ai] += policy.lastReward
        # update Q and V
        updateParameters!(policy.mdp, policy.N, policy.Nsa, policy.ρ, policy.lastState, policy.lastAction)
        valueIteration!(policy.V, policy.Q, policy.mdp, policy.iterations)
    end
    policy.lastState = s
    policy.lastAction = a
    policy.lastReward = r
    nothing
end

function action(policy::MLRL, s)
    si = policy.mdp.stateIndex[s]
    ai = indmax(policy.Q[si, :])
    policy.mdp.A[ai]
end

function action(policy::MLRL)
    if rand() < policy.epsilon
        policy.mdp.A[rand(DiscreteUniform(1,numActions(policy.mdp)))]
    else
        action(policy, policy.lastState)
    end
end

function simulate(mdp::MDP, steps::Integer, policy::Policy; script=[])
    S = Any[]
    V = Any[]
    R = Float64[]
    if length(script) == 0
        s = randState(mdp)
    else
        s = script[1]
    end
    for i = 1:steps
        push!(S, s)
        a = action(policy, s)
        r = nextReward(mdp, s, a)
        push!(R, r)
        update(policy, s, a, r)
        push!(V, copy(policy.V))
        if i < length(script)
            s = script[i + 1]
        else
            if isTerminal(mdp, s, a)
                s = randState(mdp)
                reset(policy)
            else
                s = nextState(mdp, s, a)
            end
        end
    end
    (S, R, V)
end

