#!/usr/bin/env julia
println("Start==>")
using Distributed
workers = ["gcr@haz00", "gcr@haz11", "gcr@haz22"]
addprocs(workers; tunnel=true, exename=`julia`, dir="/home/gcr")
@everywhere println(gethostname())
println("<==end")