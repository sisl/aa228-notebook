Pkg.add("NBInclude")
Pkg.add("BayesNets")
Pkg.add("PGFPlots")
Pkg.add("Interact")
Pkg.add("RDatasets")
Pkg.add("Reactive")
Pkg.add("Plots")
Pkg.add("PyCall")
Pkg.add("PyPlot")

# POMDP packages
Pkg.add("POMDPs")
Pkg.add("POMDPModelTools")
Pkg.add("POMDPSimulators")
Pkg.add("POMDPPolicies")
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


# Needed for notebook 16
try
    Pkg.clone("https://github.com/zsunberg/LaserTag.jl")
catch ex
    warn("The following error was encountered when cloning LaserTag:")
    showerror(STDERR, ex)
    println()
    warn("This error was ignored")
end


println("Dependency install complete! (check for errors)")
