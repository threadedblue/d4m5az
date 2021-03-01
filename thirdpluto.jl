### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 97679ed2-655b-11eb-14ba-b39bc9e3da2c
using Logging, D4M, InteractiveUtils, StatsBase, Dates, AAUtils, DataFrames, DataStructures, Markdown, PlutoUI;

# ╔═╡ 5819aa36-72d5-11eb-0a1c-998e6e1c36d2
md"### Using synthetic data
### Because it's synthetic, our data can be lacking--but just a little.
### We want to illustrate possibilities."

# ╔═╡ ccd8749a-655d-11eb-38dc-413babeb2727
md"## Some setup"

# ╔═╡ 54260956-6565-11eb-253d-212f17b90881
md"### Load our data from files, but
### we could use a database"

# ╔═╡ c7814532-655b-11eb-20f4-e3f5e733fb5f
begin
	CCD1 = ReadCSV("ccd321.csv");
	CCD2 = ReadCSV("ccd322.csv");
	CCD3 = ReadCSV("ccd323.csv");
	CCD4 = ReadCSV("ccd324.csv");
	CCD5 = ReadCSV("ccd325.csv");
	CCD6 = ReadCSV("ccd326.csv");
	CCD7 = ReadCSV("ccd327.csv");
	CCD8 = ReadCSV("ccd328.csv");
	CCD9 = ReadCSV("ccd329.csv");
	CCD10 = ReadCSV("ccd330.csv");
	CCD11 = ReadCSV("ccd331.csv");
end

# ╔═╡ 8a25648e-6565-11eb-312c-cf8362258e33
md"### We loaded up from five sources to consolodate we can just add them together.
### This is the \"add\" part of our semiring."

# ╔═╡ 1ca904a4-7791-11eb-0d67-ab8006d7f681
CCD = CCD1 + CCD2 + CCD3 + CCD4 + CCD5 + CCD6 + CCD7 + CCD8 + CCD9 + CCD10 + CCD11;

# ╔═╡ c6f3746e-6565-11eb-2694-2dad384e915e
md"### We can now use the \"CCD\" object (above).  
### It is an AA." 

# ╔═╡ 18a3a312-72f2-11eb-2b23-8b492214495d
begin
#	WriteCSV(CCD, "ccd.csv")
	aa2df(CCD1)
end

# ╔═╡ 95b35972-6566-11eb-197e-d570d9d1bf72
md"## Exploring the data set"


# ╔═╡ d6a28746-655c-11eb-0e96-d9249b0fb7ef
begin
	sectionAct = StartsWith("Section.Act,")
	tAct = CCD[:,sectionAct]
	rAct, cAct, vAct = find(col2type(tAct, ":"))
	countmap(cAct)
end

# ╔═╡ a26984f6-72eb-11eb-34bf-6b7937572698
begin
	sectionEnc = StartsWith("Section.Encounter.effectiveTime.low:201901,")
	tEnc = CCD[:,sectionEnc]
	size(tEnc)[1]
end

# ╔═╡ e0b05640-72eb-11eb-38df-99f1a824ac2c
begin
	section = StartsWith("Section,")
	t = CCD[:,section]
	r, c, v = find(col2type(t, ":"))
	countmap(c)
end

# ╔═╡ 90b78f72-761b-11eb-05c9-a9efb99918c7
begin
	tTitle = CCD[:,StartsWith("Section.title:,")]
	cTitle= find(tTitle)[2]
	countmap(cTitle)
end

# ╔═╡ 3b7619cc-7605-11eb-0a43-c77223fdde1a
md"## Walking the data set"


# ╔═╡ 679f526a-7610-11eb-296a-1b96e27aaf44
begin
	tTitleEnc = CCD[:,"Section.title:Encounters,"]
end

# ╔═╡ d84a6458-76b7-11eb-0575-5dd303b1d647
	rowTitleEnc = getrow(tTitleEnc)

# ╔═╡ 074c4fbe-76b8-11eb-3646-3d3d096e3c8c
begin
	docTitleEnc = CCD[rowTitleEnc,:]
	tCodeEnc = docTitleEnc[:,StartsWith("Section.code:,")]
	aa2df(tCodeEnc)
end

# ╔═╡ 0eecb55c-784e-11eb-03ad-6d8ace65281e
begin
	tCode = docTitleEnc[:,StartsWith("Section.code:,")]
	aa2df(tCode)
end

# ╔═╡ 4c34c976-76b8-11eb-14b9-4bbc9ea41ea4
begin
	tEncCode = tTitleEnc + tCode
end

# ╔═╡ fe8655b8-76b8-11eb-3df0-4d8068ba5bc1
begin
	aEncCode = tEncCode' * tEncCode
	aEncCode = aEncCode - diag(aEncCode)
	aa2df(aEncCode)
end

# ╔═╡ aaac16ac-76b9-11eb-103d-fd341489fd18
aa2df(tEncCode * tEncCode')

# ╔═╡ ce3c4eae-72d9-11eb-046f-c9456778ccf7
md"### Quantify the codes"

# ╔═╡ 63f1236a-76d2-11eb-1e12-ef67ffcced5d
begin
	tSectActCode = CCD[:, StartsWith("Section.Act.code:,")]
	rSectActCode, cSectActCode, vSectActCode = find(tSectActCode)
	countmap(cSectActCode)
end

# ╔═╡ 9e14c648-76d2-11eb-2cb9-5b300491d299
begin
	tSectProcedureCode = CCD[:, StartsWith("Section.Procedure.code:,")]
	rSectProcedureCode, cSectProcedureCode, vSectProcedureCode = find(tSectProcedureCode)
	countmap(cSectProcedureCode)
end

# ╔═╡ c612f5a0-76d2-11eb-39d1-7d8d2713a684
begin
	tSectActObservationCode = CCD[:, StartsWith("Section.Act.Observation.code:,")]
	rSectActObservationCode, cSectActObservationCode, vSectActObservationCode = find(tSectActObservationCode)
	countmap(cSectActObservationCode)
end

# ╔═╡ 49d3f5e2-76e2-11eb-3e91-b34499742593
md"### Let's navigate a network
#### First we take two column queries and combine them."

# ╔═╡ 38f4d822-76d3-11eb-1d96-9b297756255f
begin
	tSectProcedureCode1 = CCD[:, StartsWith("Section.Procedure.code:415300000,")]
	tSectActObservationCode1 = CCD[:, StartsWith("Section.Act.Observation.code:64572001,")]
	tSectProcedureObservationCode1 = tSectProcedureCode1 + tSectActObservationCode1
end

# ╔═╡ a4a627f6-76e2-11eb-2df6-67aba798bb89
md"### Then we multiply so as to get an adjacency array of documents."

# ╔═╡ dd951aea-76d3-11eb-0492-49f30d5cd84f
begin
	aSectProcedureObservationCode1 = tSectProcedureObservationCode1 * tSectProcedureObservationCode1'
	aSectProcedureObservationCode1 = aSectProcedureObservationCode1 - diag(aSectProcedureObservationCode1)
	aa2df(aSectProcedureObservationCode1)
end

# ╔═╡ c8bb873a-76e2-11eb-2622-512e7b34a51a
md"#### We now select a starting vertex.
#### pick a row (3) and a column (2)"

# ╔═╡ 0cd2fcfa-76d4-11eb-1c8c-db649ea9aba6
begin
	A = aSectProcedureObservationCode1["002f4670-19c3-4ac9-9da6-833694acc87f,",:]
	AA = A[:,"0023732c-8b82-4d90-bda4-a085ff824ec6,"]
	AAA = aSectProcedureObservationCode1 * AA'
	AAA = AAA - AAA[:,getcol(AA)]
	aa2df(AA)
end

# ╔═╡ a2603b84-76d9-11eb-0976-49d43805a434
aa2df(AAA)

# ╔═╡ b1a2d83c-76d8-11eb-2ec7-4de69076bceb
aa2df(CCD[getrow(AAA),:])

# ╔═╡ cab7d7f6-76d7-11eb-23b1-733401785cb7
begin
	B = aSectProcedureObservationCode1["010eab55-0134-4055-ba07-0ec84223ec14,",:]
	BB = B[:,"0021bca5-354b-49a9-9aac-59061181b00f,"]
	BBB = aSectProcedureObservationCode1 * BB'
	BBB = BBB - BBB[:,getcol(BB)]
	aa2df(BB)
end

# ╔═╡ 9e0aafa8-76dc-11eb-25a7-ebd87fdd4060
aa2df(BBB)

# ╔═╡ 2d54caf8-76e3-11eb-11b9-99590cd413e3
begin
		C = aSectProcedureObservationCode1["010eab55-0134-4055-ba07-0ec84223ec14,",:]
		CC = C[:,"0021bca5-354b-49a9-9aac-59061181b00f,"]
		CCC = aSectProcedureObservationCode1 * CC'
		CCC = CCC - CCC[:,getcol(CC)]
		aa2df(CC)
end

# ╔═╡ 8b4fd904-76e3-11eb-1ced-433c4fadaa59
aa2df(CCC)

# ╔═╡ 821f63d4-76e5-11eb-25e8-5f3b2aec2300
begin
	ABC = AAA + BBB + CCC
	WriteCSV(ABC, "abc.csv")
	aa2df(ABC)
end

# ╔═╡ 62acec84-76d8-11eb-3971-236f78a0f121
aa2df(CCD["010eab55-0134-4055-ba07-0ec84223ec14,",:])

# ╔═╡ b1735ada-657b-11eb-1d99-c563040c1043


# ╔═╡ a69429ea-73b6-11eb-28d6-4f959ed6c449
md"## We can use Regex"

# ╔═╡ 76fad9be-72e6-11eb-03e1-e5e959f58059
begin
	status = CCD[:,r".*status.*"]
end

# ╔═╡ 98fed048-777c-11eb-3906-ed810e7ec6a8
md"### Problem"

# ╔═╡ b00da106-777c-11eb-33f4-3b2c06cd6236
begin
	tProblem = CCD[:,"Section.title:Problems,"]
	docProblem = CCD[getrow(tProblem),:] 
	tProblemCode = docProblem[:,"Section.code:11450-4,"]
end

# ╔═╡ 21596436-77a9-11eb-38c5-4746b55037d0
md"### Get a diagnostic result from within the problem"

# ╔═╡ 9280c896-777e-11eb-3eba-ffc0da632f15
begin
	docProblem1 = docProblem[getrow(tProblemCode),:] 
	tProblemDiagCode = docProblem1[:,"Section.code:30954-2,"]
end

# ╔═╡ 2287ef48-77aa-11eb-13b6-2578075aca71
md"### Get an observation from within a problem"

# ╔═╡ ce759c84-777f-11eb-3224-7d1d1d66c136
begin
	docProblem2 = docProblem1[getrow(tProblemDiagCode),:] 
	tProblemObsCode = 			docProblem1[:,StartsWith("Section.Organizer.Observation.code:2093-3,")]
end

# ╔═╡ fe715758-77a3-11eb-05cd-0bbf74a34f22
begin
	aa2df(tProblemDiagCode + tProblemObsCode)
end

# ╔═╡ 48d4e7a8-656c-11eb-2707-5bb4a8d051aa


# ╔═╡ 71da1fd2-77aa-11eb-3ce7-953d9f7d486d


# ╔═╡ Cell order:
# ╟─5819aa36-72d5-11eb-0a1c-998e6e1c36d2
# ╟─ccd8749a-655d-11eb-38dc-413babeb2727
# ╠═97679ed2-655b-11eb-14ba-b39bc9e3da2c
# ╟─54260956-6565-11eb-253d-212f17b90881
# ╠═c7814532-655b-11eb-20f4-e3f5e733fb5f
# ╟─8a25648e-6565-11eb-312c-cf8362258e33
# ╠═1ca904a4-7791-11eb-0d67-ab8006d7f681
# ╟─c6f3746e-6565-11eb-2694-2dad384e915e
# ╠═18a3a312-72f2-11eb-2b23-8b492214495d
# ╟─95b35972-6566-11eb-197e-d570d9d1bf72
# ╠═d6a28746-655c-11eb-0e96-d9249b0fb7ef
# ╠═a26984f6-72eb-11eb-34bf-6b7937572698
# ╠═e0b05640-72eb-11eb-38df-99f1a824ac2c
# ╠═90b78f72-761b-11eb-05c9-a9efb99918c7
# ╟─3b7619cc-7605-11eb-0a43-c77223fdde1a
# ╠═679f526a-7610-11eb-296a-1b96e27aaf44
# ╠═d84a6458-76b7-11eb-0575-5dd303b1d647
# ╠═074c4fbe-76b8-11eb-3646-3d3d096e3c8c
# ╠═0eecb55c-784e-11eb-03ad-6d8ace65281e
# ╠═4c34c976-76b8-11eb-14b9-4bbc9ea41ea4
# ╠═fe8655b8-76b8-11eb-3df0-4d8068ba5bc1
# ╠═aaac16ac-76b9-11eb-103d-fd341489fd18
# ╟─ce3c4eae-72d9-11eb-046f-c9456778ccf7
# ╠═63f1236a-76d2-11eb-1e12-ef67ffcced5d
# ╠═9e14c648-76d2-11eb-2cb9-5b300491d299
# ╠═c612f5a0-76d2-11eb-39d1-7d8d2713a684
# ╟─49d3f5e2-76e2-11eb-3e91-b34499742593
# ╠═38f4d822-76d3-11eb-1d96-9b297756255f
# ╟─a4a627f6-76e2-11eb-2df6-67aba798bb89
# ╠═dd951aea-76d3-11eb-0492-49f30d5cd84f
# ╟─c8bb873a-76e2-11eb-2622-512e7b34a51a
# ╠═0cd2fcfa-76d4-11eb-1c8c-db649ea9aba6
# ╠═a2603b84-76d9-11eb-0976-49d43805a434
# ╠═b1a2d83c-76d8-11eb-2ec7-4de69076bceb
# ╠═cab7d7f6-76d7-11eb-23b1-733401785cb7
# ╠═9e0aafa8-76dc-11eb-25a7-ebd87fdd4060
# ╠═2d54caf8-76e3-11eb-11b9-99590cd413e3
# ╠═8b4fd904-76e3-11eb-1ced-433c4fadaa59
# ╠═821f63d4-76e5-11eb-25e8-5f3b2aec2300
# ╠═62acec84-76d8-11eb-3971-236f78a0f121
# ╟─b1735ada-657b-11eb-1d99-c563040c1043
# ╟─a69429ea-73b6-11eb-28d6-4f959ed6c449
# ╠═76fad9be-72e6-11eb-03e1-e5e959f58059
# ╟─98fed048-777c-11eb-3906-ed810e7ec6a8
# ╠═b00da106-777c-11eb-33f4-3b2c06cd6236
# ╟─21596436-77a9-11eb-38c5-4746b55037d0
# ╠═9280c896-777e-11eb-3eba-ffc0da632f15
# ╟─2287ef48-77aa-11eb-13b6-2578075aca71
# ╠═ce759c84-777f-11eb-3224-7d1d1d66c136
# ╠═fe715758-77a3-11eb-05cd-0bbf74a34f22
# ╟─48d4e7a8-656c-11eb-2707-5bb4a8d051aa
# ╠═71da1fd2-77aa-11eb-3ce7-953d9f7d486d
