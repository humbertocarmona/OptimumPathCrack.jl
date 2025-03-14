function odMatrix(ℓ::Float64,
                    celllist::Dict{String,Any};
                    seed::Int64 = 11,
                    ns::Int64 = 10,
                    nDstOrg::Int64 = 1,
                    square::Bool = false,
                    δ::Float64 = 0.01
                )

    δ = δ * ℓ # maximum error
    Random.seed!(seed)

    iℓ = Int(floor(ℓ / 100))

    pos = celllist["pos"]
    coords = celllist["coords"]

    nnodes = size(pos, 1)
    dx = celllist["dx"]
    dy = celllist["dy"]
    nx = celllist["nx"]
    ny = celllist["ny"]
    cells = celllist["cells"]
    next = celllist["next"]

    odMatrix = []
    n = 0
    maxorig = 0
    while n < ns && maxorig < 100*nnodes
        o = Random.rand(collect(1:nnodes))
        orig = LLA(coords[o][1], coords[o][2], 0.0)

        pO = pos[o]
        cx = Int(floor(pO[1] / dx))+1
        cy = Int(floor(pO[2] / dy)+1)
        cO = [cx, cy]

        i0,j0 = n2ij(o, nx)
        for k = 1:nDstOrg
            #find a nonempty cell, size dx x dy within ℓ, random angle
            ncelltries = 0
            cx, cy = 0, 0
            while ncelltries < 100
                foundCell = false
                trynonempy = 0
                while !foundCell && trynonempy < 1
                    ϕ = 2π * Random.rand()
                    if square
                        ϕ = Random.rand([0.0, 0.5π, π, 1.5π])
                    end
                    rϕ = [iℓ * cos(ϕ), iℓ * sin(ϕ)]
                    cCell = cO + rϕ
                    cx, cy = Int(floor(cCell[1])), Int(floor(cCell[2]))
                    if (0 < cx < nx) && (0 < cy < ny)
                        foundCell = (cells[cx,cy] > 0)
                    end
                    trynonempy = trynonempy + 1
                end
                if foundCell  # because trynonempy
                    # find a destination at distance ℓ ± dx
                    d = cells[cx, cy]
                    foundDst = false
                    while !foundDst && d > 0  # limited by the nodes in cell
                        dest = LLA(coords[d][1], coords[d][2], 0.0)
                        dist = Geodesy.distance(orig, dest)
                        i,j = n2ij(d, nx)
                        foundDst = (abs(dist - ℓ) < δ) && ((o, d) ∉ odMatrix)
                        if foundDst
                            @debug("$(n+1) ($i0, $j0) - ($i, $j) distance = $dist")
                            if !((o,d) in odMatrix)
                                push!(odMatrix, (o, d))
                                n = n + 1
                                if n ≥ ns
                                    break
                                end
                            end
                        end
                        d = next[d]  # next node in cell
                    end
                    # if !foundDst
                    #     println("\tno destination in this cell within range")
                    # end
                    if n ≥ ns
                        break
                    end
                end
                ncelltries = ncelltries + 1
            end
            if n ≥ ns
                break
            end
        end

        maxorig = maxorig + 1
    end
    return odMatrix
end
