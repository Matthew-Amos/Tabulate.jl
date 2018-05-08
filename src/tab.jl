# Generates the tabulation table
function tab(views, rl, cl, f::Function=length)
    return(
        NamedArray(
            reshape(safemap(f, views), (length(rl), length(cl))),
            (rl, cl)
        )
    )
end

"""
tabulate(vrows, f::Function=length)
tabulate(vrows, vcols, f::Function=length)
tabulate(vrows, vcols, vvals, f::Function=sum)

---

Generates a tabulation table across dimensions.

"""
function tabulate(vrows, f::Function=length)
    tabulate(vartype(vrows)(), vrows, f)
end

function tabulate(vrows, vcols, f::Function=length)
    tabulate(vartype(vrows)(), vartype(vcols)(), vrows, vcols, f)
end

function tabulate(vrows, vcols, vvals, f::Function=sum)
    tabulate(vartype(vrows)(), vartype(vcols)(), vartype(vvals)(), vrows, vcols, vvals, f)
end

# DISPATCH HANDLERS
function tabulate(rowtype::C where C <: Categorical,
                  vrows,
                  f::Function=length)
    rl = unique(vrows)
    cl = [:freq]
    ind = find_matches([vrows], to_tuple(rl))
    tab(ind, rl, cl, f)
end

function tabulate{C <: Categorical}(rowtype::C,
                  coltype::C,
                  vrows,
                  vcols,
                  f::Function=length)
    rl, cl = (unique(vrows), unique(vcols))
    ind = find_matches([vrows, vcols], product(rl, cl))
    tab(ind, rl, cl, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::C,
                  coltype::Q,
                  vrows,
                  vcols,
                  f::Function=length)
    rl, cl = (unique(vrows), [:val])
    ind = find_matches([vrows], rl)
    views = [view(vcols, ind[i]) for i=1:length(ind)]
    tab(views, rl, cl, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::Q,
                  coltype::C,
                  vrows,
                  vcols,
                  f::Function=length)
    rl, cl = ([:val], unique(vcols))
    ind = find_matches([vcols], cl)
    views = [view(vrows, ind[i]) for i=1:length(ind)]
    tab(views, rl, cl, f)
end

function tabulate{C <: Categorical, Q <: Quantitative}(rowtype::C,
                  coltype::C,
                  valtype::Q,
                  vrows,
                  vcols,
                  vvals,
                  f::Function=sum)

     rl = unique(vrows)
     cl = unique(vcols)
     ind = find_matches([vrows, vcols], product(rl, cl))
     views = [view(vvals, ind[i]) for i=1:length(ind)]
     tab(views, rl, cl, f)
end
