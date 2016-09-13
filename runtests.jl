using NBInclude

for d in readdir(".")
    if endswith(d, ".ipynb")
        workspace()
        nbinclude(d)
    end
end
