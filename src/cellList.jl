function cellList(coords::Vector{Tuple{Float64,Float64}};
                  cellWidth::Float64 = 100.0)
    """
        builds cell list for finding (origin, destination) within
        a given distance

        use (lat,lon) to build the square lattice...

    """

    #  100 meters
    dx = 9.043317e-4*cellWidth/100.0
    dy = 9.002123e-4*cellWidth/100.0

    n = size(coords,1)
    lat = [coords[i][1] for i=1:n]
    lon = [coords[i][2] for i=1:n]
    Lx = maximum(lon) - minimum(lon)
    Ly = maximum(lat) - minimum(lat)
    x = lon .-  minimum(lon)
    y = lat .-  minimum(lat)

    nx = Int(ceil(Lx/dx))+1
    ny = Int(ceil(Ly/dx))+1
    #@debug("agora $nx, $ny")

    cells = spzeros(Int, nx, ny)
    next = spzeros(Int, n)
    for node in 1:n
        i = Int(floor(x[node]/dx))+1
        j = Int(floor(y[node]/dy))+1
        if i > nx || j > ny
            println("($i, $j) vs. ($nx, $ny)")
        end
        last = cells[i,j]
        cells[i,j] = node
        next[n] = last
    end


    pos = [[x[i], y[i]] for i = 1:n]

    result = Dict("coords"=> coords,
                  "pos"=> pos,
                  "dx"=> dx, "dy"=>dy,
                  "nx"=> nx,"ny"=> ny,
                  "cells"=>cells,
                  "next"=>next)
end
