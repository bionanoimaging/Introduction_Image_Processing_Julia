### A Pluto.jl notebook ###
# v0.14.6

using Markdown
using InteractiveUtils

# ╔═╡ 48aa5a70-b65d-11eb-1f4c-ed447341ce4f
begin
	using FFTW, DeconvOptim, TestImages, Napari, Noise
	using IndexFunArrays, FourierTools, Colors
	v = napari.view_image
end

# ╔═╡ ced8e77f-035e-4aae-b236-b5196028861f
md"## Load Packages"

# ╔═╡ 6e88b04a-dcb5-4bc9-a4f9-f5b7dfd9965e
FFTW.set_num_threads(1)

# ╔═╡ bf93f8bd-144b-4c90-892e-01df05956327
begin
	img = Float32.(testimage("resolution_test_512"))
end

# ╔═╡ 35262a15-628e-4639-a0ca-2b53ac7fbecc
md"## Simulate a simple PSF"

# ╔═╡ 594eb15c-7f38-4890-8f26-d35a9fe128ad
function simulate_psf(shape, radius, dtype=Float32)
	arr_ft = ones(dtype, shape)
	aperture = rr(shape) .< radius
	arr = abs2.(ift(arr_ft .* aperture))
	arr ./= sum(arr)
	return arr
end

# ╔═╡ ba837952-d782-46eb-846c-7893401a4d4b
psf = ifftshift(simulate_psf(size(img), 30));

# ╔═╡ ed5e859b-aa48-4d43-8378-367be437f17e
v(psf)

# ╔═╡ 3cf013a8-221d-40ca-91b6-0a48774d9317
md"### Create blurry measured image"

# ╔═╡ 085402ed-d42d-40f5-9f70-6c6c0483aa39
measured = poisson(FourierTools.conv(img, psf), 300)

# ╔═╡ eb362894-9ea4-4a0d-8723-7acd39abd567
v(measured)

# ╔═╡ 4464fa21-69d4-4447-ba27-7299d7e8d454
md"## DeconvOptim.jl"

# ╔═╡ 5f7222dc-c2c5-4fd5-879f-0dddc99c9c6e
reg = TV()

# ╔═╡ 16d79931-5ae0-4515-b1f3-f1b694da80c6
res, o = deconvolution(measured, psf, regularizer=reg, iterations=20, λ=0.02);

# ╔═╡ 01a50c2a-bb57-4625-980d-fd4c9d07044e
v(res)

# ╔═╡ Cell order:
# ╟─ced8e77f-035e-4aae-b236-b5196028861f
# ╠═48aa5a70-b65d-11eb-1f4c-ed447341ce4f
# ╠═6e88b04a-dcb5-4bc9-a4f9-f5b7dfd9965e
# ╠═bf93f8bd-144b-4c90-892e-01df05956327
# ╟─35262a15-628e-4639-a0ca-2b53ac7fbecc
# ╠═594eb15c-7f38-4890-8f26-d35a9fe128ad
# ╠═ba837952-d782-46eb-846c-7893401a4d4b
# ╠═ed5e859b-aa48-4d43-8378-367be437f17e
# ╟─3cf013a8-221d-40ca-91b6-0a48774d9317
# ╠═085402ed-d42d-40f5-9f70-6c6c0483aa39
# ╠═eb362894-9ea4-4a0d-8723-7acd39abd567
# ╟─4464fa21-69d4-4447-ba27-7299d7e8d454
# ╠═5f7222dc-c2c5-4fd5-879f-0dddc99c9c6e
# ╠═16d79931-5ae0-4515-b1f3-f1b694da80c6
# ╠═01a50c2a-bb57-4625-980d-fd4c9d07044e
