########################################################
# Setup binding to a database.
########################################################
using D4M, Logging
# D4M.dbinit()
@info "there==>"
@isdefined(namesp) || (namesp="")      # SET LOCAL LABEL TO AVOID COLLISIONS.

DB = dbsetup("accumulo", "db.conf")    # Create binding to database.  Shorthand for:
stem = "ccd"
Tccd = D4M.getindex(DB, namesp*stem, namesp*stem*"T")    # Create database table pair for holding adjacency matrix.
TccdDeg = D4M.getindex(DB, namesp*stem*"Deg")
D4M.addColCombiner(TccdDeg,"Degree,","sum");
@info "<==there"