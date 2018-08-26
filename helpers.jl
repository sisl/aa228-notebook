using Printf
using LinearAlgebra
macro max(range, ex)
    :(maximum($(Expr(:typed_comprehension, :Float64, ex, range))))
end
macro sum(range, ex)
    :(sum($(Expr(:typed_comprehension, :Float64, ex, range))))
end
macro min(range, ex)
    :(minimum($(Expr(:typed_comprehension, :Float64, ex, range))))
end
macro prod(range, ex)
    :(prod($(Expr(:typed_comprehension, :Float64, ex, range))))
end
macro argmax(range, ex)
    @assert(range.head == :in)
    @assert(length(range.args) == 2)
    :($(range.args[2])[indmax($(Expr(:typed_comprehension, :Float64, ex, range)))])
end
macro argmin(range, ex)
    @assert(range.head == :in)
    @assert(length(range.args) == 2)
    :($(range.args[2])[indmin($(Expr(:typed_comprehension, :Float64, ex, range)))])
end
macro array(range, ex)
    :($(Expr(:typed_comprehension, :Float64, ex, range)))
end

function polyfit(x, y, n)
    A = [float(xi)^p for xi in x, p = 0:n]
    (q, r) = LinearAlgebra.qr(A)
    r \ (q[:,1:n+1]' * y)
end

function prettyPolynomial(λ)
    o = IOBuffer()
    Printf.@printf(o, "\$")
    for i = 1:length(λ)
        if i == 1
            Printf.@printf(o, "%0.2f", λ[i])
        elseif i == 2
            if λ[i] < 0
                Printf.@printf(o, "%0.2f x", λ[i])
            else
                Printf.@printf(o, "+%0.2f x", λ[i])
            end
        else
            if λ[i] < 0
                Printf.@printf(o, "%0.2fx^{%d}", λ[i], i-1)
            else
                Printf.@printf(o, "+%0.2fx^{%d}", λ[i], i-1)
            end
        end
    end
    Printf.@printf(o, "\$")
    String(take!(o))
end

using TikzPictures

function plot_chain(len; fill::Dict{Int,String}=Dict{Int64,String}())
    str = "\\draw "
    for i in 1:len
        fl = get(fill, i, "white")
        str = string(str, "($(i)cm, 0cm) node[draw=black,circle,fill=$fl]{$i}")
        if i == len
            str = string(str, ";")
        else
            str = string(str, " -- ")
        end
    end
    return TikzPicture(str)
end
