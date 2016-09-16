type Bandit
  θ::Vector{Float64} # true bandit probabilities
end
Bandit(k::Integer) = Bandit(rand(k))
pull(b::Bandit, i::Integer) = rand() < b.θ[i]
numArms(b::Bandit) = length(b.θ)

function _get_string_list_of_percentages{R<:Real}(bandit_odds::Vector{R})
    strings = map(θ->@sprintf("%.2f percent", 100θ), bandit_odds)
    retval = strings[1]
    for i in 2 : length(strings)
        retval = retval * ", " * strings[i]
    end
    # latex(retval)
    retval
end

function banditTrial(b)

    for i in 1 : numArms(b)
        but = button("Arm $i")
        display(but)
        sig = foldp((acc, value)->(acc[1]+pull(b,i),acc[2]+1), (0,0), signal(but))
        display(map(s -> @sprintf("%d wins out of %d tries (%d percent)", s[1], s[2], 100*s[1]/s[2]), sig))
        # NOTE: we used to use the latex() wrapper
    end

    t = togglebuttons(["Hide", "Show"], value="Hide", label="True Params")
    display(t)
    display(map(v -> v == "Show" ? _get_string_list_of_percentages(b.θ) : "", signal(t)))
end

function banditEstimation(b)
  B = [button("Arm $i") for i = 1:numArms(b)]
  for (i,but) in enumerate(B)
      display(but)
  end
  sigs = [foldp((acc, value)->(acc[1]+pull(b,i),acc[2]+1), (0,0), signal(B[i])) for i in 1:numArms(b)]
  for (i,sig) in enumerate(sigs)
      display(map(s -> @sprintf("%d wins out of %d tries (%d percent)", s[1], s[2], 100*s[1]/s[2]), sig))
  end

  display(map((sig1,sig2)-> begin
      w1, t1 = sig1[1], sig1[2]
      w2, t2 = sig2[1], sig2[2]
         Axis([
                Plots.Linear(θ->pdf(Beta(w1+1, t1-w1+1), θ), (0,1), legendentry="Beta($(w1+1), $(t1-w1+1))"),
                Plots.Linear(θ->pdf(Beta(w2+1, t2-w2+1), θ), (0,1), legendentry="Beta($(w2+1), $(t2-w2+1))")
                ],
      xmin=0,xmax=1,ymin=0, width="15cm", height="10cm")
      end, sigs[1], sigs[2],
         ))
  t = togglebuttons(["Hide", "Show"], value="Hide", label="True Params")
  display(t)
  display(map(v -> v == "Show" ? string(b.θ) : "", signal(t)))
end

type BanditStatistics
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
winProbabilities(b::BanditStatistics) = (b.numWins + 1)./(b.numTries + 2)

abstract BanditPolicy

function simulate(b::Bandit, policy::BanditPolicy; steps = 10)
    wins = zeros(steps)
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
  ret = zeros(steps)
  for i = 1:iterations
    ret += simulate(b, policy, steps=steps, steps=steps)
  end
  ret ./ iterations
end
