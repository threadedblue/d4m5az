#!/usr/bin/env julia
println("start==>")
using D4M, Distributed
workers = ["haz@uno"]
addprocs(workers; tunnel=true, exename=`julia`, dir="/home/haz", sshflags=`-p 2222`)

@everywhere module Encounters
    using D4M
    dbinit()
    function createT(file)
        A = ReadCSV(file)
        return A.A[1]
    end
end
T = pmap(Encounters.createT, ["ccd1.csv"])
println(T)
println(typeof(T))
rmprocs(workers)
println("<==end")
# shows  Any