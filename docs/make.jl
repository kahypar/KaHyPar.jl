using Documenter, KaHyPar

makedocs(;
    modules=[KaHyPar],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/jalving/KaHyPar.jl/blob/{commit}{path}#L{line}",
    sitename="KaHyPar.jl",
    authors="Jordan Jalving <jhjalving@gmail.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/jalving/KaHyPar.jl",
)
