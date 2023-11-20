using KaHyPar
using SparseArrays

I = [1, 3, 1, 2, 4, 5, 4, 5, 7, 3, 6, 7]
J = [1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4]
V = Int.(ones(length(I)))

A = sparse(I, J, V)

h = KaHyPar.HyperGraph(A)

#Free the first 3 vertices in the hypergraph (denoted using -1).  Fix vertices to blocks 1 and 2
KaHyPar.fix_vertices(h, 3, [-1, -1, -1, 1, 1, 2, 2])

#Partition with fixed vertices
partition = KaHyPar.partition(h, 3; configuration=:edge_cut, imbalance=0.1)

#Improve partition with fixed vertices
improved_partition = KaHyPar.improve_partition(
    h, 3, partition; num_iterations=10, imbalance=0.1
)

true
