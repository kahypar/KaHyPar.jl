# KaHyPar.jl

[![CI](https://github.com/kahypar/KaHyPar.jl/workflows/CI/badge.svg)](https://github.com/kahypar/KaHyPar.jl/actions)
[![codecov](https://codecov.io/gh/kahypar/KaHyPar.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/kahypar/KaHyPar.jl)

KaHyPar.jl is a Julia interface to the [KaHyPar](https://github.com/SebastianSchlag/kahypar) hypergraph partitioning package.

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

### macOS support

Precompiled versions of [KaHyPar](https://github.com/SebastianSchlag/kahypar) are not available for macOS so to use KaHyPar.jl on macOS [one must first
follow the instructions to build this package](https://github.com/kahypar/kahypar#building-kahypar). Installing KaHyPar.jl then proceeds as above with the additional step of setting the `JULIA_KAHYPAR_LIBRARY_PATH` environment variable
to point to the `lib` folder of this build.

```julia
using Pkg
ENV["JULIA_KAHYPAR_LIBRARY_PATH"] = <build_root>/lib
Pkg.add(PackageSpec(url="https://github.com/jalving/KaHyPar.jl.git"))
Pkg.test("KaHyPar")
```
