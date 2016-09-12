using NBInclude

for d in readdir(".")
    if endswith(d, ".ipynb")
        nbinclude(d)
    end
end
