using Distributions
using StatsBase
using Random
include("gridworld.jl")
include("helpers.jl")

mutable struct MappedDiscreteMDP{SType,AType} <: MDP{SType,AType}
    S::Vector{SType}
    A::Vector{AType}
    T::Array{Float64,3}
    R::Matrix{Float64}
    discount::Float64
    stateIndex::Dict
    actionIndex::Dict
    nextStates
end

function MappedDiscreteMDP(S::Vector, A::Vector, T, R; discount=0.9)
    stateIndex = Dict([S[i]=>i for i in 1:length(S)])
    actionIndex = Dict([A[i]=>i for i in 1:length(A)])
    nextStates = Dict([(S[si], A[ai])=>S[findall(x->x!=0, T[si, ai, :])] for si=1:length(S), ai=1:length(A)])
    MappedDiscreteMDP(S, A, T, R, discount, stateIndex, actionIndex, nextStates)
end

MappedDiscreteMDP(S::Vector, A::Vector; discount=0.9) =
    MappedDiscreteMDP(S, A,
                    zeros(length(S), length(A), length(S)),
                    zeros(length(S), length(A)),
                    discount=discount)

actions(mdp::MappedDiscreteMDP) = mdp.A
states(mdp::MappedDiscreteMDP) = mdp.S
n_states(mdp::MappedDiscreteMDP) = length(mdp.S)
n_actions(mdp::MappedDiscreteMDP) = length(mdp.A)
reward(mdp::MappedDiscreteMDP, s, a) = mdp.R[mdp.stateIndex[s], mdp.actionIndex[a]]
transition_pdf(mdp::MappedDiscreteMDP, s0, a, s1) = mdp.T[mdp.stateIndex[s0], mdp.actionIndex[a], mdp.stateIndex[s1]]
discount(mdp::MappedDiscreteMDP) = mdp.discount
state_index(mdp::MappedDiscreteMDP, s) = mdp.stateIndex[s]
action_index(mdp::MappedDiscreteMDP, a) = mdp.actionIndex[s]
next_states(mdp::MappedDiscreteMDP, s, a) = mdp.nextStates[(s, a)]


rand_state(mdp::MDP) = states(mdp)[rand(DiscreteUniform(1,n_states(mdp)))]

function value_iteration(mdp::MDP, iterations::Integer)
  V = zeros(n_states(mdp))
  Q = zeros(n_states(mdp), n_actions(mdp))
  value_iteration!(V, Q, mdp, iterations)
  (V, Q)
end

function value_iteration!(V::Vector, Q::Matrix, mdp::MDP, iterations::Integer)
  (S, A, T, R, discount) = locals(mdp)
  V_old = copy(V)
  for i = 1:iterations
    for s0i in 1:n_states(mdp)
      s0 = S[s0i]
      for ai = 1:n_actions(mdp)
        a = A[ai]
        Q[s0i,ai] = R(s0, a) + discount * sum([0.0; [T(s0, a, s1)*V_old[state_index(mdp, s1)] for s1 in next_states(mdp, s0, a)]])
      end
      V[s0i] = maximum(Q[s0i,:])
    end
    copyto!(V_old, V)
  end
end

function update_parameters!(mdp::MappedDiscreteMDP, N, Nsa, ρ, s, a)
  si = mdp.stateIndex[s]
  ai = mdp.actionIndex[a]
  denom = Nsa[si, ai]
  mdp.T[si, ai, :] = N[si, ai, :] ./ denom
  mdp.R[si, ai] = ρ[si, ai] / denom
  mdp.nextStates[(s, a)]= mdp.S[findall(x->x!=0, mdp.T[si, ai, :])]
end

function isterminal(mdp::MDP, s0, a)
  S1 = next_states(mdp, s0, a)
  length(S1) == 0 || 0 == sum(s1 -> transition_pdf(mdp, s0, a, s1), S1)
end

function generate_s(mdp::MDP, s0, a, rng::AbstractRNG=Random.GLOBAL_RNG)
    p = [transition_pdf(mdp, s0, a, s1) for s1 in states(mdp)]
    s1i = sample(rng, Weights(p))
    states(mdp)[s1i]
end

mutable struct MLRL <: Policy
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
        update_parameters!(policy.mdp, policy.N, policy.Nsa, policy.ρ, policy.lastState, policy.lastAction)
        value_iteration!(policy.V, policy.Q, policy.mdp, policy.iterations)
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
        update_parameters!(policy.mdp, policy.N, policy.Nsa, policy.ρ, policy.lastState, policy.lastAction)
        value_iteration!(policy.V, policy.Q, policy.mdp, policy.iterations)
    end
    policy.lastState = s
    policy.lastAction = a
    policy.lastReward = r
    nothing
end

function action(policy::MLRL, s)
    si = policy.mdp.stateIndex[s]
    Qs = policy.Q[si, :]
    ais = findall((in)(maximum(Qs)), Qs)
    ai = rand(ais)
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
        s = rand_state(mdp)
    else
        s = script[1]
    end
    for i = 1:steps
        push!(S, s)
        a = action(policy, s)
        r = reward(mdp, s, a)
        push!(R, r)
        update(policy, s, a, r)
        push!(V, copy(policy.V))
        if i < length(script)
            s = script[i + 1]
        else
            if isterminal(mdp, s, a)
                s = rand_state(mdp)
                reset(policy)
            else
                s = generate_s(mdp, s, a)
            end
        end
    end
    (S, R, V)
end
