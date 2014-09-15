using Distributions
include("gridworld.jl")

randState(g::GridWorld) = rand(DiscreteUniform(1,100))

function valueIteration!(V, Q, T, R, discount, iterations)
  numStates = size(Q, 1)
  numActions = size(Q, 2)
  # continue work here
end