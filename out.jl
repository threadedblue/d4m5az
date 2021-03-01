
using D4M, DataFrames
function out(A::Assoc)::DataFrame
    c = D4M.getcol(A)
    dataFrame = convert(DataFrame, D4M.full(A))
    Cols1 = names(dataFrame)
    Cols2 = Symbol[]
#    push!(Cols2, Symbol("rowId"))
    foreach(x -> push!(Cols2, Symbol(x)), unique(c))
    rename!(dataFrame, f => t for (f, t) = zip(Cols1, Cols2))
    deleterows!(dataFrame, 1)
    return dataFrame
end