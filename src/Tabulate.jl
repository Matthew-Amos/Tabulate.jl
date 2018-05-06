using NamedArrays
using VariableTypes
using IterTools.product

abstract type Identity end

v1 = ["A","A","B","C","D","D"]
v2 = [true, false, true, false, true, true]
v3 = [3, 5, 4, 2, 2, 3]
v4 = [10.5, 11.7, 13.8, 8.6, 9.2, 6.0]

function tabulate(v1, f=length)
    tabulate(v1, [:freq], f)
end

function tabulate(v1, v2, f=length; v1_type=Identity, v2_type=Identity)
    v1_t = v1_type == Identity ? vartype(v1) : v1_type
    v2_t = v2_type == Identity ? vartype(v2) : v2_type

    categoricals = sum([v1_t <: Categorical, v2_t <: Categorical])

    if categoricals == 2
        # Two categoricals, default to count by unique combinations
        rl, cl = (unique(v1), unique(v2))
        combn = product(rl, cl)
        ind = find_matches([v1, v2], combn)
        # should f be applied here?
        tab = NamedArray(reshape(length.(ind), (length(rl), length(cl))), (rl, cl))
    elseif categoricals == 1
        # One categorical, default to sum by it
        f = f == length ? sum : f
        if v1_t <: Categorical
            rl, cl = (unique(v1), [:val])
            ind = find_matches([v1], rl)
            tab = NamedArray(reshape(f.([v2[ind[i]] for i=1:length(ind)]), (length(rl), length(cl))), (rl, cl))
        else
            rl, cl = ([:val], unique(v2))
            ind = find_matches([v2], cl)
            tab = NamedArray(reshape(f.([v1[ind[i]] for i=1:length(ind)]), (length(rl), length(cl))), (rl, cl))
        end
    else
        # No categoricals, default to count by bins
        error("Binning not yet supported")
    end
    return(tab)
end

function tabulate(v1, v2, vals, f; v1_type=Identity, v2_type=Identity, vals_type=Identity)

end

# case for:
#  cat cat
#  cat qnt / qnt cat

# Internal
# ========
# Return views
function find_matches(varr, k)
    buffer = Array{Array{Int, 1}, 1}(length(k))
    i = 0
    for p in k
        i += 1
        bvec = [varr[j] .== ifelse(length(p)==1, p, p[j]) for j=1:length(p)]
        bvec = sum(bvec, 1)[1] .== length(p)
        buffer[i] = find(bvec)
    end
    return(buffer)
end
