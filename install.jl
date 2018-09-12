Pkg.add("NBInclude")
Pkg.add("BayesNets")
# Pkg.checkout("BayesNets") # get the latest version
Pkg.add("PGFPlots")
# Pkg.checkout("PGFPlots") # get the latest version
Pkg.add("Interact")
# Pkg.checkout("Interact") # get the latest version
Pkg.add("RDatasets")
Pkg.add("Reactive")
Pkg.add("Plots")
Pkg.add("PyCall")
Pkg.add("PyPlot")

Pkg.add("POMDPs")
Pkg.add("POMDPModelTools")
Pkg.add("POMDPSimulators")
Pkg.add("POMDPModels") # for Crying Baby

try
    Pkg.clone("https://github.com/zsunberg/ContinuumWorld.jl.git")
catch ex
    warn("The following error was encountered when cloning ContinuumWorld:")
    showerror(STDERR, ex)
    println()
    warn("This error was ignored")
end

using POMDPs
POMDPs.add("BasicPOMCP")
POMDPs.add("MCTS")
POMDPs.add("DiscreteValueIteration")

try
    Pkg.clone("https://github.com/zsunberg/LaserTag.jl")
catch ex
    warn("The following error was encountered when cloning LaserTag:")
    showerror(STDERR, ex)
    println()
    warn("This error was ignored")
end


println("Dependency install complete! (check for errors)")
