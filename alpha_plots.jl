using PGFPlots

alpha2vec(alpha::Dict) = [ alpha[:not_hungry], alpha[:hungry] ]

function plot(alpha::Dict)
    Plots.Linear([0,1], alpha2vec(alpha))
end

function plot(alphas::Vector{Dict{Symbol, Float64}})
    plot_array = Plots.Linear[]
    for alpha in alphas
        push!(plot_array, Plots.Linear([0,1], alpha2vec(alpha), style="red,solid,thick", mark="none") )
    end
    #return plot_array
    Axis(plot_array, xlabel="P(hungry=true)", xmin=0,xmax=1)
end
