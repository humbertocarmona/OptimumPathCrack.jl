"""
	Creates a spatial cell list for a set of coordinates, dividing the space into grid cells.
	
	# Arguments
	- `coords::Vector{Tuple{Float64,Float64}}`: A vector of coordinate pairs (latitude, longitude).
	- `cellWidth::Float64 = 100.0`: The width of each cell in meters.
	
	# Returns
	A dictionary containing:
	- "coords": Original coordinates.
	- "pos": Adjusted positions within the grid.
	- "dx", "dy": Grid cell dimensions.
	- "nx", "ny": Grid size.
	- "cells": Sparse matrix mapping cells to node indices.
	- "next": List tracking next nodes within each cell.

	- "cells" and "next" arrays together implement a cell list data structure,
"""
function cellList_lat_lon(coords::Vector{Tuple{Float64, Float64}};
	cellWidth::Float64 = 100.0)
	n_nodes = size(coords, 1)
	debug(logger, "n_nodes = $(n_nodes)")
	lat = [coords[i][1] for i ∈ 1:n_nodes]
	lon = [coords[i][2] for i ∈ 1:n_nodes]
	lat_min, lat_max = extrema(lat)
	lon_min, lon_max = extrema(lon)

	# Compute grid cell dimensions based on cell width
	# 9.043317e-4 degrees corresponds to 100 meters in longitude at a particular latitude.
	# 9.002123e-4 degrees corresponds to 100 meters in latitude.
	d_lon = 9.043317e-4 * cellWidth / 100.0
	d_lat = 9.002123e-4 * cellWidth / 100.0
	Lx = maximum(lon) - minimum(lon)
	Ly = maximum(lat) - minimum(lat)
    nx = Int(ceil(Lx / d_lon)) + 1
	ny = Int(ceil(Ly / d_lat)) + 1
	x = lon .- lon_min
	y = lat .- lat_min

    debug(logger, "ang Lx = $(Lx), Ly = $(Ly)")
	debug(logger, "ang nx = $(nx), ny = $(ny)")

	# # using euclidean_distance
	# dx = dy = 100

	# point1 = LLA(lat_min, lon_min, 0)
	# point2 = LLA(lat_max, lon_min, 0)
	# point3 = LLA(lat_min, lon_max, 0)
	# Ly = euclidean_distance(point1, point2)

	# Lx = euclidean_distance(point1, point3)



	# # Determine number of grid cells in x and y directions
	# nx = Int(ceil(Lx / dx)) + 1
	# ny = Int(ceil(Ly / dy)) + 1

	# debug(logger, "euc Lx = $(Lx), Ly = $(Ly)")
	# debug(logger, "euc nx = $(nx), ny = $(ny)")

	# Initialize cell and next node tracking with zeros
	cells = spzeros(Int, nx, ny)
	next = zeros(Int, n_nodes)


	# Assign nodes to grid cells
	for node in 1:n_nodes
		i = Int(floor(x[node] / d_lat)) + 1
		j = Int(floor(y[node] / d_lon)) + 1
        # debug(logger, "node:$(node),  i=$i, j=$j")

        # point_x = LLA(lat_min, lon[node], 0)
        # point_y = LLA(lat[node], lon_min, 0)
        
        # dist_x = euclidean_distance(point_x, point1)
        # dist_y = euclidean_distance(point_y, point1)
        # i = Int(floor(dist_x / dx)) + 1
        # j = Int(floor(dist_y / dy)) + 1
		# debug(logger, "node:$(node),  i=$i, j=$j")


		if i > nx || j > ny
			debug(logger, "($i, $j) vs. ($nx, $ny)")
		else
			last = cells[i, j]
			cells[i, j] = node
			next[node] = last
		end
	end

	# Store adjusted positions
	pos = [[x[i], y[i]] for i ∈ 1:n_nodes]

	# Return structured output as a dictionary
	return Dict("coords" => coords,
		"pos" => pos,
		"cellSize" => [d_lon,  d_lat],
		"nCells" => [nx,  ny],
		"cells" => cells,
		"next" => next)
end


function cellList_euclidean(coords::Vector{Tuple{Float64, Float64}}; cellWidth::Float64 = 100.0)

	n_nodes = size(coords, 1)
	debug(logger, "n_nodes = $(n_nodes)")
	lat = [coords[i][1] for i ∈ 1:n_nodes]
	lon = [coords[i][2] for i ∈ 1:n_nodes]
	lat_min, lat_max = extrema(lat)
	lon_min, lon_max = extrema(lon)

	# # using euclidean_distance
	
	point1 = LLA(lat_min, lon_min, 0)
	point2 = LLA(lat_max, lon_min, 0)
	point3 = LLA(lat_min, lon_max, 0)
	Ly = euclidean_distance(point1, point2)
	Lx = euclidean_distance(point1, point3)
    dx = dy = 100

	# Determine number of grid cells in x and y directions
	nx = Int(ceil(Lx / dx)) + 1
	ny = Int(ceil(Ly / dy)) + 1
	debug(logger, "Lx = $(Lx), Ly = $(Ly)")
	debug(logger, "nx = $(nx), ny = $(ny)")

	# Initialize cell and next node tracking with zeros
	cells = spzeros(Int, nx, ny)
	next = zeros(Int, n_nodes)
    x = []
    y = []
	# Assign nodes to grid cells
	for node in 1:n_nodes
        point_x = LLA(lat_min, lon[node], 0)
        point_y = LLA(lat[node], lon_min, 0)        
        dist_x = euclidean_distance(point_x, point1)
        dist_y = euclidean_distance(point_y, point1)
        push!(x, dist_x)
        push!(y, dist_y)

        i = Int(floor(dist_x / dx)) + 1
        j = Int(floor(dist_y / dy)) + 1
		debug(logger, "node:$(node),  i=$i, j=$j")

		if i > nx || j > ny
			debug(logger, "($i, $j) vs. ($nx, $ny)")
		else
			last = cells[i, j]
			cells[i, j] = node
			next[node] = last
		end
	end

	# Store adjusted positions
	pos = [[x[i], y[i]] for i ∈ 1:n_nodes]

	# Return structured output as a dictionary
	return Dict("coords" => coords,
		"pos" => pos,
		"cellSize" => [dx,  dy],
		"nCells" => [nx,  ny],
		"cells" => cells,
		"next" => next)
end