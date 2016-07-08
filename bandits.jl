type Bandit
  θ::Vector{Float64}
end
Bandit(k::Integer) = Bandit(rand(k))
pull(b::Bandit, i::Integer) = rand() < b.θ[i]
numArms(b::Bandit) = length(b.θ)

# New string formatting function
function _get_latex_string_list_of_percentages{R<:Real}(bandit_odds::Vector{R})
    strings = map(θ->@sprintf("%.2f percent", 100θ), bandit_odds)
    retval = strings[1]
    for i in 2 : length(strings)
        retval = retval * ", " * strings[i]
    end
    latex(retval)
end

function banditTrial(b)       #new version implements the number of wins & tries as one signal, rather than two 
    B = [button("Arm $i") for i = 1:numArms(b)]
    bandit_states = [foldp((acc, value)->(acc[1]+pull(b,i),acc[2]+1), (0,0), signal(B[i])) for i in 1:arms]
    for i = 1:numArms(b)
        display(B[i])
        display(map(s -> latex(@sprintf("%d wins out of %d tries (%d percent)", s[1], s[2], 100*s[1]/s[2])), bandit_states[i]))
    end
    t = togglebuttons(["Hide", "Show"], value="Hide", label="True parameters")
    display(t)
    display(map(v -> v == "Show" ? _get_latex_string_list_of_percentages(b.θ) : latex(""), signal(t)))
end

function banditTrial_old(b)
  B = [button("Arm $i") for i = 1:numArms(b)]
  wins = [foldp((acc, value) -> acc + pull(b,i), 0, signal(B[i])) for i = 1:arms]
  tries = [foldp((acc, value) -> acc + 1, 0, signal(B[i])) for i = 1:arms]
  for i = 1:numArms(b)
    display(B[i])
    display(map((w,t) -> latex(@sprintf("%d wins out of %d tries (%d percent)", w, t, 100*w/t)), wins[i], tries[i]))
  end
  t = togglebuttons(["Hide", "Show"], value="Hide", label="True parameters")
  display(t)
  display(map(v -> v == "Show" ? latex(string(b.θ)) : latex(""), t))
end

function banditEstimation(b)  # This works, but 'wins' is not correct!
  B = [button("Arm $i") for i = 1:numArms(b)]
  tries = [foldp((acc, value) -> acc + 1, 0, signal(B[i])) for i = 1:arms]
  wins = [foldp((acc, value) -> acc + pull(b,i), 0, signal(B[i])) for i = 1:arms]
  for i = 1:numArms(b)
    display(B[i])
    display(map((w,t) -> latex(@sprintf("%d wins out of %d tries (%d percent)", w, t, 100*w/t)), wins[i], tries[i]))
  end
  display(map((w1,t1,w2,t2)->
       Axis([
              Plots.Linear(θ->pdf(Beta(w1+1, t1-w1+1), θ), (0,1), legendentry="Beta($(w1+1), $(t1-w1+1))"),
              Plots.Linear(θ->pdf(Beta(w2+1, t2-w2+1), θ), (0,1), legendentry="Beta($(w2+1), $(t2-w2+1))")
              ],
            xmin=0,xmax=1,ymin=0),
       wins[1], tries[1], wins[2], tries[2]
       ))
  t = togglebuttons(["Hide", "Show"], value="Hide", label="True parameters")
  display(t)
  display(map(v -> v == "Show" ? latex(string(b.θ)) : latex(""), signal(t)))
end

function banditEstimation_old(b)  # This doesn't work: 'tries' never gets updated!
  B = [button("Arm $i") for i = 1:numArms(b)]
  wins = [foldp((acc, value) -> acc + pull(b,i), 0, signal(B[i])) for i = 1:arms]
  tries = [foldp((acc, value) -> acc + 1, 0, signal(B[i])) for i = 1:arms]
  for i = 1:numArms(b)
    display(B[i])
    display(map((w,t) -> latex(@sprintf("%d wins out of %d tries (%d percent)", w, t, 100*w/t)), wins[i], tries[i]))
  end
  display(map((w1,t1,w2,t2)->
       Axis([
              Plots.Linear(θ->pdf(Beta(w1+1, t1-w1+1), θ), (0,1), legendentry="Beta($(w1+1), $(t1-w1+1))"),
              Plots.Linear(θ->pdf(Beta(w2+1, t2-w2+1), θ), (0,1), legendentry="Beta($(w2+1), $(t2-w2+1))")
              ],
            xmin=0,xmax=1,ymin=0),
       wins[1], tries[1], wins[2], tries[2]
       ))
  t = togglebuttons(["Hide", "Show"], value="Hide", label="True parameters")
  display(t)
  display(map(v -> v == "Show" ? latex(string(b.θ)) : latex(""), t))
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
