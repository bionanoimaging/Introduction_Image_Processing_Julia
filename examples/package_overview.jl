### A Pluto.jl notebook ###
# v0.14.6

using Markdown
using InteractiveUtils

# ╔═╡ f299bb23-aa3a-4a89-abc8-91459c649a43
begin
	using Revise
	using Pkg
	Pkg.activate("../.")
end

# ╔═╡ b88ba8d6-33c8-4d5b-a673-7030fc768596
using JavaCall, BioformatsLoader, View5D

# ╔═╡ 930855c0-2439-4889-a399-85b23e780b5e
using TestImages, Noise, Napari, ImageShow, Images

# ╔═╡ ecbe0fe3-33b5-4529-b00d-76bf28b66eb4
JavaCall.addClassPath(BioformatsLoader.get_bf_path())

# ╔═╡ a41f9c9d-7a84-4dd4-9b46-62271f4318cb
JavaCall.addOpts("-Xmx2048M"); # Set maximum memory to 2 Gigabyte

# ╔═╡ 77515a38-b65b-11eb-388d-bb59872c6ca1
BioformatsLoader.init()

# ╔═╡ d8ae01cd-7205-4155-80d4-922de74a0464
img = testimage("resolution_test_512")

# ╔═╡ 6e59a98b-a8f6-42e1-972a-85108f5f898e
arr = Float32.(img)

# ╔═╡ d5e27923-fd85-4354-9778-6d14f830bb46
img_color = testimage("mandrill")

# ╔═╡ 7f7a302a-4c5a-4eb2-a41c-9ab0247532c6
arr_color = reshape(permutedims(Float32.(channelview(img_color)), (3,2,1)), (512, 512, 1, 3))

# ╔═╡ 7a6b5f57-bc33-4632-9eb0-259df20198a5
md"The type of `img` is not a pure array but rather a type which encodes color information like `Gray`"

# ╔═╡ 896db842-feab-4d29-811c-53968122b67f
typeof(img)

# ╔═╡ 08afca09-245c-44ed-b29d-f9fe383b4a06
typeof(img_color)

# ╔═╡ 2f4de0ae-0f22-4426-8db1-35b3047b4376
md"# Different Image Viewer"

# ╔═╡ 997308fd-6609-4677-9303-f7d1cea83f17
@vt arr_color

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
data = BioformatsLoader.bf_import("/home/fxw/Downloads/150707_WTstack.lsm")

# ╔═╡ cbc4344f-840f-46e5-84ab-6b13b4347f9e
data

# ╔═╡ 1ab43110-151b-42cf-a9c6-6fd0149de564
view5d(data)

# ╔═╡ Cell order:
# ╠═f299bb23-aa3a-4a89-abc8-91459c649a43
# ╠═b88ba8d6-33c8-4d5b-a673-7030fc768596
# ╠═ecbe0fe3-33b5-4529-b00d-76bf28b66eb4
# ╠═a41f9c9d-7a84-4dd4-9b46-62271f4318cb
# ╠═930855c0-2439-4889-a399-85b23e780b5e
# ╠═77515a38-b65b-11eb-388d-bb59872c6ca1
# ╠═d8ae01cd-7205-4155-80d4-922de74a0464
# ╠═6e59a98b-a8f6-42e1-972a-85108f5f898e
# ╠═d5e27923-fd85-4354-9778-6d14f830bb46
# ╠═7f7a302a-4c5a-4eb2-a41c-9ab0247532c6
# ╟─7a6b5f57-bc33-4632-9eb0-259df20198a5
# ╠═896db842-feab-4d29-811c-53968122b67f
# ╠═08afca09-245c-44ed-b29d-f9fe383b4a06
# ╠═2f4de0ae-0f22-4426-8db1-35b3047b4376
# ╠═997308fd-6609-4677-9303-f7d1cea83f17
# ╠═89800d5e-c1ba-4d42-83f5-76b7d1561bee
# ╠═dadbf7b7-28fb-41ab-86a0-75dd93a222ea
# ╠═a3d556e5-246d-46a9-b117-76ccb9da6da2
# ╠═a35825e6-7c1a-4772-bd83-49a70171baa0
# ╠═cbc4344f-840f-46e5-84ab-6b13b4347f9e
# ╠═1ab43110-151b-42cf-a9c6-6fd0149de564
