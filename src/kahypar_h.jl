const kahypar_hypernode_id_t = Cuint
const kahypar_hyperedge_id_t = Cuint
const kahypar_hypernode_weight_t = Cint
const kahypar_hyperedge_weight_t = Cint
const kahypar_partition_id_t = Cuint

mutable struct kahypar_context_t
end

#Create a kaypar context.  Return a pointer to it.
function kahypar_context_new()
    context = ccall((:kahypar_context_new,libkahypar),Ptr{kahypar_context_t},())
    return context
end

#Configure the context from a file
function kahypar_configure_context_from_file(context::Ref{kahypar_context_t},filename::String)
    ccall((:kahypar_configure_context_from_file,libkahypar),
        Cvoid,
        (Ref{kahypar_context_t},Cstring),
        context,
        filename)
end

#Free the context
function kahypar_context_free(context::Ref{kahypar_context_t})
    ccall((:kahypar_context_free,libkahypar),
    Cvoid,
    (Ref{kahypar_context_t},),
    context)
end

function kahypar_set_custom_target_block_weights(num_blocks::kahypar_hypernode_id_t,block_weights::Vector{kahypar_hypernode_weight_t},kahypar_context::Ref{kahypar_context_t})
    ccall((:kahypar_set_custom_target_block_weights,libkahypar),
    Cvoid,
    (kahypar_partition_id_t,Ptr{kahypar_hypernode_weight_t},Ptr{kahypar_context_t}),
    num_blocks,block_weights,kahypar_context
    )
    return
end

#Perform kahypar partitioning given hypergraph information.
function kahypar_partition(num_vertices, num_hyperedges, imbalance, num_blocks,
                          vertex_weights, hyperedge_weights, hyperedge_indices,
                          hyperedges, objective, context, partition)
    ccall((:kahypar_partition,libkahypar),
    Cvoid,
    (kahypar_hypernode_id_t,              #num vertices
    kahypar_hyperedge_id_t,               #num hyperedges
    Cdouble,                              #imbalance
    kahypar_partition_id_t,               #num blocks
    Ptr{kahypar_hypernode_weight_t},      #hypernode weights
    Ptr{kahypar_hyperedge_weight_t},      #hyperedge weights
    Ptr{Csize_t},                         #hyperedge indices
    Ptr{kahypar_hyperedge_id_t},          #hyperedges
    Ref{kahypar_hyperedge_weight_t},      #Reference to objective value
    Ptr{kahypar_context_t},               #context (should this be a Ptr or a Ref?)
    Ref{kahypar_partition_id_t}),         #partition
    num_vertices,
    num_hyperedges,
    imbalance,
    num_blocks,
    vertex_weights,
    hyperedge_weights,
    hyperedge_indices,
    hyperedges,
    objective,
    context,
    partition
    )
    return
end

#Improve hypergraph partition
function kahypar_improve_partition(num_vertices, num_hyperedges, imbalance, num_blocks,
                          vertex_weights, hyperedge_weights, hyperedge_indices,
                          hyperedges,input_partition,num_improvement_iterations,objective,context,partition)
    ccall((:kahypar_improve_partition,libkahypar),
    Cvoid,
    (kahypar_hypernode_id_t,              #num vertices
    kahypar_hyperedge_id_t,               #num hyperedges
    Cdouble,                              #imbalance
    kahypar_partition_id_t,               #num blocks
    Ptr{kahypar_hypernode_weight_t},      #hypernode weights
    Ptr{kahypar_hyperedge_weight_t},      #hyperedge weights
    Ptr{Csize_t},                         #hyperedge indices
    Ptr{kahypar_hyperedge_id_t},          #hyperedges
    Ptr{kahypar_partition_id_t},          #input partition
    Csize_t,                              #number of improvement iterations
    Ref{kahypar_hyperedge_weight_t},      #Reference to objective value
    Ptr{kahypar_context_t},               #context (should this be a Ptr or a Ref?)
    Ref{kahypar_partition_id_t}),         #return partition
    num_vertices,
    num_hyperedges,
    imbalance,
    num_blocks,
    vertex_weights,
    hyperedge_weights,
    hyperedge_indices,
    hyperedges,
    input_partition,
    num_improvement_iterations,
    objective,
    context,
    partition
    )
    return
end

#New interface functions that use a KaHyPar hypergraph type
#reference to the underlying C hypergraph type
mutable struct kahypar_hypergraph_t
end

#create a KaHyPar hypergraph object
function kahypar_create_hypergraph(num_blocks,num_vertices,num_hyperedges,hyperedge_indices,hyperedges,hyperedge_weights,vertex_weights)
      k_hypergraph = ccall((:kahypar_create_hypergraph,libkahypar),
          Ptr{kahypar_hypergraph_t},
          (kahypar_partition_id_t,              #num blocks
          kahypar_hypernode_id_t,               #num vertices
          kahypar_hyperedge_id_t,               #num hyperedges
          Ptr{Csize_t},                         #hyperedge indices
          Ptr{kahypar_hyperedge_id_t},          #hyperedges
          Ptr{kahypar_hyperedge_weight_t},      #hyperedge weights
          Ptr{kahypar_hypernode_weight_t},      #vertex weights
          ),
          num_blocks,
          num_vertices,
          num_hyperedges,
          hyperedge_indices,
          hyperedges,
          hyperedge_weights,
          vertex_weights)
      return k_hypergraph
end

#create a hypergraph from an input file
function kahypar_create_hypergraph_from_file(filename::String,num_blocks::kahypar_hypernode_id_t)
  k_hypergraph = ccall((:kahypar_create_hypergraph_from_file,libkahypar),
      Ptr{kahypar_hypergraph_t},
      (Cstring,kahypar_partition_id_t),
      filename,
      num_blocks)
      return k_hypergraph
end

#partition a hypergraph
function kahypar_partition_hypergraph(k_hypergraph,num_blocks,imbalance,objective,context,partition)
    ccall((:kahypar_partition_hypergraph,libkahypar),
    Cvoid,
    (Ptr{kahypar_hypergraph_t},           #hypergraph
    kahypar_partition_id_t,               #num blocks
    Cdouble,                              #imbalance
    Ref{kahypar_hyperedge_weight_t},      #Reference to objective value
    Ptr{kahypar_context_t},               #context (Should this be a Ptr or a Ref?)
    Ref{kahypar_partition_id_t}),         #Partition
    k_hypergraph,
    num_blocks,
    imbalance,
    objective,
    context,
    partition
    )
    return
end

#set fixed vertices in a hypergraph
function kahypar_set_fixed_vertices(k_hypergraph::Ref{kahypar_hypergraph_t},fixed_vertex_blocks::Vector{kahypar_partition_id_t})
    ccall((:kahypar_set_fixed_vertices,libkahypar),
        Cvoid,
        (Ptr{kahypar_hypergraph_t},
        Ptr{kahypar_partition_id_t}),
        k_hypergraph,
        fixed_vertex_blocks)
    return
end

#improve a hypergraph partition
function kahypar_improve_hypergraph_partition(k_hypergraph,num_blocks,imbalance,objective,context,input_partition,num_improvement_iterations,improved_partition)
    ccall((:kahypar_improve_hypergraph_partition,libkahypar),
    Cvoid,
    (Ptr{kahypar_hypergraph_t},           #hypergraph
    kahypar_partition_id_t,               #num blocks
    Cdouble,                              #imbalance
    Ref{kahypar_hyperedge_weight_t},      #Reference to objective value
    Ptr{kahypar_context_t},               #context (Should this be a Ptr or a Ref?)
    Ptr{kahypar_partition_id_t},          #input partition
    Csize_t,                              #number of improvement iterations
    Ref{kahypar_partition_id_t}),         #return partition
    k_hypergraph,
    num_blocks,
    imbalance,
    objective,
    context,
    input_partition,
    num_improvement_iterations,
    improved_partition
    )
    return
end

#Free a hypergraph
function kahypar_hypergraph_free(k_hypergraph::Ref{kahypar_hypergraph_t})
    ccall((:kahypar_hypergraph_free,libkahypar),
    Cvoid,
    (Ref{kahypar_hypergraph_t},),
    k_hypergraph)
end
