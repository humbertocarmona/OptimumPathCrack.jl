using OptimumPathCrack
using Test
using Test, CSV, DataFrames, Graphs, SparseArrays
using Random, Distributions

function test_buildCityNetwork()
	# Create temporary CSV files for testing
	edges_file = "data/edges.csv"
	nodes_file = "data/nodes.csv"

	# Run the function with test data
	g, coords, distance_matrix, weight_matrix, edges_index_dict =
		buildCityNetwork(edges_file, nodes_file)
	display(weight_matrix)

	# Perform assertions
	@test nv(g) == 28        # Ensure nodes are added
	@test ne(g) == 20        # Ensure edges are added
	@test length(coords) == nv(g)  # Ensure coordinates match node count
	@test size(distance_matrix) == (nv(g), nv(g))  # Ensure distance matrix size is correct
	@test size(weight_matrix) == (nv(g), nv(g))    # Ensure weight matrix size is correct
	@test length(edges_index_dict) == ne(g)  # Ensure edges index dictionary is correct

	println("All tests passed!")
end

function test_buildSquareNetwork()
	nx, ny = 5, 5  # Define grid size
	dist = Normal(0.5, 0.1)  # Define weight distribution
	seed = 42
	od, pbc = true, false

	# Run the function
	g, coords, weightmx, placeholder =
		buildSquareNetwork(nx, ny; dist = dist, seed = seed, od = od, pbc = pbc)

	# Perform assertions
	@test nv(g) == nx * ny + 2 * od  # Check total nodes including origin/destination
	@test ne(g) > 0  # Ensure edges are added
	@test length(coords) == nv(g)  # Ensure coordinates match node count
	@test size(weightmx) == (nv(g), nv(g))  # Check weight matrix size
	@test placeholder == 0  # Ensure placeholder return value is correct

	println("All tests passed for buildSquareNetwork!")
end

function test_cellList()
    # Define test coordinates
    coords = [(-3.7000,-38.6000),
			  (-3.7001,-38.6000), 
			  (-3.7020,-38.6000), 
			  (-3.7021,-38.6000), 
			  (-3.7040,-38.6000), 
			  (-3.7041,-38.6000), 
			  (-3.7060,-38.6000), 
			  (-3.7061,-38.6000), 
			  (-3.7000,-38.6010),
			  (-3.7000,-38.6030),
			  (-3.7000,-38.6040)]
    cellWidth = 100.0  # Cell width in meters
    
    # Run the function
    result = cellList_euclidean(coords; cellWidth=cellWidth)
    
	display(result["cells"])
	display(result["next"])
	display(result["pos"])

    # Extract values from the result dictionary
    dx, dy = result["dx"], result["dy"]
    nx, ny = result["nx"], result["ny"]
    cells, next = result["cells"], result["next"]
    
    # Perform assertions
    @test length(result["coords"]) == length(coords)  # Ensure coords are stored properly
    @test nx > 0 && ny > 0  # Grid dimensions must be positive
    @test size(cells) == (nx, ny)  # Ensure cell matrix matches grid size
    @test size(next) == (length(coords),)  # Ensure next array has the correct size
    
    
    println("All tests passed for cellList!")
end

function test_OD_matrix()
	edges_file = "data/boston-edges-4h.csv"
	nodes_file = "data/boston-nodes.csv"
	g, coords, distance_matrix, weight_matrix, edges_index_dict =
	buildCityNetwork(edges_file, nodes_file)
	cell_list = cellList_lat_lon(coords; cellWidth=100.0)
	println(typeof(cell_list))
	n_od_pairs=1000
    OD = OD_matrix(1000.0, cell_list, n_od_pairs=n_od_pairs)

    @test size(OD,1) == n_od_pairs  # Ensure coords are stored properly


end

@testset "cellList Tests" begin
    test_OD_matrix()
end

# @testset "cellList Tests" begin
#     test_cellList()
# end

# @testset "buildSquareNetwork Tests" begin
#     test_buildSquareNetwork()
# end

# @testset "buildCityNetwork Tests" begin
#     test_buildCityNetwork()
# end
