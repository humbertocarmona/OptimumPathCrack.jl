"""
	Generates an origin-destination (OD) matrix by selecting random origins and destinations
	within a given distance constraint.

	# Arguments
	- `ℓ::Float64`: Desired travel distance between origins and destinations.
	- `cell_list::Dict{String,Any}`: Dictionary containing spatial grid and positional information.
	
	# Keyword Arguments
	- `seed::Int64=11`: Random seed for reproducibility.
	- `n_od_pairs::Int64=10`: Number of OD pairs to generate.
	- `δ::Float64=0.01`: Allowable deviation from the target distance.
	
	# Returns
	- `Vector{Tuple{Int64, Int64}}`: A list of OD pairs as tuples of node indices.
"""
function create_ODs(
	ℓ::Float64,
	cell_list::Dict{String, AbstractArray};
	seed::Int64 = 1,
	n_od_pairs::Int64 = 10,
	δ::Float64 = 0.01) :: Vector{Tuple{Int64, Int64}}
	Random.seed!(seed) # Set random seed for reproducibility

	δ = δ * ℓ #  maximum allowed error based on the distance scale
	iℓ = Int(floor(ℓ / 100)) # Convert distance to integer cell scale

	# Extract relevant spatial data from the dictionary
	pos = cell_list["pos"]
	coords = cell_list["coords"]

	cellSize = cell_list["cellSize"] # [dx, dy]
	n_cells = cell_list["nCells"]# [nx, ny]

	cells = cell_list["cells"]
	next = cell_list["next"]

	n_nodes = size(pos, 1)

	OD_vector = [] # List to store OD pairs

	n_orig = 0# Counter to prevent infinite loops

	max_cell_tries = 100
	n = 0# Counter for successful OD pairs
	while n < n_od_pairs && n_orig < 100*n_nodes
		# select one origin
		origin_idx = Random.rand(collect(1:n_nodes)) # Select a random origin node

		lat, lon = coords[origin_idx][1], coords[origin_idx][2]
		origin_coord = LLA(lat, lon, 0.0) # Convert to geographic coordinates

		# Determine the grid cell of the origin point
		cell_origin = Int.(floor.(pos[origin_idx] ./ cellSize .+ 1))

		n_cell_tries = 0 # Counter for attempts to find a valid destination cell

		# Search for a non-empty destination cell within the allowed distance
		foundCell= false
		dst_cell = [0,0]
		while !foundCell && n_cell_tries < max_cell_tries
			ϕ = 2π * Random.rand() # Select a random angle
			# ϕ = Random.rand([0.0, 0.5π, π, 1.5π]) # Restrict to 90-degree angles

			cell_index_trial = [iℓ * cos(ϕ), iℓ * sin(ϕ)] # Compute displacement vector
			cell_index_dest = cell_origin + cell_index_trial # Compute new cell location
			dst_cell = Int.(floor.(cell_index_dest))

			foundCell = all(0 < dst_cell[i] <= n_cells[i] for i in 1:2)
			foundCell = foundCell && (cells[dst_cell[1], dst_cell[2]] > 0) # Ensure the cell is occupied
			n_cell_tries += 1
		end

		if foundCell  # Proceed if a valid destination cell is found
			i,j = dst_cell
			dest_idx = cells[i,j] # Get the index of the last node in the cell
			found_dst = false
			while !found_dst && dest_idx > 0  # Iterate over nodes in the destination cell
				lat, lon = coords[dest_idx]
				dest_coord = LLA(lat, lon, 0.0) # Convert to geographic coordinates
				dist = euclidean_distance(origin_coord, dest_coord) # Compute distance to origin

				# Check distance condition and that this pair od is not in the matrix
				found_dst = (abs(dist - ℓ) < δ) && ((origin_idx, dest_idx) ∉ OD_vector)
				if found_dst
					n += 1
					debug(logger, "$(n) ($(origin_idx), $(dest_idx)), distance = $dist")
					push!(OD_vector, (origin_idx, dest_idx)) # Store valid OD pair
					if n ≥ n_od_pairs
						break
					end
				end
				dest_idx = next[dest_idx]  # Move to next node in the cell
			end
		end

		n_orig += 1
	end
	return OD_vector
end
