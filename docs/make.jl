using TimeArrays
using Documenter

DocMeta.setdocmeta!(TimeArrays, :DocTestSetup, :(using TimeArrays); recursive = true)

makedocs(
    modules = [TimeArrays],
    sitename = "TimeArrays.jl",
    format = Documenter.HTML(;
        repolink = "https://github.com/bhftbootcamp/TimeArrays.jl",
        canonical = "https://bhftbootcamp.github.io/TimeArrays.jl",
        edit_link = "master",
        assets = ["assets/favicon.ico"],
        sidebar_sitename = true,  # Set to 'false' if the package logo already contain its name
    ),
    pages = [
        "Home" => "index.md",
        "API Reference" => [
            "pages/interface.md",
            "pages/arithmetic.md",
            "pages/array.md",
            "pages/rolling.md",
            "pages/resample.md",
        ],
        "For Developers" => [
            "pages/custom_types.md",
        ]
    ],
    warnonly = [:doctest, :missing_docs],
)

deploydocs(;
    repo = "github.com/bhftbootcamp/TimeArrays.jl",
    devbranch = "master",
    push_preview = true,
)
