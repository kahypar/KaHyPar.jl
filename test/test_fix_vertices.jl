using KaHyPar
using SparseArrays

I = [1,3,1,2,4,5,4,5,7,3,6,7]
J = [1,1,2,2,2,2,3,3,3,4,4,4]
V = Int.(ones(length(I)))

A = sparse(I,J,V)

h = KaHyPar.HyperGraph(A)

# KaHyPar.fix_vertices(h,3,[0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1])
KaHyPar.fix_vertices(h,3,[-1,0,0,1,1,2,2])

KaHyPar.partition(h,3,configuration = :edge_cut,imbalance = 0.5)

true
