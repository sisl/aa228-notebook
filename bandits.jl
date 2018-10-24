using Printf
using Random
mutable struct Bandit
  θ::Vector{Float64} # true bandit probabilities
end
Bandit(k::Integer) = Bandit(rand(k))
pull(b::Bandit, i::Integer) = rand() < b.θ[i]
numArms(b::Bandit) = length(b.θ)

function _get_string_list_of_percentages(bandit_odds::Vector{R}) where {R<:Real}
    strings = map(θ->Printf.@sprintf("%.2f percent", 100θ), bandit_odds)
    retval = strings[1]
    for i in 2 : length(strings)
        retval = retval * ", " * strings[i]
    end
    retval
end

function banditTrial(b)

    for i in 1 : numArms(b)
        but=button("Arm $i",value=0)
        display(but)
        wins=Observable(0)
        Interact.@on &but>0 ? (wins[] = wins[]+pull(b,i)) : 0
        display(map(s -> Printf.@sprintf("%d wins out of %d tries (%d percent)", wins[], but[], 100*wins[]/but[]), but))
        # NOTE: we used to use the latex() wrapper
    end

    t = togglebuttons(["Hide", "Show"], value="Hide", label="True Params")
    display(t)
    display(map(v -> v == "Show" ? _get_string_list_of_percentages(b.θ) : "", t))
end

function banditEstimation(b)
    B = [button("Arm $i") for i = 1:numArms(b)]
    for i in 1 : numArms(b)
        but=button("Arm $i",value=0)
        display(but)
        wins=Observable(0)
        Interact.@on &but>0 ? (wins[] = wins[]+pull(b,i)) : 0
        display(map(s -> Printf.@sprintf("%d wins out of %d tries (%d percent)", wins[], but[], 100*wins[]/but[]), but))
        display(map(s -> begin
             w = wins[]
             t = but[]
             Axis([
                    Plots.Linear(θ->pdf(Beta(w+1, t-w+1), θ), (0,1), legendentry="Beta($(w+1), $(t-w+1))")
                    ],
             xmin=0,xmax=1,ymin=0, width="15cm", height="10cm")
                    end, but
             ))
    end
    t = togglebuttons(["Hide", "Show"], value="Hide", label="True Params")
    display(t)
    display(map(v -> v == "Show" ? string(b.θ) : "", t))
end

mutable struct BanditStatistics
    numWins::Vector{Int}
    numTries::Vector{Int}
    BanditStatistics(k::Int) = new(zeros(k), zeros(k))
end
numArms(b::BanditStatistics) = length(b.numWins)
function update!(b::BanditStatistics, i::Int, success::Bool)
    b.numTries[i] += 1
    if success
        b.numWins[i] += 1
    end
end
# win probability assuming uniform prior
winProbabilities(b::BanditStatistics) = (b.numWins .+ 1)./(b.numTries .+ 2)

abstract type BanditPolicy end

function simulate(b::Bandit, policy::BanditPolicy; steps = 10)
    wins = zeros(Int, steps)
    s = BanditStatistics(numArms(b))
    for step = 1:steps
        i = arm(policy, s)
        win = pull(b, i)
        update!(s, i, win)
        wins[step] = wins[max(1, step-1)] + (win ? 1 : 0)
    end
    wins
end

function simulateAverage(b::Bandit, policy::BanditPolicy; steps = 10, iterations = 10)
  ret = zeros(Int, steps)
  for i = 1:iterations
    ret += simulate(b, policy, steps=steps)
  end
  ret ./ iterations
end
