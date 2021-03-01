#!/usr/bin/env julia
println("start==>")
using D4M, Distributed
#workers = ["gcr@haz00", "gcr@haz11", "gcr@haz22"]
workers = ["haz@uno"]
#addprocs(workers; tunnel=true, exename=`julia`, dir="/home/gcr")
addprocs(workers; tunnel=true, exename=`julia`, dir="/home/haz", sshflags=`-p 2222`)

@everywhere using Distributed
@everywhere module Encounters
    using D4M, Logging
    logger = Logging.SimpleLogger(stdout,Logging.Debug)
    global_logger(logger)
    dbinit()
    @isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

    DB = dbsetup("dbuno.conf")
    Tccd::DBtablePair
    TccdDeg::DBtablePair
    @debug "DB.instanceName=" * DB.instanceName

    @debug "create()0==>"
    function createT(stem)
        Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T", 5)    # Create database table pair for holding adjacency matrix.
        TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
        D4M.addColCombiner(TccdDeg,"Degree,","sum");
        return Tccd
    end

    function firstT(qry::String)::Assoc
        @debug "qry=" * qry
        T = Tccd[:, StartsWith(qry),]
        return T
    end

    function nextT(dummy)::Assoc
        return Tccd[]
    end

    @debug "export==>"
    export createT, firstT, nextT
end

Tccd = pmap(Encounters.createT, ["ccd"])
@info size(Tccd)
@info typeof(Tccd)
T = pmap(Encounters.firstT, ["Encounters.codeD,"])
@info string(typeof(T))
T += pmap(Encounters.nextT, ["Tccd"])
 @info getrow(T)[1]
 @info getcol(T)[1]
 @info getval(T)[1]
rmprocs(workers)``
println("<==end") 