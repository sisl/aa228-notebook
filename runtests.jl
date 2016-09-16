using NBInclude

for d in readdir(".")
    if endswith(d, ".ipynb")
        stuff = "using NBInclude; nbinclude(\"" * d * "\")"
        cmd = `julia -e $stuff`
        run(cmd)
    end
end
