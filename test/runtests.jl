using Test
using KaHyPar

println("running tests...")

println("testing partition")

@test include("test_partition.jl")

println("testing weights")

@test include("test_weights.jl")

println("testing improve partition")
@test include("test_improve_partition.jl")

println("testing custom block weights")
@test include("test_set_target_weights.jl")
