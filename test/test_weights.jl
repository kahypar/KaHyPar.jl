using KaHyPar
using SparseArrays

I = [1, 3, 1, 2, 4, 5, 4, 5, 7, 3, 6, 7]
J = [1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4]
V = Int.(ones(length(I)))

node_weights = [1, 2, 3, 4, 5, 6, 7]
edge_weights = [1, 2, 2, 1]

A = sparse(I, J, V)

h = KaHyPar.HyperGraph(A, node_weights, edge_weights)

KaHyPar.partition(h, 2; configuration=:edge_cut)

KaHyPar.partition(h, 2; configuration=:connectivity)

KaHyPar.partition(
    h, 2; configuration=joinpath(@__DIR__, "../src/config/km1_rKaHyPar_sea20.ini")
)

true
