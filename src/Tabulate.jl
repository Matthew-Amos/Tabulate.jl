module Tabulate

using NamedArrays
using VariableTypes
using IterTools.product

function tabulate(vrows, vcols, f=length)
    tabulate(vartype(vrows)(), vartype(vcols)(), vrows, vcols, f)
end

function tabulate(vrows, vcols, vvals, f=sum)
    tabulate(vartype(vrows)(), vartype(vcols)(), vartype(vvals)(), vrows, vcols, vvals, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::C,
                  coltype::Q,
                  vrows,
                  vcols,
                  f=length)
    rl, cl = (unique(vrows), [:val])
    ind = find_matches([vrows], rl)
    views = [view(vcols, ind[i]) for i=1:length(ind)]
    tab(views, rl, cl, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::Q,
                  coltype::C,
                  vrows,
                  vcols,
                  f=length)
    rl, cl = ([:val], unique(vcols))
    ind = find_matches([vcols], cl)
    views = [view(vrows, ind[i]) for i=1:length(ind)]
    tab(views, rl, cl, f)
end

function tabulate{C <: Categorical}(rowtype::C,
                  coltype::C,
                  vrows,
                  vcols,
                  f=length)
    rl, cl = (unique(vrows), unique(vcols))
    ind = find_matches([vrows, vcols], product(rl, cl))
    tab(ind, rl, cl, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::C,
                  coltype::C,
                  valtype::Q,
                  vrows,
                  vcols,
                  vvals,
                  f=sum)

     rl, cl = (unique(vrows), unique(vcols))
     ind = ind = find_matches([vrows, vcols], product(rl, cl))
     views = [view(vvals, ind[i]) for i=1:length(ind)]
     tab(views, rl, cl, f)
end


function tab(views, rl, cl, f=length)
    return(
        NamedArray(
            reshape(f.(views), (length(rl), length(cl))),
            (rl, cl)
        )
    )
end

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

end # module
