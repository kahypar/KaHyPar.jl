using Test
using KaHyPar

println("running tests...")

println("simple test...")

@test include("simple_test.jl")

println("testing weights...")

@test include("weights.jl")
