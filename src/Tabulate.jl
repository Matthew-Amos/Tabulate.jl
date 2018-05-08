module Tabulate

using   NamedArrays,
        VariableTypes,
        IterTools.Product,
        IterTools.product

export  tabulate

include("./util.jl")
include("./tab.jl")

end # module
