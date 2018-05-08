# Number of vector pointers in Product struct
function Base.length(p::Product)::Int
    length(p.xss)
end

# Number of combinations in a cartesian inner product
function Base.size(p::Product)::Int
    l = 1
    for i = 1:length(p)
        l *= length(p.xss[i])
    end
    return l
end

# Length * Width
area(v)::Int = prod(size(v))

# Maps a function f over a vector, returning NaN if vector is empty
function safemap(f::Function, v)
    function f_safe(x)
        try
            f(x)
        catch
            NaN
        end
    end
    map(f_safe, v)
end

# Converts vector into a vector of tuples
function to_tuple(v)
    map(x -> (x,), v)
end

# Compares arrays against a tuple
function opt_compare(varr, p::T where T <: Tuple)
    if length(varr) !== length(p)
        throw("length of vectors does not equal length of keys")
    end

    bv = BitArray{1}(length(varr[1]))
    for i=1:length(p)
        if i===1
            bv .= varr[i] .== p[i]
        else
            bv .= bv .& varr[i] .== p[i]
        end
    end

    return bv
end

# Returns indices where arrays match key combinations
function find_matches(varr, k)
    buffer = Array{Array{Int, 1}, 1}(area(k))
    bvecs = Array{BitArray{1}, 1}(length(k))
    bvec = BitArray{1}(length(varr[1]))
    i = 0
    for p in k
        i += 1
        #bvecs .= [varr[j] .== ifelse(length(p)==1, p, p[j]) for j=1:length(p)]
        #bvec .= sum(bvecs) .== length(p)
        bvec .= opt_compare(varr, p)
        buffer[i] = find(bvec)
    end
    return(buffer)
end
