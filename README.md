# KaHyPar.jl

[![CI](https://github.com/kahypar/KaHyPar.jl/workflows/CI/badge.svg)](https://github.com/kahypar/KaHyPar.jl/actions)
[![codecov](https://codecov.io/gh/kahypar/KaHyPar.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kahypar/KaHyPar.jl)

KaHyPar.jl is a Julia interface to the [KaHyPar](https://github.com/kahypar/kahypar) hypergraph partitioning package.

## Hypergraphs and Hypergraph Partitioning
-----------
<img src="https://cloud.githubusercontent.com/assets/484403/25314222/3a3bdbda-2840-11e7-9961-3bbc59b59177.png" alt="alt text" width="50%" height="50%"><img src="https://cloud.githubusercontent.com/assets/484403/25314225/3e061e42-2840-11e7-860c-028a345d1641.png" alt="alt text" width="50%" height="50%">


## Installation

<p>
KaHyPar is a &nbsp;
    <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a>
    &nbsp; package. To install KaHyPar,
    please <a href="https://docs.julialang.org/en/v1/manual/getting-started/">open
    Julia's interactive session (known as REPL)</a> and press <kbd>]</kbd> key in the REPL to use the package mode, then type the following command
</p>

```julia
pkg> add KaHyPar
```

## Usage
KaHyPar.jl natively accepts an incidence matrix as a Julia sparse matrix. 
The following snippet shows how to define and partition a simple hypergraph that contains 7 vertices and 4 hyperedges.

```julia
using KaHyPar
using SparseArrays

# setup incidence matrix
# I and J represent non-zero coordinates in the incidence matrix
I = [1, 3, 1, 2, 4, 5, 4, 5, 7, 3, 6, 7]
J = [1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4]
V = Int.(ones(length(I))) # can technically be any non-zero value

# create the incidence matrix
A = sparse(I, J, V)

# create a KaHyPar hypergraph
h = KaHyPar.HyperGraph(A)

# partition with default edge_cut configuration with maximum imbalance of 10%
KaHyPar.partition(h, 2; configuration=:edge_cut, imbalance=0.1)

# partition with default connectivity configuration with maximum imbalance of 10%
KaHyPar.partition(h, 2; configuration=:connectivity, imbalance=0.1)
```

Configuration files may also be used to define the partition options like the following snippet. Some 
sample configuration files can be found [here](https://github.com/kahypar/KaHyPar.jl/tree/master/src/config).
```julia
# partition with given configuration file (assumes file is in your path)
KaHyPar.partition(h, 2; configuration="km1_rKaHyPar_sea20.ini")
```

It is also possible to partition with node and edge weights, set target block weights, set fixed vertices, or run improvement on existing partitions. The Julia API 
is not documented, but the [test files](https://github.com/kahypar/KaHyPar.jl/tree/master/test) show how to use the aforementioned features.

## License

This Julia wrapper package is released under MIT License.
The KaHyPar C++ library is licensed with the GPL License.
