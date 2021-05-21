### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ efaf0218-42bd-46dd-9f93-de666df37100
md"## Julia Lang

* A relatively new programming language (≈ 10 years)
* General purpose and high level language
* Core paradigm is *Multiple Dispatch*
* Performance comparable to C/C++
* *for loops* don't have a performance penalty

### Reason for Speed
* JIT - Just in Time compilation
* Because of the type system Julia can compile efficient code


### Helpfuls resources
* However, certain differences to other languages
* Consult [performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/)
* [Noteworthy differences to other language](https://docs.julialang.org/en/v1/manual/noteworthy-differences/)
* Ecosystem for image processing for microscopy data is small

### Some important packages
* [Bioformatsloader.jl](https://github.com/ahnlabb/BioformatsLoader.jl)
* [View5D.jl](https://github.com/RainerHeintzmann/View5D.jl)
* [DeconvOptim.jl](https://github.com/roflmaostc/DeconvOptim.jl)
* [Images.jl](https://github.com/JuliaImages/Images.jl/)
* [Napari.jl](https://github.com/mkitti/Napari.jl)
* [FourierTools.jl](https://github.com/bionanoimaging/FourierTools.jl)
* [TestImages.jl](https://github.com/JuliaImages/TestImages.jl)
"

# ╔═╡ d78a922c-efa2-4935-881a-b5dccaa09caa
md"## Multiple Dispatch

* In general no type signatures are needed
* However we can specialize if we want
"

# ╔═╡ 3b8c572c-3d2e-4f68-96f3-b4552ac2d20b
# no type signatures needed
function f(x, y)
	return x + y
end

# ╔═╡ 6b5f335d-15af-43f2-afc4-1b51acc693cc
# However, we can specialize if we want

function f(x::Int, y::Int)
	return 42
end

# ╔═╡ 6ea00fdb-7659-4bd5-83a1-09af4c6f31d7
f(10, 12.1)

# ╔═╡ 034676c5-8a30-488f-a685-d0d4c20d078b
f(10, 11)

# ╔═╡ 7183ba48-5785-41af-afc6-f80bc07916cf
md"## Small for loop array example

Consider an array where we want to sum up all positive numbers
"

# ╔═╡ aa72b577-18f6-4871-b232-d17c2bb5c7fd
arr = randn((100_000_000));

# ╔═╡ 1e79336c-9f63-48ca-aa47-5c96bc7dfd9c
result1 = sum(arr[arr .> 0.0])

# ╔═╡ b71710ee-09fe-4568-9aa7-fc5eaa4b0cb3
function sum_positive(arr)
	res = zero(eltype(arr))
	for entry in arr
		if entry > 0
			res += entry
		end
	end
	return res
end

# ╔═╡ 76f78b1c-b796-4ec5-b857-12635be06a0d
result2 = sum_positive(arr)

# ╔═╡ f9f7a2fe-c0e4-412d-bc88-22b2a8cf9f4c
result1 ≈ result2

# ╔═╡ 03284aee-5c55-4124-93e5-6a4353185cfd
md"The type of `img` is not a pure array but rather a type which encodes color information like `Gray`"

# ╔═╡ Cell order:
# ╠═efaf0218-42bd-46dd-9f93-de666df37100
# ╠═d78a922c-efa2-4935-881a-b5dccaa09caa
# ╠═3b8c572c-3d2e-4f68-96f3-b4552ac2d20b
# ╠═6ea00fdb-7659-4bd5-83a1-09af4c6f31d7
# ╠═6b5f335d-15af-43f2-afc4-1b51acc693cc
# ╠═034676c5-8a30-488f-a685-d0d4c20d078b
# ╠═7183ba48-5785-41af-afc6-f80bc07916cf
# ╠═aa72b577-18f6-4871-b232-d17c2bb5c7fd
# ╠═1e79336c-9f63-48ca-aa47-5c96bc7dfd9c
# ╠═76f78b1c-b796-4ec5-b857-12635be06a0d
# ╠═b71710ee-09fe-4568-9aa7-fc5eaa4b0cb3
# ╠═f9f7a2fe-c0e4-412d-bc88-22b2a8cf9f4c
# ╠═03284aee-5c55-4124-93e5-6a4353185cfd
