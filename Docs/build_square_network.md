# Function Documentation: `buildSquareNetwork`

## Description
`buildSquareNetwork` constructs a square grid network with optional bidirectional edges and periodic boundary conditions. The network consists of `nx` columns and `ny` rows of nodes, with edges assigned weights based on a given probability distribution. Additionally, an origin and destination node can be added to facilitate network-based computations.

## Syntax
```julia
buildSquareNetwork(nx::Int, ny::Int; p::Float64=0.5, dist, seed::Int64=123, od::Bool=true, pbc::Bool=false) -> (g, coords, weightmx, 0)
```

## Parameters
- `nx::Int` : Number of columns in the square grid.
- `ny::Int` : Number of rows in the square grid.
- `p::Float64=0.5` : Probability of creating unidirectional edges instead of bidirectional ones.
- `dist` : Probability distribution used to generate edge weights (e.g., a `DisorderDist` or any distribution from the `Distributions` package).
- `seed::Int64=123` : Random seed for reproducibility.
- `od::Bool=true` : If `true`, adds an origin node at the leftmost column and a destination node at the rightmost column.
- `pbc::Bool=false` : If `true`, applies periodic boundary conditions by connecting the last column to the first column.

## Returns
A tuple containing:
1. `g`: A directed graph (`SimpleDiGraph`) representing the network.
2. `coords`: A list of tuples representing the coordinates of each node.
3. `weightmx`: A sparse matrix (`spzeros`) storing the weights of the edges.
4. `0`: A placeholder value.

## Grid Layout and Edge Connections
The function constructs a grid with the following layout:
```
31---32---33---34---35---36      6
 |    |    |    |    |    |
25---26---27---28---29---30      5
 |    |    |    |    |    |
19---20---21---22---23---24      4
 |    |    |    |    |    |
13---14---15---16---17---18      3
 |    |    |    |    |    |
 7----8----9---10---11---12      2
 |    |    |    |    |    |
 1----2----3----4----5----6      1
                                ||
I=1    2    3    4    5    6      J
```

## Edge Generation
- Each node is connected to its right and upper neighbors (unless it is at the rightmost or top row, respectively).
- With probability `p`, an edge is unidirectional (randomly assigned direction), otherwise, it is bidirectional.
- If `pbc=true`, the rightmost column is connected to the leftmost column to enforce periodic boundary conditions.
- If `od=true`, two additional nodes are added:
  - An **origin node** that connects to all nodes in the leftmost column.
  - A **destination node** that receives connections from all nodes in the rightmost column.

## Example Usage
```julia
using Random, LightGraphs, SparseArrays, Distributions

dist = Normal(0.5, 0.1) # Define weight distribution
network, coords, weights, _ = buildSquareNetwork(6, 6; p=0.7, dist=dist, seed=42, od=true, pbc=true)
```

## Notes
- The function ensures deterministic results by setting the random seed (`Random.seed!(seed)`).
- If `dist` is a `Float64`, it is internally converted to a `DisorderDist`.
- The adjacency structure of the graph is managed using a `SimpleDiGraph` from `LightGraphs.jl`.
- The function supports various probability distributions for edge weights, making it flexible for different applications.
