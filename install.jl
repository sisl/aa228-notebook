Pkg.add("NBInclude")
Pkg.add("BayesNets")
# Pkg.checkout("BayesNets") # get the latest version
Pkg.add("PGFPlots")
# Pkg.checkout("PGFPlots") # get the latest version
Pkg.add("Interact")
# Pkg.checkout("Interact") # get the latest version
Pkg.add("RDatasets")
Pkg.add("Grid")
Pkg.add("Reactive")

Pkg.add("POMDPs")

using POMDPs
POMDPs.add("GenerativeModels")
POMDPs.add("POMDPToolbox")

println("Dependency install complete! (check for errors)")
