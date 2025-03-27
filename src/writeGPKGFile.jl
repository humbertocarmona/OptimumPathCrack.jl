function writeGPKGFile(
	g::SimpleDiGraph,
	coords::Vector{Tuple{Float64, Float64}},
	distance_matrix::SparseArrays.SparseMatrixCSC{Float64, Int64},
	weight_matrix::SparseArrays.SparseMatrixCSC{Float64, Int64};
	removed_matrix::SparseArrays.SparseMatrixCSC{Float64, Int64} = spzeros(0, 0),
	path_matrix::SparseArrays.SparseMatrixCSC{Float64, Int64} = spzeros(0, 0),
	od = (0, 0),
	filename = "test")
	n_removed = size(findnz(removed_matrix)[3], 1)

	geom_edges = LineString{2, Float32}[]
	dists_edges = Float64[]
	weight_edges = Float64[]
	paths_edges = Int[]
	removed_edges = Int[]

	for e in edges(g)
		s = src(e)
		d = dst(e)

		xy_s = swap(coords[s])
		xy_d = swap(coords[d])

		line = LineString([Point2f(xy_s), Point2f(xy_d)])
		push!(geom_edges, line)
		push!(dists_edges, distance_matrix[s, d])
		push!(weight_edges, weight_matrix[s, d])
		if n_removed > 0
			push!(removed_edges, removed_matrix[s, d])
			push!(paths_edges, path_matrix[s, d])
		end
	end

	geom_nodes = Point2f[]
	od_nodes = String[]
	for n in vertices(g)
		xy = swap(coords[n])
		push!(geom_nodes, Point2f(xy))
		if n == od[1]
			push!(od_nodes, "origin")
		elseif n == od[2]
			push!(od_nodes, "destination")
		else
			push!(od_nodes, "")
		end
	end

	tbl_edges = DataFrame(geometry = geom_edges,
		distance = dists_edges,
		weight = weight_edges,
		paths = paths_edges,
		removed = removed_edges)

	tbl_nodes = DataFrame(geometry = geom_nodes, type = od_nodes)

	edges_file = "$(filename)_edges.gpkg"
	vertices_file = "$(filename)_vertices.gpkg"

	# Shapefile.write(edges_file, tbl_edges,force=true)
	GeoDataFrames.write(
		edges_file,
		tbl_edges;
		driver = "GPKG",
		options = Dict("SPATIAL_INDEX" => "YES"),
	)
	info(logger, "saved $edges_file")
	GeoDataFrames.write(
		vertices_file,
		tbl_nodes;
		driver = "GPKG",
		options = Dict("SPATIAL_INDEX" => "YES"),
	)
	info(logger, "saved $vertices_file")
end
