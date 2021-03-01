#!/usr/bin/env julia
ENV["JULIA_COPY_STACKS"]=1
using D4M, Logging
dbinit()
@info "there==>"
@isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

DB = dbsetup("accumulo", "conf/db.conf")    # Create binding to database.  Shorthand for:
stem = "ccd"
Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T")    # Create database table pair for holding adjacency matrix.
TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
D4M.addColCombiner(TccdDeg,"Degree,","sum");
@info "<==there"