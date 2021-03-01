module Encounters
    
    using D4M, Logging
    logger = Logging.SimpleLogger(stdout,Logging.Debug)
    global_logger(logger)
    dbinit()
    @isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

    DB = dbsetup("dbuno.conf")
    @debug "DB.instanceName=" * DB.instanceName

    @debug "create()"
    function createT()::DBtablePair
        stem = "ccd"
        Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T", 5)    # Create database table pair for holding adjacency matrix.
        TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
        D4M.addColCombiner(TccdDeg,"Degree,","sum");
        return Tccd
    end

    function firstT(Tccd::DBtablePair, qry::String)::Assoc
        @debug "qry=" * qry
        T = Tccd[:, StartsWith(qry),]
        return T
    end
    
    function nextT(Tccd::DBtablePair)::Assoc
        return Tccd[]
    end

    @debug "export==>"
    export createT, firstT, nextT
end