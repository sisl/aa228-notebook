using NBInclude

for d in readdir(".")
    if endswith(d, ".ipynb") && !startswith(d, "08-Markov") # ignore MDP notebook because it fails for some reason
        stuff = "using NBInclude; nbinclude(\"" * d * "\")"
        cmd = `julia -e $stuff`
        run(cmd)
    end
end
