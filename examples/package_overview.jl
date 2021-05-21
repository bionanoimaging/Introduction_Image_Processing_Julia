### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 054a0eb4-635c-403b-871b-3668778ce527
begin
	using Pkg
	Pkg.add(url="https://github.com/ahnlabb/BioformatsLoader.jl")
end

# ╔═╡ 930855c0-2439-4889-a399-85b23e780b5e
BioformatsLoader.init()

# ╔═╡ 8c60880e-3cc6-43d0-837f-67ef00b96c8b
ENV["JULIA_COPY_STACKS"] = 1

# ╔═╡ d8ae01cd-7205-4155-80d4-922de74a0464
img = testimage("resolution_test_512")

# ╔═╡ 6e59a98b-a8f6-42e1-972a-85108f5f898e
arr = Float32.(img)

# ╔═╡ d5e27923-fd85-4354-9778-6d14f830bb46
img_color = testimage("manduril")

# ╔═╡ 7c02fc0e-a45a-4c6a-aaf6-d40a397e30c0


# ╔═╡ 46c327dd-c649-466f-b246-bca44050316d


# ╔═╡ 7f7a302a-4c5a-4eb2-a41c-9ab0247532c6
arr_color = permutedims(Float32.(channelview(img_color)), (2, 3, 1))

# ╔═╡ 7a6b5f57-bc33-4632-9eb0-259df20198a5
md"The type of `img` is not a pure array but rather a type which encodes color information like `Gray`"

# ╔═╡ 896db842-feab-4d29-811c-53968122b67f
typeof(img)

# ╔═╡ 08afca09-245c-44ed-b29d-f9fe383b4a06
typeof(img_color)

# ╔═╡ 2f4de0ae-0f22-4426-8db1-35b3047b4376
md"# Different Image Viewer"

# ╔═╡ 997308fd-6609-4677-9303-f7d1cea83f17
view5d(arr_color)

# ╔═╡ 89800d5e-c1ba-4d42-83f5-76b7d1561bee
begin
	v = napari.view_image(arr_color)
	@add_image v arr_color .* 2
	v.grid.enabled = true
end

# ╔═╡ dadbf7b7-28fb-41ab-86a0-75dd93a222ea


# ╔═╡ a3d556e5-246d-46a9-b117-76ccb9da6da2
md"## BioFormatsLoader
"

# ╔═╡ a35825e6-7c1a-4772-bd83-49a70171baa0
data = BioformatsLoader.bf_import_url("https://samples.fiji.sc/150707_WTstack.lsm")

# ╔═╡ 1ab43110-151b-42cf-a9c6-6fd0149de564
view5d(data)

# ╔═╡ 76b435db-84e8-4d8c-9eb4-bf1bb8c18d31
using BioformatsLoader

# ╔═╡ 77515a38-b65b-11eb-388d-bb59872c6ca1
using Revise, TestImages, Noise, View5D, Napari, ImageShow, Images, BioformatsLoader

# ╔═╡ Cell order:
# ╠═76b435db-84e8-4d8c-9eb4-bf1bb8c18d31
# ╠═930855c0-2439-4889-a399-85b23e780b5e
# ╠═77515a38-b65b-11eb-388d-bb59872c6ca1
# ╠═8c60880e-3cc6-43d0-837f-67ef00b96c8b
# ╠═054a0eb4-635c-403b-871b-3668778ce527
# ╠═d8ae01cd-7205-4155-80d4-922de74a0464
# ╠═6e59a98b-a8f6-42e1-972a-85108f5f898e
# ╠═d5e27923-fd85-4354-9778-6d14f830bb46
# ╠═7c02fc0e-a45a-4c6a-aaf6-d40a397e30c0
# ╠═46c327dd-c649-466f-b246-bca44050316d
# ╠═7f7a302a-4c5a-4eb2-a41c-9ab0247532c6
# ╠═7a6b5f57-bc33-4632-9eb0-259df20198a5
# ╠═896db842-feab-4d29-811c-53968122b67f
# ╠═08afca09-245c-44ed-b29d-f9fe383b4a06
# ╠═2f4de0ae-0f22-4426-8db1-35b3047b4376
# ╠═997308fd-6609-4677-9303-f7d1cea83f17
# ╠═89800d5e-c1ba-4d42-83f5-76b7d1561bee
# ╠═dadbf7b7-28fb-41ab-86a0-75dd93a222ea
# ╠═a3d556e5-246d-46a9-b117-76ccb9da6da2
# ╠═a35825e6-7c1a-4772-bd83-49a70171baa0
# ╠═1ab43110-151b-42cf-a9c6-6fd0149de564
