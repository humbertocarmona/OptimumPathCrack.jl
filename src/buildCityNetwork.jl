"""
	Constructs a directed city network graph from edge and node data stored in CSV files.

	# Arguments
	- `edges_file::String`: Path to the CSV file containing edge information.
	- `nodes_file::String`: Path to the CSV file containing node information.

	# Returns
	A tuple `(g, coords, distance_matrix, weight_matrix, edges_index_dict)`:
	- `g::SimpleDiGraph`: Directed graph representing the city network.
	- `coords::Vector{Tuple{Float64, Float64}}`: List of node coordinates.
	- `distance_matrix::SparseMatrixCSC{Float64, Int}`: Sparse matrix storing edge distances.
	- `weight_matrix::SparseMatrixCSC{Float64, Int}`: Sparse matrix storing edge weights.
	- `edges_index_dict::Dict{Int, Tuple{Int, Int}}`: Mapping from `edges_df` to graph edges.

	# Notes
	- The function reads CSV files using `CSV.read` and converts them into DataFrames.
	- It internally calls `buildCityNetwork(edges_df::DataFrame, nodes_df::DataFrame)` to process the data.
"""
function buildCityNetwork(edges_file::String, nodes_file::String)
	# Read CSV files into DataFrames
	edges_df = CSV.read(edges_file, DataFrame)
	nodes_df = CSV.read(nodes_file, DataFrame)

	# Construct the city network using the DataFrame version of the function
	g, coords, distance_matrix, weight_matrix, edges_index_dict =
		buildCityNetwork(edges_df, nodes_df)

	return g, coords, distance_matrix, weight_matrix, edges_index_dict
end

"""
	buildCityNetwork(edges_df::DataFrame, nodes_df::DataFrame)

	Constructs a directed city network graph from given edge and node data.

	# Arguments
	- `edges_df::DataFrame`: A dataframe containing edge information. It must include:
	- `"src"`: Source node index.
	- `"dst"`: Destination node index.
	- `"length"`: Distance between nodes.
	- `"travelTime"` (optional): If present, weights edges based on travel time.
	- `nodes_df::DataFrame`: A dataframe containing node information. It must include:
	- `"lat"`: Latitude coordinate of each node.
	- `"lon"`: Longitude coordinate of each node.

	# Returns
	A tuple containing:
	1. `g::SimpleDiGraph`: A directed graph representing the city network.
	2. `coords::Vector{Tuple{Float64, Float64}}`: List of node coordinates as `(latitude, longitude)`.
	3. `distance_matrix::SparseMatrixCSC{Float64, Int}`: A sparse matrix representing edge distances.
	4. `weight_matrix::SparseMatrixCSC{Float64, Int}`: A sparse matrix representing edge weights.
	5. `edges_index_dict::Dict{Int, Tuple{Int, Int}}`: A dictionary mapping edges from `edges_df` to graph edges.

	# Notes
	- The function sorts `edges_df` to ensure consistency.
	- If `"travelTime"` is missing, edges are assigned a default weight of `1`.
	- Edges are added in the order of `edges_df`, but their indices may change in `g`, requiring `edges_index_dict` for reference.
	- If an edge addition fails, a warning is printed.

"""
function buildCityNetwork(edges_df::DataFrame, nodes_df::DataFrame)

	# Ensure required columns are present in edges_df
	@assert "src" in names(edges_df) "edges need 'src' column"
	@assert "dst" in names(edges_df) "edges need 'dst' column"
	@assert "length" in names(edges_df) "edges need 'length' column"

	# Extract node coordinates as tuples (lat, lon)
	coords = collect(zip(nodes_df.lat, nodes_df.lon))

	# Sort edges by source and destination for consistency
	#sort!(edges_df, (:src, :dst), rev = (false, false))
	sort!(edges_df, [order(:src, rev=true), order(:dst, rev=true)])

	# Define the number of edges and nodes
	n_edges = size(edges_df, 1)  # Number of edges
	n_nodes = size(nodes_df, 1)  # Number of nodes

	# Initialize sparse matrices for distance and weight storage
	distance_matrix = spzeros(n_nodes, n_nodes)
	weight_matrix = spzeros(n_nodes, n_nodes)

	# Determine if weights are based on travel time
	weighted = ("travelTime" in names(edges_df))

	# Create a directed graph with n_nodes nodes
	g = SimpleDiGraph(n_nodes)

	# Add edges to the graph
	for i ∈ 1:n_edges
		s = edges_df[!, "src"][i]  # Source node
		d = edges_df[!, "dst"][i]  # Destination node
		l = edges_df[!, "length"][i]  # Edge length

		# Assign weight based on travel time if available, otherwise default to 1
		if weighted
			w = edges_df[!, "travelTime"][i]
		else
			w = 1
		end

		# Attempt to add the edge; if successful, update matrices
		if add_edge!(g, s, d)
			distance_matrix[s, d] = l
			weight_matrix[s, d] = w
		else
			println("Problem with edge ($s, $d)")
		end
	end

	# Create a mapping from original edge indices to graph edges
	edges_index_dict = Dict()
	g_edges = collect(edges(g))
	g_edges = [(e.src, e.dst) for e in g_edges]  # Convert edges to tuple format
	# n_edges = size(g_edges, 1)
	n_edges= ne(g)

	for i ∈ 1:n_edges
		s = edges_df.src[i]
		d = edges_df.dst[i]
		t = (s, d)
		e = findall(x -> x == t, g_edges)  # Locate edge index
		edges_index_dict[i] = e[1]
	end

	# Return the graph, node coordinates, matrices, and edge mapping
	return g, coords, distance_matrix, weight_matrix, edges_index_dict
end
