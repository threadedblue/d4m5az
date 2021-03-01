#!/usr/bin/env julia

using D4M, Logging
@info "there==>"
dbinit()
@isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

DB = dbsetup("dbuno.conf")
@info "DB.instanceName1=" * DB.instanceName
stem = "ccd"
Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T")    # Create database table pair for holding adjacency matrix.
TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
D4M.addColCombiner(TccdDeg,"Degree,","sum");

@info "<==there"
T = Tccd[:,StartsWith("Encounters,")]
printAll(T)