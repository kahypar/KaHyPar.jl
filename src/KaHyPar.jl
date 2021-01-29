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

const default_configuration = joinpath(@__DIR__,"config/cut_kKaHyPar_sea20.ini")

# KaHyPar C API
include("kahypar_h.jl")

# Begin Julia interface
"""
    KaHyPar.HyperGraph
    Hypergraph structure based on hMetis manual.  The Julia structure contains references to an underlying KaHyPar context and KaHyPar hypergraph object.
"""
mutable struct HyperGraph
    context::Ptr
    k_hypergraph::Union{Nothing,Ptr}
    n_vertices::kahypar_hypernode_id_t
    edge_indices::Vector{Csize_t}
    hyperedges::Vector{kahypar_hyperedge_id_t}
    v_weights::Vector{kahypar_hypernode_weight_t}
    e_weights::Vector{kahypar_hyperedge_weight_t}
    config::Union{Nothing,String}
end

#Julia HyperGraph object constructor
function HyperGraph(num_vertices,edge_indices,hyperedges,vertex_weights,edge_weights)
    context =  kahypar_context_new()
    num_edges = kahypar_hyperedge_id_t(length(edge_indices) - 1)
    hypergraph = HyperGraph(context,nothing,num_vertices,edge_indices,hyperedges,vertex_weights,edge_weights,nothing)
    return hypergraph
end

HyperGraph(num_vertices,edge_indices,hyperedges) = HyperGraph(num_vertices,edge_indices,hyperedges,kahypar_hypernode_weight_t.(ones(num_vertices)),
kahypar_hyperedge_weight_t.(ones(length(edge_indices) - 1)),nothing)


"""
KaHyPar.HyperGraph(A::SparseMatrixCSC,vertex_weights::Vector{Int64},edge_weights::Vector{Int64})
Create Hypergraph from a sparse matrix representing the incidence matrix (rows are nodes, columns are edges)
"""
function HyperGraph(A::SparseMatrixCSC,vertex_weights::Vector,edge_weights::Vector)
    N_v,N_e = size(A)
    @assert length(vertex_weights) == N_v
    @assert length(edge_weights) == N_e

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

    return HyperGraph(kahypar_hypernode_id_t(N_v),edge_indices,hyperedges,kahypar_hypernode_weight_t.(vertex_weights),kahypar_hyperedge_weight_t.(edge_weights))
end

#Default weights are 1
function HyperGraph(A::SparseMatrixCSC)
    _check_structure(A) && error("Incidence matrix contains an empty column (i.e. a hyperedge not connected to any vertices).  KaHyPar does not support empty hyperedges.")
    N_v,N_e = size(A)
    vertex_weights = kahypar_hypernode_id_t.(ones(N_v))
    edge_weights = kahypar_hyperedge_id_t.(ones(N_e))
    return HyperGraph(A,vertex_weights,edge_weights)
end

function _check_structure(A::SparseMatrixCSC)
    return any(sum(A,dims = 1) .== 0) #check whether any columns (hyperedges) are empty
end

@deprecate hypergraph HyperGraph

"""
    KaHyPar.partition(H, kparts; options_file = "")
    Partition the hypergraph `H` in `k` parts.  Returns a partition vector
"""
partition(H, kparts;imbalance = 0.03, configuration = default_configuration) = partition(HyperGraph(H), kparts,imbalance = imbalance, configuration = configuration)

#Simple partition wrapper.  We create a new context, load the file, partition the hypergraph, and free the context.
function partition(H::HyperGraph, kparts::Integer; imbalance::Number = 0.03, configuration::Union{Nothing,Symbol,String} = nothing)
    objective = Cint(0)
    parts = Vector{kahypar_partition_id_t}(undef, H.n_vertices)
    num_hyperedges = kahypar_hyperedge_id_t(length(H.edge_indices) - 1)
    if isa(configuration,Symbol)
        if configuration == :edge_cut
            config_file =  joinpath(@__DIR__ ,"config/cut_kKaHyPar_sea20.ini")
        elseif configuration == :connectivity
            config_file =  joinpath(@__DIR__ ,"config/km1_kKaHyPar_sea20.ini")
        else
            error("Unsupported configuration option given")
        end
        H.config = config_file
    elseif isa(configuration,String)
        H.config = configuration
    elseif configuration == nothing && H.config == nothing
        H.config = default_configuration
    end
    kahypar_configure_context_from_file(H.context,H.config)
    if H.k_hypergraph == nothing
        kahypar_partition(H.n_vertices, num_hyperedges, Cdouble(imbalance), kahypar_partition_id_t(kparts),H.v_weights, H.e_weights, H.edge_indices,H.hyperedges, objective, H.context, parts)
    else
        kahypar_partition_hypergraph(H.k_hypergraph,kahypar_partition_id_t(kparts),Cdouble(imbalance),objective,H.context,parts)
    end
    #kahypar_context_free(context)
    return Int.(parts)  #typecast result back to julia Integer
end

#Load a partitioning configuration from a file
function set_config_file(H::HyperGraph,config_file::String)
    H.config = config_file
    return nothing
end

#Improve an existing partition
function improve_partition(H::HyperGraph, kparts::Integer, input_partition::Vector;num_iterations::Int64 = 10, imbalance::Number = 0.03)
    objective = Cint(0)
    parts = Vector{kahypar_partition_id_t}(undef, H.n_vertices)
    num_hyperedges = kahypar_hyperedge_id_t(length(H.edge_indices) - 1)
    input_partition = kahypar_partition_id_t.(input_partition)
    if H.k_hypergraph == nothing
        kahypar_improve_partition(H.n_vertices,num_hyperedges,Cdouble(imbalance),kahypar_partition_id_t(kparts),
        H.v_weights, H.e_weights, H.edge_indices,H.hyperedges,input_partition,num_iterations,objective, H.context, parts)
    else #we already have a hypergraph object
        kahypar_improve_hypergraph_partition(H.k_hypergraph,kahypar_partition_id_t(kparts),Cdouble(imbalance),objective,
        H.context,input_partition,num_iterations,parts)
    end
    return Int.(parts)  #typecast result back to julia Integer
end

function set_target_block_weights(H::HyperGraph,block_weights::Vector{Int64})
    @assert length(block_weights) <= H.n_vertices  "Number of block weights ($(length(block_weights))) must be less than or equal to number of vertices ($(H.n_vertices)) "
    @assert sum(block_weights) >= sum(H.v_weights) "Sum of individual part weights must be greater than sum of vertex weights"
    n_blocks = kahypar_hypernode_id_t(length(block_weights))
    block_weights = kahypar_hypernode_weight_t.(block_weights)
    kahypar_set_custom_target_block_weights(n_blocks,block_weights,H.context)
    return nothing
end

#Fix vertices
function fix_vertices(H::HyperGraph,num_blocks::Int64,fixed_vertex_blocks::Vector{Int64})
    num_edges = kahypar_hyperedge_id_t(length(H.edge_indices) - 1)
    k_hypergraph = kahypar_create_hypergraph(kahypar_partition_id_t(num_blocks),H.n_vertices,num_edges,H.edge_indices,H.hyperedges,H.e_weights,H.v_weights)
    H.k_hypergraph = k_hypergraph
    kahypar_set_fixed_vertices(H.k_hypergraph,kahypar_partition_id_t.(fixed_vertex_blocks))
    return nothing
end

end # module
