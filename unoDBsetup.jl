#!/usr/bin/env julia
using D4M, Logging
logger=Logging.SimpleLogger(stdout,Logging.Debug)
global_logger(logger)
@info "uno==>"
dbinit()
@isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

DB = dbsetup("dbuno.conf")
@info "DB.instanceName=" * DB.instanceName
stem = "ccd"
Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T", 10)    
# Create database table pair for holding adjacency matrix.
TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
D4M.addColCombiner(TccdDeg,"Degree,","sum");
T = Tccd[:,StartsWith("Encounters,",)]
printFull(T)
@info "<==unoč