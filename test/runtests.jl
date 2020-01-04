using KaHyPar
using Test

@testset "KaHyPar.jl" begin
    include("simple_test.jl")

    include("weights.jl")
end
