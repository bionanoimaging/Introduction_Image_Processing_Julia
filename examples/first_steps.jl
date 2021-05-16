### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ f58b1894-b417-11eb-27a5-41d85790a325
using TestImages, Noise, View5D, Napari, ImageShow

# ╔═╡ 56dc69ff-ec92-4054-9b8f-2bec65c1cf50
v = napari.view_image

# ╔═╡ 0b5a46f9-255b-4f79-ba10-317751999550
# load an image
img = testimage("resolution_test_512")

# ╔═╡ 03284aee-5c55-4124-93e5-6a4353185cfd
md"The type of `img` is not a pure array but rather a type which encodes color information like `Gray`"

# ╔═╡ 24c56b57-430e-4f3d-96af-5c6537b9f8f7
typeof(img)

# ╔═╡ d41e73d6-4a57-4148-b43e-217d4728c771
# we can easily convert to pure array type with Float32 as data type
img_arr = Float32.(img)

# ╔═╡ c90b6904-3c74-4c21-9d14-233e6a510e35
v(img_arr)

# ╔═╡ cd95739d-787d-4080-8cf9-0825790a72f7


# ╔═╡ Cell order:
# ╠═f58b1894-b417-11eb-27a5-41d85790a325
# ╠═56dc69ff-ec92-4054-9b8f-2bec65c1cf50
# ╠═0b5a46f9-255b-4f79-ba10-317751999550
# ╠═03284aee-5c55-4124-93e5-6a4353185cfd
# ╠═24c56b57-430e-4f3d-96af-5c6537b9f8f7
# ╠═d41e73d6-4a57-4148-b43e-217d4728c771
# ╠═c90b6904-3c74-4c21-9d14-233e6a510e35
# ╠═cd95739d-787d-4080-8cf9-0825790a72f7
