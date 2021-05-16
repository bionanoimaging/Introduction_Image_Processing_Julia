### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# ╔═╡ 368b1310-b663-11eb-2d78-c79d87d7e01a
using Images, TestImages, ImageSegmentation, Random, ImageShow

# ╔═╡ abf9b1ed-308e-4e19-af87-81fa8f0cd028
function get_random_color(seed)
    Random.seed!(seed)
    rand(RGB{N0f8})
end

# ╔═╡ 2648125d-8574-4c56-8ee4-b086067949eb
begin
	img = Float32.(channelview(load(download("http://docs.opencv.org/3.1.0/water_coins.jpg")))[1, :, :]);
	Gray.(img)
end

# ╔═╡ c97329a0-6102-41d1-b794-abfd7339ddd2
begin
	img_thresh = img .> 0.8
	Gray.(img_thresh)
end

# ╔═╡ 6dc0d6f8-2f06-462b-9a8e-ab0d94aa4583
typeof(img_thresh)

# ╔═╡ af82e3dc-9502-4ff4-8ec7-614523fcae4b
begin
	img_dist = 1 .- distance_transform(feature_transform(img_thresh))
	Gray.(img_dist)
end

# ╔═╡ 4e96caa9-6976-488d-818e-713886d46c7e
begin
	markers = label_components(img_dist .< -15);
end

# ╔═╡ 4b047fc1-0496-4422-aa6b-0fa77854990d
segments = watershed(img_dist, markers)

# ╔═╡ d0a649b9-f046-44d4-a2cd-a9dc9a539fc3
RGB.(map(i->get_random_color(i), labels_map(segments)) .* (1 .-img_thresh)) 

# ╔═╡ Cell order:
# ╠═368b1310-b663-11eb-2d78-c79d87d7e01a
# ╠═abf9b1ed-308e-4e19-af87-81fa8f0cd028
# ╠═2648125d-8574-4c56-8ee4-b086067949eb
# ╠═c97329a0-6102-41d1-b794-abfd7339ddd2
# ╠═6dc0d6f8-2f06-462b-9a8e-ab0d94aa4583
# ╠═af82e3dc-9502-4ff4-8ec7-614523fcae4b
# ╠═4e96caa9-6976-488d-818e-713886d46c7e
# ╠═4b047fc1-0496-4422-aa6b-0fa77854990d
# ╠═d0a649b9-f046-44d4-a2cd-a9dc9a539fc3
