using KaHyPar
using SparseArrays

I = [1,3,1,2,4,5,4,5,7,3,6,7]
J = [1,1,2,2,2,2,3,3,3,4,4,4]
V = Int.(ones(length(I)))

A = sparse(I,J,V)
A[:,2] .= 0

@test_logs (:warn,"Incidence matrix contains an empty column (i.e. a hyperedge not connected to any vertices).  This might lead to a segmentation fault when partitioning.")  h = KaHyPar.HyperGraph(A)

true
