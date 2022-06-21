using Documenter, BEA

makedocs(
    sitename = "BEA.jl",
    root = joinpath(pkgdir(BEA), "docs"),
    # source = 
)
makedocs(
    modules = BEA,
    sitename = "BEA.jl",
    # root = joinpath(pkgdir(BEA), "docs"),
    source = "src",
    pages = [
        "index.md",
        "api.md",
        "manual.md"
        ]
    )


deploydocs(
    repo = "github.com/Nosferican/BEA.jl.git",
)
