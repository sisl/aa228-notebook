import Pkg

@info("Adding JuliaPOMDP Package Registry to your global list of registries.")
Pkg.add("POMDPs")
using POMDPs
POMDPs.add_registry()

ENV["PYTHON"]=""

projdir = dirname(@__FILE__())
toml = open(joinpath(projdir, "Project.toml")) do f
    Pkg.TOML.parse(f)
end
pkgs = collect(keys(toml["deps"]))
pkgstring = string([pkg*"\n    " for pkg in pkgs]...)
@info("""
    Installing the following packages to the current environment:

    $pkgstring
""")

Pkg.add(pkgs)

@info("Dependency install complete! (check for errors)")
