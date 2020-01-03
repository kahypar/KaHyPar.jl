module KaHyPar

using SparseArrays
using LinearAlgebra
using Libdl

#Load libkahypar with BinaryProvider
__init__() = check_deps()
let depsfile = joinpath(@__DIR__, "..", "deps", "deps.jl")
    if isfile(depsfile)
        include(depsfile)
    else
        error("$(depsfile) does not exist, Please re-run Pkg.build(\"KaHyPar\"), and restart Julia.")
    end
end

const default_configuration = joinpath(@__DIR__,"config/cut_kahypar_mf_jea19.ini")

# KaHyPar C API
include("kahypar_h.jl")

# Julia interface
"""
    KaHyPar.HyperGraph
    Hypergraph structure based on hMetis manual
"""
mutable struct HyperGraph
    context::Ptr
    n_vertices::kahypar_hypernode_id_t
    edge_indices::Vector{Csize_t}
    hyperedges::Vector{kahypar_hyperedge_id_t}
    v_weights::Vector{kahypar_hypernode_weight_t}
    e_weights::Vector{kahypar_hyperedge_weight_t}

    HyperGraph(n_vertices, edge_indices,hyperedges) = new(kahypar_context_new(),n_vertices, edge_indices,hyperedges,kahypar_hypernode_id_t.(ones(n_vertices)),kahypar_hyperedge_id_t.(ones(length(edge_indices) - 1)))
    HyperGraph(n_vertices, edge_indices,hyperedges,vertex_weights,edge_weights) = new(kahypar_context_new(),n_vertices,edge_indices,hyperedges,vertex_weights,edge_weights)
end

"""
KaHyPar.HyperGraph(A::SparseMatrixCSC)
Create Hypergraph from a sparse matrix representing the incidence matrix (rows are nodes, columns are edges)
"""
function hypergraph(A::SparseMatrixCSC)
    N_v,N_e = size(A)

    edge_indices = Vector{Csize_t}(undef, N_e+1)
    edge_indices[1] = 0   #must start at zero for C interface
    hyperedges = Vector{kahypar_hyperedge_id_t}(undef, nnz(A))
    hyperedge_i = 0
    @inbounds for j in 1:N_e
        n_rows = 0
        for k in A.colptr[j] : (A.colptr[j+1] - 1)
            i = A.rowval[k]
            n_rows += 1
            hyperedge_i += 1
            hyperedges[hyperedge_i] = i - 1  #subtract 1 for C interface
        end
        edge_indices[j+1] = edge_indices[j] + n_rows
    end
    resize!(hyperedges, hyperedge_i)

    return HyperGraph(kahypar_hypernode_id_t(N_v), edge_indices, hyperedges)
end

function hypergraph(A::SparseMatrixCSC,vertex_weights::Vector{Int64},edge_weights::Vector{Int64})
    graph = hypergraph(A)
    graph.v_weights = Cint.(vertex_weights)
    graph.e_weights = Cint.(edge_weights)
    return graph
end
HyperGraph(A::SparseMatrixCSC) = hypergraph(A)
HyperGraph(A::SparseMatrixCSC,vertex_weights::Vector{kahypar_hypernode_weight_t},edge_weights::Vector{kahypar_hyperedge_weight_t}) = hypergraph(A,vertex_weights,edge_weights)



"""
    KaHyPar.partition(H, kparts; options_file = "")
    Partition the hypergraph `H` in `k` parts.  Returns a partition vector
"""
partition(H, kparts;imbalance = 0.03, configuration = default_configuration) = partition(hypergraph(H), kparts,imbalance = imbalance, configuration = configuration)


#Simple partition wrapper.  We create a new context, load the file, partition the hypergraph, and free the context.
function partition(H::HyperGraph, kparts::Integer; imbalance::Number = 0.03, configuration::Union{Symbol,String} = default_configuration)

    objective = Cint(0)
    parts = Vector{kahypar_partition_id_t}(undef, H.n_vertices)
    num_hyperedges = kahypar_hyperedge_id_t(length(H.edge_indices) - 1)

    if isa(configuration,Symbol)
        if configuration == :edge_cut
            config_file =  joinpath(@__DIR__ ,"config/cut_kahypar_mf_jea19.ini")
        elseif configuration == :connectivity
            config_file =  joinpath(@__DIR__ ,"config/km1_kahypar_mf_jea19.ini")
        else
            error("Unsupported configuration option given")
        end
    else
        config_file = configuration
    end

    #H.context = kahypar_context_new()
    kahypar_configure_context_from_file(H.context,config_file)
    kahypar_partition(H.n_vertices, num_hyperedges, Cdouble(imbalance), kahypar_partition_id_t(kparts),
                               H.v_weights, H.e_weights, H.edge_indices,
                               H.hyperedges, objective, H.context, parts)
    #kahypar_context_free(context)

    return Int.(parts)  #typecast result back to julia Integer
end


end # module
