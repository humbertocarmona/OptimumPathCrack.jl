"""
	crackOptimalPaths(g::SimpleDiGraph, org::Int64, dst::Int64,
					  weight_matrix::SparseMatrixCSC{Float64, Int64};
					  nMaxRem::Int64 = 0)

Finds and removes the highest-weight edges along shortest paths from `org` to `dst` 
until no path exists or the maximum allowed removals (`nMaxRem`) is reached.

# Arguments
- `g::SimpleDiGraph`: The input directed graph.
- `org::Int64`: The origin node.
- `dst::Int64`: The destination node.
- `weight_matrix::SparseMatrixCSC{Float64, Int64}`: A sparse matrix representing edge weights.
- `nMaxRem::Int64` (optional): The maximum number of edges to remove. Defaults to `N`, the number of nodes.

# Returns
- `n_removed::Int64`: The number of edges removed.
- `removed_mx::SparseMatrixCSC{Int64, Int64}`: A matrix tracking which edges were removed and in what order.
- `path_mx::SparseMatrixCSC{Int64, Int64}`: A matrix recording the sequence of paths before edges were removed.

# Description
The function iteratively computes shortest paths from `org` to `dst` using Dijkstra's algorithm. 
At each step, it identifies and removes the edge with the maximum weight along the current shortest path. 
This process repeats until no path remains or the limit `nMaxRem` is reached.
"""
function crackOptimalPaths(g::SimpleDiGraph, org::Int64, dst::Int64,
	weight_matrix::SparseMatrixCSC{Float64, Int64};
	nMaxRem::Int64 = 0)

	# Make a copy of the graph to modify during edge removals
	gr = copy(g)
	N = nv(gr)  # Number of nodes

	# If no maximum removal count is specified, allow up to n_edges removals
	if nMaxRem == 0
		nMaxRem = ne(gr)
	end

	# Compute initial shortest paths from origin using Dijkstra's algorithm
	dijkstra_state = LightGraphs.dijkstra_shortest_paths(
		gr,
		org,
		distmx = weight_matrix,
		allpaths = true,
	)

	# Check if there exists a path from `org` to `dst`
	predecessors = dijkstra_state.predecessors[dst]
	have_path = size(predecessors, 1) > 0

	# Initialize matrices to track paths and removed edges
	path_mx = spzeros(N, N)    # Stores the sequence of paths
	removed_mx = spzeros(N, N) # Tracks removed edges
	n_removed = 0              # Counter for removed edges

	# Continue removing edges while a path exists and removal limit is not exceeded
	while have_path && n_removed < nMaxRem
		# Identify the maximum weight edge in the current shortest path
		j = dst  # Start at the destination node
		i = dijkstra_state.predecessors[j][1]  # Move backward along the shortest path

		# Record the first discovered path in `path_mx`
		if path_mx[i, j] == 0
			path_mx[i, j] = n_removed + 1
		end

		# Variables to track the heaviest edge along the path
		imax, jmax = i, j
		maximum_weight = weight_matrix[i, j]

		# Traverse the path backwards to find the edge with the highest weight
		while i != org
			j = i
			i = dijkstra_state.predecessors[j][1]

			# Record the path
			if path_mx[i, j] == 0
				path_mx[i, j] = n_removed + 1
			end

			# Update the maximum weight edge if a heavier one is found
			w = weight_matrix[i, j]
			if w > maximum_weight
				maximum_weight = w
				imax, jmax = i, j
			end
		end

		# Remove the identified heaviest edge from the graph
		removed_mx[imax, jmax] = n_removed + 1
		rem_edge!(gr, imax, jmax)

		# Recompute shortest paths after edge removal
		dijkstra_state = dijkstra_shortest_paths(gr, org, weight_matrix, allpaths = true)

		# Check if a path from `org` to `dst` still exists
		predecessors = dijkstra_state.predecessors[dst]
		have_path = size(predecessors, 1) > 0

		# Increment removal counter
		n_removed += 1
	end

	# Return the number of removed edges, removed edges matrix, and path matrix
	return n_removed, removed_mx, path_mx
end
