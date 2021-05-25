### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 943cd3a0-b9a7-11eb-0852-fb73c86a7ebe
using CUDA, Zygote, Optim, Napari, TestImages, LinearAlgebra, FFTW, Noise, LineSearches, Tullio, Statistics, DeconvOptim, FourierTools, Colors, ImageShow, Images

# ╔═╡ 11c1d382-a7b0-4c84-b2fa-ee21ea2da201
md"## Import Packages"

# ╔═╡ 26439a7f-d22c-4b1e-a29c-5124c0a68094
FFTW.set_num_threads(6)

# ╔═╡ 0554827f-6a54-42d6-8a03-fd3a2d1112f5
md"## How does CUDA work?"

# ╔═╡ a14bacc8-a080-430b-a8fc-8084ce7a0e4d
begin
	x = rand(10, 10, 10)
	x_c = CuArray(x)
end;

# ╔═╡ e3d6933a-3ef4-4067-bc6a-570b5f5b1bb0
typeof(x)

# ╔═╡ b5e85f9d-e389-456a-b415-6303cffe7bdb
typeof(x_c)

# ╔═╡ 178b4a21-dd8b-4858-9337-5cf062fe4b09
fft(x);

# ╔═╡ d7347964-eda2-4ae2-80f9-ea2eeca640d8
fft(x_c);

# ╔═╡ fd0311fb-ea86-4e07-b3f9-0038fb539cc8
begin
	# prevent slow scalar indexing on GPU
	CUDA.allowscalar(false);

	# we need to fix some operations so that they are fast o GPUs
	# Reference: https://discourse.julialang.org/t/cuarray-and-optim/14053
	LinearAlgebra.norm1(x::CUDA.CuArray{T,N}) where {T,N} = sum(abs, x); # specializes the one-norm
	LinearAlgebra.normInf(x::CUDA.CuArray{T,N}) where {T,N} = maximum(abs, x); # specializes the one-norm
	Optim.maxdiff(x::CUDA.CuArray{T,N},y::CUDA.CuArray{T,N}) where {T,N} = maximum(abs.(x-y));
end

# ╔═╡ 7fcfc7b7-74b9-436b-9de9-e4b13da0087b
testimage("simple_3d_ball")

# ╔═╡ 8e481367-6fd5-4f63-b4e8-e5f84a70acd5
md"## Load example 3D image"

# ╔═╡ 5a242207-d570-43c7-bfef-20dc02b5a9ea
begin
	img = Float32.(testimage("simple_3d_ball"))
	img = abs.(resample(img, (128, 128, 128)))
	psf = permutedims(ifftshift(Float32.(testimage("simple_3d_psf").parent)), (3, 1, 2))
	psf = abs.(resample(psf, (128, 128, 128)))
	psf ./= sum(psf)
end;

# ╔═╡ b20ca70f-a979-4a53-ba9c-bf3b91dc5261
@view_image Float32.(testimage("simple_3d_psf").parent)

# ╔═╡ c979f867-0830-4e0b-aaca-3ccdc3ac2bc9
md"## Define a Loss Function"

# ╔═╡ eeb36b76-e9bc-4734-95d7-b1296f4050b1
function loss(rec, meas)
	return sum(abs2, rec .- meas)
end

# ╔═╡ 0f29fcc1-90f5-4446-b563-7765de99c177
md"## Create a forward deconvolution model 

$$Y = (S * \text{PSF}) + N$$

measurement $Y$, sample $S$,  point spread function $\text{PSF}$, Noise $N$
"

# ╔═╡ d2dbe922-9dc1-4996-b753-62c8f7ff5a6b
begin
	otf = rfft(psf)
	
	function forward(img)
		return irfft(rfft(img) .* otf, size(img, 1))
	end
	
	
	otf_cuda = CuArray(otf)
	p = plan_rfft(CuArray(psf))
	p_inv = inv(p)
	
	function forward(img::CuArray)
		return p_inv.scale .* (p_inv.p * ((p * img) .* otf_cuda))
	end
	
	
	#return conv
	
end

# ╔═╡ cfc95c98-3f72-4b3a-86d6-6c73806330c6
forward(img);

# ╔═╡ 67e0992e-c504-4631-a510-3adb564a434b
img_c = CuArray(img);

# ╔═╡ 877a5075-0dac-456b-9539-3712abd884e0
forward(img_c);

# ╔═╡ ecf713de-7c69-4fc2-8bf2-00bdff7ddf04
md"## Create a noisy measurement"

# ╔═╡ a4a8e9e9-d68e-43f2-b575-f6b30861753b
begin
	measurement = poisson(forward(img), 50)
	measurement_cuda = CuArray(measurement)
end;

# ╔═╡ 09b5ae2e-0031-44fe-a29d-2c0b0105cb65
@view_image measurement

# ╔═╡ 88498069-35df-489d-9973-57695163fcdb
md"## Regularizer"

# ╔═╡ 7f9b85e3-a3e6-4120-8fd5-ce30debfbf82
reg(rec) = @tullio r = sqrt(1f-8 + abs2(rec[i, j, k] - rec[i + 1, j, k]) + abs2(rec[i, j, k] - rec[i, j + 1, k]) + abs2(rec[i, j, k] - rec[i, j, k + 1]))

# ╔═╡ fdb9ea82-2965-4993-9872-919bc2ed53e8
reg(rec::CuArray) = DeconvOptim.TV_cuda(num_dims=3)(rec)

# ╔═╡ dcc35fc0-b894-42aa-b67e-61bd66f1d7a2
begin
	f(rec) = loss(forward(rec.^2), measurement) + 0.001 * reg(rec.^2)
	f(rec::CuArray) = loss(forward(rec.^2), measurement_cuda) + 0.001 * reg(rec.^2)
	g!(G, rec) = G .= gradient(f, rec)[1]
end

# ╔═╡ 043efd53-e032-4f01-ab13-37a17b9d944c
begin
	rec0 = mean(measurement) .* ones(Float32, size(measurement));
	rec0_cuda = CuArray(rec0);
end;

# ╔═╡ f198cd1d-1fb1-4e00-b135-a69b9c54872b
begin
	f(rec0)
	f(rec0_cuda)
	g!(copy(rec0), rec0)
	g!(copy(rec0_cuda), rec0_cuda)
end;

# ╔═╡ eb9aaea3-b521-4b40-a3c8-04c893c1bf9c
md"## Optimizer"

# ╔═╡ beef10c8-2c24-4be2-8396-3024ff899d09
@time res = Optim.optimize(f, g!, rec0, LBFGS(linesearch=LineSearches.BackTracking()), Optim.Options(iterations=40))

# ╔═╡ f55b0aa2-4de9-43ab-9a30-3d1a7bc85984
CUDA.@time res_cuda = Optim.optimize(f, g!, rec0_cuda, LBFGS(linesearch=LineSearches.BackTracking()), Optim.Options(iterations=40))

# ╔═╡ 214fa627-9dd0-45c1-b766-77cbc2494a7d
begin
	rec = Optim.minimizer(res);
	rec_cuda = Optim.minimizer(res_cuda);
end

# ╔═╡ 4fc1d818-f2e8-428d-bd96-0fbfa9af3954
md"## Viewer"

# ╔═╡ de6df8ce-a6de-4910-a423-ec4e058bd79f
begin
	vr= napari.view_image(rec.^2)
	@add_image vr Array(rec_cuda.^2)
	@add_image vr measurement
	@add_image vr img
	vr.grid.enabled = true
end

# ╔═╡ Cell order:
# ╟─11c1d382-a7b0-4c84-b2fa-ee21ea2da201
# ╠═943cd3a0-b9a7-11eb-0852-fb73c86a7ebe
# ╠═26439a7f-d22c-4b1e-a29c-5124c0a68094
# ╠═0554827f-6a54-42d6-8a03-fd3a2d1112f5
# ╠═a14bacc8-a080-430b-a8fc-8084ce7a0e4d
# ╠═e3d6933a-3ef4-4067-bc6a-570b5f5b1bb0
# ╠═b5e85f9d-e389-456a-b415-6303cffe7bdb
# ╠═178b4a21-dd8b-4858-9337-5cf062fe4b09
# ╠═d7347964-eda2-4ae2-80f9-ea2eeca640d8
# ╟─fd0311fb-ea86-4e07-b3f9-0038fb539cc8
# ╠═7fcfc7b7-74b9-436b-9de9-e4b13da0087b
# ╟─8e481367-6fd5-4f63-b4e8-e5f84a70acd5
# ╠═5a242207-d570-43c7-bfef-20dc02b5a9ea
# ╠═b20ca70f-a979-4a53-ba9c-bf3b91dc5261
# ╟─c979f867-0830-4e0b-aaca-3ccdc3ac2bc9
# ╠═eeb36b76-e9bc-4734-95d7-b1296f4050b1
# ╟─0f29fcc1-90f5-4446-b563-7765de99c177
# ╠═d2dbe922-9dc1-4996-b753-62c8f7ff5a6b
# ╠═cfc95c98-3f72-4b3a-86d6-6c73806330c6
# ╠═877a5075-0dac-456b-9539-3712abd884e0
# ╠═67e0992e-c504-4631-a510-3adb564a434b
# ╠═ecf713de-7c69-4fc2-8bf2-00bdff7ddf04
# ╠═a4a8e9e9-d68e-43f2-b575-f6b30861753b
# ╠═09b5ae2e-0031-44fe-a29d-2c0b0105cb65
# ╠═88498069-35df-489d-9973-57695163fcdb
# ╠═7f9b85e3-a3e6-4120-8fd5-ce30debfbf82
# ╠═fdb9ea82-2965-4993-9872-919bc2ed53e8
# ╠═dcc35fc0-b894-42aa-b67e-61bd66f1d7a2
# ╠═f198cd1d-1fb1-4e00-b135-a69b9c54872b
# ╠═043efd53-e032-4f01-ab13-37a17b9d944c
# ╠═eb9aaea3-b521-4b40-a3c8-04c893c1bf9c
# ╠═beef10c8-2c24-4be2-8396-3024ff899d09
# ╠═f55b0aa2-4de9-43ab-9a30-3d1a7bc85984
# ╠═214fa627-9dd0-45c1-b766-77cbc2494a7d
# ╠═4fc1d818-f2e8-428d-bd96-0fbfa9af3954
# ╠═de6df8ce-a6de-4910-a423-ec4e058bd79f
