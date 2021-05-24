### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 839c36b1-1318-4892-84ab-389b40b2ea48
using PlutoUI

# ╔═╡ efaf0218-42bd-46dd-9f93-de666df37100
md"## Julia Lang

* A relatively new programming language (≈ 10 years)
* General purpose and high level language
* Core paradigm is *Multiple Dispatch*
* Performance comparable to C/C++/Fortran
* For example: *for loops* don't have a performance penalty

### Reason for Speed
* JIT - Just in Time compilation
* type stable functions
* because of the type system Julia can compile efficient code


### Helpfuls resources
* However, severalc differences to other languages
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

# ╔═╡ ad907ec3-7f30-4508-9599-a734c18593af
md"#### sqrt example which fails in Julia because of the types"

# ╔═╡ f8d94633-d125-4da1-a446-bbf4e8fd43a9
sqrt(-1)

# ╔═╡ 8c83a90b-642a-4e9c-abe6-0e1ce0c819b5
sqrt(1) |> typeof

# ╔═╡ d78a922c-efa2-4935-881a-b5dccaa09caa
md"## Multiple Dispatch

* In general no type signatures are needed
* However we can specialize if we want
"

# ╔═╡ 8f247848-6258-4538-9bea-df4897d5716a
md"""
x = $(@bind x Slider(1:10; default=8, show_value=true))
z = $(@bind z Slider(1:10; default=8, show_value=true))
"""

# ╔═╡ 6b5f335d-15af-43f2-afc4-1b51acc693cc
# However, we can specialize if we want
function f(x::Int, y::Int)
	return 42
end

# ╔═╡ 8021d1d9-773d-46d4-9804-6fbe7978f4df
ϵ = 10

# ╔═╡ 7183ba48-5785-41af-afc6-f80bc07916cf
md"## Small for loop array example

Consider an array where we want to sum up all positive numbers
"

# ╔═╡ aa72b577-18f6-4871-b232-d17c2bb5c7fd
Γ = randn((100_000_000, ));

# ╔═╡ 1e79336c-9f63-48ca-aa47-5c96bc7dfd9c
result1 = sum(Γ[Γ .> 0.0])

# ╔═╡ dec2cd2e-2263-4139-b461-1c4c5c49976f
md"## Type Example"

# ╔═╡ 35e81c4d-8673-4b2a-aa0f-457aaefcddb7
abstract type Bit end

# ╔═╡ 6c57ae37-12d0-43c7-9043-3e5dbb0b85e3
struct One <: Bit end

# ╔═╡ e779870d-966a-4ed7-9ab4-54e534518642
struct Zero <: Bit end

# ╔═╡ 214b7930-763b-4034-bf50-05a0c369c02d
begin
	import Base.+
	+(::Bit, ::Bit) = Zero()
	+(::One, ::Zero) = One()
	+(::Zero, ::One) = One()
end

# ╔═╡ 3b8c572c-3d2e-4f68-96f3-b4552ac2d20b
# no type signatures needed
function f(x, y)
	return x + y
end

# ╔═╡ 6ea00fdb-7659-4bd5-83a1-09af4c6f31d7
f(x, z * 1im)

# ╔═╡ 034676c5-8a30-488f-a685-d0d4c20d078b
f(ϵ, x + z)

# ╔═╡ b71710ee-09fe-4568-9aa7-fc5eaa4b0cb3
function sum_positive(Γ)
	res = zero(eltype(Γ))
	for entry in Γ
		if entry > 0
			res += entry
		end
	end
	return res
end

# ╔═╡ 76f78b1c-b796-4ec5-b857-12635be06a0d
result2 = sum_positive(Γ)

# ╔═╡ f9f7a2fe-c0e4-412d-bc88-22b2a8cf9f4c
result1 ≈ result2

# ╔═╡ b0c6f430-3ade-40ef-9468-9701391be788
One() + Zero()

# ╔═╡ e04b7ae2-3282-4093-a35e-1357d48cdff9
Zero() + Zero()

# ╔═╡ Cell order:
# ╠═839c36b1-1318-4892-84ab-389b40b2ea48
# ╠═efaf0218-42bd-46dd-9f93-de666df37100
# ╠═ad907ec3-7f30-4508-9599-a734c18593af
# ╠═f8d94633-d125-4da1-a446-bbf4e8fd43a9
# ╠═8c83a90b-642a-4e9c-abe6-0e1ce0c819b5
# ╠═d78a922c-efa2-4935-881a-b5dccaa09caa
# ╠═3b8c572c-3d2e-4f68-96f3-b4552ac2d20b
# ╟─8f247848-6258-4538-9bea-df4897d5716a
# ╠═6ea00fdb-7659-4bd5-83a1-09af4c6f31d7
# ╠═6b5f335d-15af-43f2-afc4-1b51acc693cc
# ╠═8021d1d9-773d-46d4-9804-6fbe7978f4df
# ╠═034676c5-8a30-488f-a685-d0d4c20d078b
# ╠═7183ba48-5785-41af-afc6-f80bc07916cf
# ╠═aa72b577-18f6-4871-b232-d17c2bb5c7fd
# ╠═1e79336c-9f63-48ca-aa47-5c96bc7dfd9c
# ╠═76f78b1c-b796-4ec5-b857-12635be06a0d
# ╠═b71710ee-09fe-4568-9aa7-fc5eaa4b0cb3
# ╠═f9f7a2fe-c0e4-412d-bc88-22b2a8cf9f4c
# ╠═dec2cd2e-2263-4139-b461-1c4c5c49976f
# ╠═35e81c4d-8673-4b2a-aa0f-457aaefcddb7
# ╠═6c57ae37-12d0-43c7-9043-3e5dbb0b85e3
# ╠═e779870d-966a-4ed7-9ab4-54e534518642
# ╠═214b7930-763b-4034-bf50-05a0c369c02d
# ╠═b0c6f430-3ade-40ef-9468-9701391be788
# ╠═e04b7ae2-3282-4093-a35e-1357d48cdff9
