# Introduction to Image Processing in Julia

Material for the Julia Image Processing workshop at the 6th NORMIC Image Processing Workshop.


## Installation of Julia
Go to the [official Website of Julia](https://julialang.org/) and download the latest release for your operating system.
Once you have Julia installed and copied/cloned this repository in your file system you can start a Julia REPL within this folder.
This can look like the following:
```julia
julia> cd("/home/myuser/Downloads/Introduction_Image_Processing_Julia/")

julia> pwd()
"/home/myuser/Downloads/Introduction_Image_Processing_Julia/"
```


## Activating local environment
Via the `Project.toml` and `Manifest.toml` we provide the needed dependencies and versions to execute
the examples provided here. To activate the environment and to start Pluto do:
```julia
(@v1.6) pkg> activate .
  Activating environment at `/home/myuser/Downloads/Introduction_Image_Processing_Julia/Project.toml`

julia> using Pluto

julia> ENV["JULIA_COPY_STACKS"]=1  #only for Linux

julia> Pluto.run()
```
Within Pluto you can then start the notebooks. Please be patient, the loading time of packages in Julia might take a while the first time.
