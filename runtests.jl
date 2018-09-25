using NBInclude
using Test

@testset "notebooks" begin
    for d in readdir(".")
        # if endswith(d, ".ipynb") && !startswith(d, "08-Markov") && !startswith(d, "09-") && !startswith(d, "11-") && !startswith(d, "16-") && !startswith(d, "POM") # ignore MDP notebook because it fails for some reason
        if endswith(d, ".ipynb")
            @info("Running "*d)
            stuff = "using NBInclude; @nbinclude(\"" * d * "\")"
            projdir = dirname(@__FILE__())
            cmd = `julia --project=$projdir -e $stuff`
            proc = run(pipeline(cmd, stderr=stderr), wait=false)
            @test success(proc)
        end
    end
end
