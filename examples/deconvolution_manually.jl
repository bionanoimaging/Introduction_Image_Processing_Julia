### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 943cd3a0-b9a7-11eb-0852-fb73c86a7ebe
using CUDA, Zygote, Optim, Napari, TestImages, LinearAlgebra, FFTW, Noise, LineSearches, Tullio, Statistics, DeconvOptim, FourierTools

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

# ╔═╡ eeb36b76-e9bc-4734-95d7-b1296f4050b1
function loss(rec, meas)
	return sum(abs2, rec .- meas)
end

# ╔═╡ 5a242207-d570-43c7-bfef-20dc02b5a9ea
begin
	img = Float32.(testimage("simple"))
	img = abs.(resample(img, (256, 256, 256)))
	psf = permutedims(ifftshift(Float32.(testimage("simple_3d_psf").parent)), (3, 1, 2))
	psf = abs.(resample(psf, (256, 256, 256)))
	psf ./= sum(psf)
end;

# ╔═╡ b20ca70f-a979-4a53-ba9c-bf3b91dc5261
@view_image Float32.(testimage("simple_3d_psf").parent)

# ╔═╡ 11c8ac98-14e5-4d47-acef-8e25e876fefa
@view_image permutedims(psf, (3, 1, 2))

# ╔═╡ d2dbe922-9dc1-4996-b753-62c8f7ff5a6b
function create_forward(psf)
	otf = rfft(psf)
	otf_cuda = CuArray(otf)
	function conv(a)
		return irfft(rfft(a) .* otf, size(a, 1))
	end
	
	function conv(a::CuArray)
		return irfft(rfft(a) .* otf_cuda, size(a, 1))
	end
	
	return conv
end

# ╔═╡ a4a8e9e9-d68e-43f2-b575-f6b30861753b
begin
	forward = create_forward(psf)
	measurement = poisson(forward(img), 50)
	measurement_cuda = CuArray(measurement)
end;

# ╔═╡ 09b5ae2e-0031-44fe-a29d-2c0b0105cb65
@view_image measurement

# ╔═╡ 7f9b85e3-a3e6-4120-8fd5-ce30debfbf82
reg(rec) = @tullio r = sqrt(1f-8 + abs2(rec[i, j, k] - rec[i + 1, j, k]) + abs2(rec[i, j, k] - rec[i, j + 1, k]) + abs2(rec[i, j, k] - rec[i, j, k + 1]))

# ╔═╡ dcc35fc0-b894-42aa-b67e-61bd66f1d7a2
begin
	reg_cuda(rec) = DeconvOptim.TV_cuda(num_dims=3)(rec)
	f(rec) = loss(forward(rec.^2), measurement) + 0.001 * reg(rec.^2)
	f(rec::CuArray) = loss(forward(rec.^2), measurement_cuda) + 0.001 * reg_cuda(rec.^2)
	g!(G, rec) = G .= gradient(f, rec)[1]
end

# ╔═╡ 043efd53-e032-4f01-ab13-37a17b9d944c
begin
	rec0 = mean(img) .* ones(Float32, size(img));
	rec0_cuda = CuArray(rec0);
end

# ╔═╡ 8cd58df5-f5d4-4328-b15a-8e8e848a913e
f(rec0_cuda)

# ╔═╡ a4f0df6f-bdab-4ee3-af66-18843424bbe6
reg(rec0)

# ╔═╡ f198cd1d-1fb1-4e00-b135-a69b9c54872b
begin
	f(rec0)
	f(rec0_cuda)
	g!(copy(rec0), rec0)
	g!(copy(rec0_cuda), rec0_cuda)
end;

# ╔═╡ c03997d5-c25d-4996-ba28-6efb7fcd35dc
begin
	f(rec0);
	@time g!(copy(rec0), rec0);
end;

# ╔═╡ beef10c8-2c24-4be2-8396-3024ff899d09
res = Optim.optimize(f, g!, rec0, LBFGS(linesearch=LineSearches.BackTracking()), Optim.Options(iterations=50))

# ╔═╡ f55b0aa2-4de9-43ab-9a30-3d1a7bc85984
res_cuda = Optim.optimize(f, g!, rec0_cuda, LBFGS(linesearch=LineSearches.BackTracking()), Optim.Options(iterations=50))

# ╔═╡ 214fa627-9dd0-45c1-b766-77cbc2494a7d
begin
	rec = Optim.minimizer(res);
	rec_cuda = Optim.minimizer(res_cuda);
end

# ╔═╡ de6df8ce-a6de-4910-a423-ec4e058bd79f
begin
	vr= napari.view_image(rec.^2)
	@add_image vr Array(rec_cuda.^2)
	@add_image vr measurement
	@add_image vr img
	vr.grid.enabled = true
end

# ╔═╡ 08f4c9f4-d812-40e7-b32a-ef80f6e0f3a9
@view_image ifftshift(psf)

# ╔═╡ Cell order:
# ╠═943cd3a0-b9a7-11eb-0852-fb73c86a7ebe
# ╠═fd0311fb-ea86-4e07-b3f9-0038fb539cc8
# ╠═eeb36b76-e9bc-4734-95d7-b1296f4050b1
# ╠═5a242207-d570-43c7-bfef-20dc02b5a9ea
# ╠═b20ca70f-a979-4a53-ba9c-bf3b91dc5261
# ╠═11c8ac98-14e5-4d47-acef-8e25e876fefa
# ╠═d2dbe922-9dc1-4996-b753-62c8f7ff5a6b
# ╠═8cd58df5-f5d4-4328-b15a-8e8e848a913e
# ╠═a4a8e9e9-d68e-43f2-b575-f6b30861753b
# ╠═09b5ae2e-0031-44fe-a29d-2c0b0105cb65
# ╠═7f9b85e3-a3e6-4120-8fd5-ce30debfbf82
# ╠═a4f0df6f-bdab-4ee3-af66-18843424bbe6
# ╠═dcc35fc0-b894-42aa-b67e-61bd66f1d7a2
# ╠═f198cd1d-1fb1-4e00-b135-a69b9c54872b
# ╠═043efd53-e032-4f01-ab13-37a17b9d944c
# ╟─c03997d5-c25d-4996-ba28-6efb7fcd35dc
# ╠═beef10c8-2c24-4be2-8396-3024ff899d09
# ╠═f55b0aa2-4de9-43ab-9a30-3d1a7bc85984
# ╠═214fa627-9dd0-45c1-b766-77cbc2494a7d
# ╠═de6df8ce-a6de-4910-a423-ec4e058bd79f
# ╠═08f4c9f4-d812-40e7-b32a-ef80f6e0f3a9
