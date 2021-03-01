### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 97679ed2-655b-11eb-14ba-b39bc9e3da2c
using Logging, D4M, StatsBase, Dates, AAUtils, DataFrames, DataStructures, JavaCall;

# ╔═╡ 6bc71724-6666-11eb-0be5-b16d7b589763
include("hazDBsetup.jl")

# ╔═╡ ccd8749a-655d-11eb-38dc-413babeb2727
md"## Some setup"

# ╔═╡ bf71e6c2-6666-11eb-0686-8d7d507df7d1
ENV["JULIA_COPY_STACKS"]=1

# ╔═╡ 54260956-6565-11eb-253d-212f17b90881
md"### Load our data"

# ╔═╡ 607c3d10-6560-11eb-2ac4-8f6c6e64d975


# ╔═╡ c7814532-655b-11eb-20f4-e3f5e733fb5f


# ╔═╡ 8d924244-655c-11eb-1d99-e1a50cd8f6f8


# ╔═╡ 98072b54-655c-11eb-3715-e3dc49c85877


# ╔═╡ a520daae-655c-11eb-0c2b-ab3d6c1e7473


# ╔═╡ b7c6a230-655c-11eb-1907-97b1afebd774


# ╔═╡ 8a25648e-6565-11eb-312c-cf8362258e33
md"### We loaded up from five sources to consolodate we can just add them together"

# ╔═╡ 6f00290c-655c-11eb-28af-e18b44ccd862
CCD = CCD1 + CCD2 + CCD3 + CCD4 + CCD5;

# ╔═╡ c6f3746e-6565-11eb-2694-2dad384e915e
md"### We can now use the \"CCD\" object (above).  
### It is an AA." 

# ╔═╡ 95b35972-6566-11eb-197e-d570d9d1bf72
md"#### Below, we see a data frame showing the codes and their descriptions that are in our data set."


# ╔═╡ d6a28746-655c-11eb-0e96-d9249b0fb7ef
begin
	tObs = CCD[:,StartsWith("Diagnostic_Results.Observation.code,")]
	tObs1 = col2type(tObs, ":")
	aa2df(tObs1)
end

# ╔═╡ 5daa7d48-655d-11eb-0e85-cbcb626f3a51
begin
	tDiagCodes = CCD[:, StartsWith("Diagnostic_Results.Observation.code:,") ]
	dDiagCodes = countVals(tDiagCodes)
end

# ╔═╡ 14e38462-664b-11eb-1a6c-dd088c86eb74
md"### We have a few functions to support our special needs:"

# ╔═╡ 08f0ebce-655e-11eb-012d-63433f735e80
begin
	function calcAge(tDiagCode)
	    tDiagCodeRows = getrow(tDiagCode)
	    tDiagCodeDocs = CCD[tDiagCodeRows,:]
	    tBirth = tDiagCodeDocs[:,StartsWith("Patient.birth,")]
	    tBirthRows = getrow(tBirth)
	    tBirthDocs = CCD[tBirthRows,:]
	    tEffective = tBirthDocs[:,StartsWith("effectiveTime,")]
	    tEffectiveRows = getrow(tEffective)
	    tBirth = tBirth[tEffectiveRows,:]
	    aBirth = col2type(tBirth, ":")
	    aEffective = col2type(tEffective, ":")
		aDiagCode = col2type(tDiagCode, ":")
	    return aBirth, aEffective, aDiagCode
	end
	function countCategorizeAges(aBirth, aEffective)
		format="yyyymmddHHMMSS"
	    rBirth, cBirth, vBirth = find(aBirth)
	    rEffective, cEffective, vEffective = find(aEffective)
	    vBirth = Dates.DateTime.(vBirth, format)
	    vEffective = Dates.DateTime.(vEffective, format)
	    vAges = Dates.year.(vEffective) - Dates.year.(vBirth)
	    # vAges = vAges[vAges .> 0]
	    # vAges = vAges[vAges .< 100]
		# return size(rBirth), size(fill("Age", size(rBirth))), size(vAges)
		aAges = Assoc(rBirth, fill("Age", size(rBirth)), vAges)
		return countmap(vAges), aAges
	end
	function keyMapp(sd::Dict)

    dOut = SortedDict("0 - 20" => 0, "21 - 40" => 0,  "41 - 60" => 0, "61 - 80" => 0, "81 +" => 0)

    for key in keys(sd)
        if key in 0:20
        elseif key in 21:40
            dOut["0 - 20"] += sd[key]
        elseif key in 41: 60
            dOut["21 - 40"] += sd[key]
        elseif key in 61:80
            dOut["41 - 60"] += sd[key]
        elseif key in 61:80
            dOut["61 - 80"] += sd[key]
        else
            dOut["81 +"] += sd[key]
        end
    end
    return dOut
	end
end

# ╔═╡ 9b9d83b2-6570-11eb-0886-017776dde76b
begin
	aBirth = nothing
	aEffective = nothing
	aDiagCode = nothing
	ys = []
	x = []
	y = []
	for diagCode in getcol(tDiagCodes)
		aBirth, aEffective, aDiagCode = calcAge(tDiagCodes[:, diagCode * ","])
		count, aAges = countCategorizeAges(aBirth, aEffective)
		ageMap = keyMapp(count)
		sym = Symbol(split(diagCode, ":")[2])
		push!(ys, sym)
		if length(x) == 0
			push!(x, convert.(String, keys(ageMap)))
		end
		push!(y, convert.(Int64, values(ageMap)))
	end
	ys = reshape(ys, 1, length(ys))
	bar(x, y, xlabel = "age groups", ylabel = "code count", line = (ys, 1), label = map(string, ys), legend = true, legendtitle = "diagnostic codes")
end

# ╔═╡ b1735ada-657b-11eb-1d99-c563040c1043


# ╔═╡ 3fc707c4-6571-11eb-2532-1b7da3c9c38f
begin
	count, aAge1 = countCategorizeAges(aBirth, aEffective)
 	aBirth1 = val2col(aBirth, ":")
 	aEffective1 = val2col(aEffective, ":")
# 	aDiagCode1 = val2col(tDiagCodes, ":")
	aAge1 = val2col(num2str(aAge1), ":")
	a2CSV = aBirth1 + aEffective1 + tDiagCodes + aAge1
 	a2CSV1 = col2type(a2CSV, ":")

 	WriteCSV(a2CSV1, "agebycode.csv", ",")
	aa2df(a2CSV1)
end

# ╔═╡ b4d0c86c-6649-11eb-0e49-6963636d3fb3
md"## More power"

# ╔═╡ d71d540e-6649-11eb-1c0a-e50adb57831c
vLowEffs = extrema(getcol(CCD[:,StartsWith("Encounters.effectiveTime.low,")]))

# ╔═╡ aca108c6-664c-11eb-0599-25a30880d891
vHighEffs = extrema(getcol(CCD[:,StartsWith("Encounters.effectiveTime.high,")]))

# ╔═╡ 417657d0-664d-11eb-17f1-a9d73d26e43d
extrema(getcol(CCD[:,StartsWith("Encounters.effectiveTime,")]))

# ╔═╡ 607fc7a8-664d-11eb-0869-67a363d3c9d3
begin
	qry = r".*effectiveTime.*"
	extrema(getcol(CCD[:,qry]))
end

# ╔═╡ 485498b8-665f-11eb-3804-2bc4dc38c5d7
md"## Pairing
### Let's identify all documents that are for patients with a given problem.
### In this case: Problem coded as 64572001.
### We use codes because they are more reliable that the descriptions."

# ╔═╡ 869d5aec-665c-11eb-1458-f954980ab8a5
rows = getrow(CCD[:,"Problems.Observation.code:64572001,"])

# ╔═╡ bb1fe80c-665f-11eb-3c17-ff755c0cae93
md"### Then using the ids, we retrieve a set of full documents."

# ╔═╡ aa29fde0-6654-11eb-1084-03bcd0688251
docs = CCD[rows,:]

# ╔═╡ 6639d0d0-67d8-11eb-20cb-3de65d67669b
begin
	colD1 = docs[:,"Diagnostic_Results.Observation.code:777-3,"]
	colM1 = docs[:,"Medications.Material.code:833036,"]
end

# ╔═╡ 12450bb2-6660-11eb-364b-a331a2e04a9f
md"### then using that document set, we look for those that have both a given diagnostic and a given medication.
### We'll display the result."

# ╔═╡ ec231682-665c-11eb-1251-a1e1d7b6ef73
begin
	result = docs[:,"Medications.Material.code:833036,Diagnostic_Results.Observation.code:777-3,"]
	aa2df(result)
end

# ╔═╡ 94bc4e6e-665d-11eb-3b3f-8176fafd261b
aa2df(result)

# ╔═╡ cf5d2c06-664d-11eb-045b-dd1c010cdf76
begin
	C = CCD[:,StartsWith("Encounters.effectiveTime.high:201406," : "Encounters.effectiveTime.low:202006,")]
	extrema(getcol(C))
end

# ╔═╡ 82c89b72-655e-11eb-2c13-ff0ff19d79a7


# ╔═╡ 48d4e7a8-656c-11eb-2707-5bb4a8d051aa


# ╔═╡ Cell order:
# ╟─ccd8749a-655d-11eb-38dc-413babeb2727
# ╠═bf71e6c2-6666-11eb-0686-8d7d507df7d1
# ╠═97679ed2-655b-11eb-14ba-b39bc9e3da2c
# ╠═6bc71724-6666-11eb-0be5-b16d7b589763
# ╠═54260956-6565-11eb-253d-212f17b90881
# ╠═607c3d10-6560-11eb-2ac4-8f6c6e64d975
# ╠═6639d0d0-67d8-11eb-20cb-3de65d67669b
# ╟─c7814532-655b-11eb-20f4-e3f5e733fb5f
# ╟─8d924244-655c-11eb-1d99-e1a50cd8f6f8
# ╟─98072b54-655c-11eb-3715-e3dc49c85877
# ╟─a520daae-655c-11eb-0c2b-ab3d6c1e7473
# ╟─b7c6a230-655c-11eb-1907-97b1afebd774
# ╠═8a25648e-6565-11eb-312c-cf8362258e33
# ╠═6f00290c-655c-11eb-28af-e18b44ccd862
# ╠═c6f3746e-6565-11eb-2694-2dad384e915e
# ╠═95b35972-6566-11eb-197e-d570d9d1bf72
# ╠═d6a28746-655c-11eb-0e96-d9249b0fb7ef
# ╠═5daa7d48-655d-11eb-0e85-cbcb626f3a51
# ╠═14e38462-664b-11eb-1a6c-dd088c86eb74
# ╠═08f0ebce-655e-11eb-012d-63433f735e80
# ╟─9b9d83b2-6570-11eb-0886-017776dde76b
# ╟─b1735ada-657b-11eb-1d99-c563040c1043
# ╠═3fc707c4-6571-11eb-2532-1b7da3c9c38f
# ╠═b4d0c86c-6649-11eb-0e49-6963636d3fb3
# ╠═d71d540e-6649-11eb-1c0a-e50adb57831c
# ╠═aca108c6-664c-11eb-0599-25a30880d891
# ╠═417657d0-664d-11eb-17f1-a9d73d26e43d
# ╠═607fc7a8-664d-11eb-0869-67a363d3c9d3
# ╠═485498b8-665f-11eb-3804-2bc4dc38c5d7
# ╠═869d5aec-665c-11eb-1458-f954980ab8a5
# ╠═bb1fe80c-665f-11eb-3c17-ff755c0cae93
# ╠═aa29fde0-6654-11eb-1084-03bcd0688251
# ╠═12450bb2-6660-11eb-364b-a331a2e04a9f
# ╠═ec231682-665c-11eb-1251-a1e1d7b6ef73
# ╠═94bc4e6e-665d-11eb-3b3f-8176fafd261b
# ╠═cf5d2c06-664d-11eb-045b-dd1c010cdf76
# ╟─82c89b72-655e-11eb-2c13-ff0ff19d79a7
# ╟─48d4e7a8-656c-11eb-2707-5bb4a8d051aa
