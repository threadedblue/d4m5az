#!/usr/bin/env julia
ENV["JULIA_COPY_STACKS"]=1
using JavaCall
JavaCall.init(["-Xmx128M"])
jlm = @jimport java.lang.Math
println(jcall(jlm, "sin", jdouble, (jdouble,), pi/2))    