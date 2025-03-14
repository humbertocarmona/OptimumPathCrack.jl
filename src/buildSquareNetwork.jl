function ij2n(i,j, nx)
    return i+nx*(j-1)
end

function n2ij(n, nx)
    j = (n-1)÷nx
    i = n-nx*j
    return i,j+1
end

function buildSquareNetwork(nx::Int, ny::Int; p::Float64=0.5,
                            dist, seed::Int64 = 123,
                            od::Bool = true,
                            pbc::Bool = false)
    """
        nx, ny: network size
        p: probability of bidirect edges
        dist: distribution to generate weights - DesorderDist is defined here,
              but it can be anyone defined in Distributions

        add one abobe the top row and one below to the bottom row

        add edges
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
    """

    if isa(dist,Float64)
        dist = DisorderDist(dist)
    end

    Random.seed!(seed)
    nvertices = nx*ny
    nnodes = nvertices
    if od
        nnodes = nvertices + 2 # last 2 are origin-destination
    end
    g = SimpleDiGraph(nnodes)
    weightmx = spzeros(nnodes,nnodes)

    en = 0
    center = [-3.7327, -38.5270]
    dx = 9.043317e-4
    dy = 9.002123e-4
    coords =  Tuple{Float64, Float64}[]
    # interior
    for i in 1:nx
        for j in 1:ny
            pos = center + [(i-1)*dx, (j-1)*dy]
            push!(coords, Tuple(pos))
            s=ij2n(i,j, nx)

            #add horizontal
            if i<nx
                d=ij2n(i+1,j, nx)
                unidirected = p > rand()    # bidirected edge?
                if unidirected
                    right = rand()>0.5 # choose direction
                    if right
                        ϵ = rand(dist)
                        add_edge!(g, s,d)
                        weightmx[s,d] = ϵ
                        en+=1
                    else
                        ϵ = rand(dist)
                        add_edge!(g, d,s)
                        weightmx[d,s] = ϵ
                        en+=1
                    end
                else # add bi-directed
                    ϵ = rand(dist)
                    add_edge!(g, s,d)
                    weightmx[s,d] = ϵ

                    ϵ = rand(dist)
                    add_edge!(g, d,s)
                    weightmx[d,s] = ϵ
                    en+=1
                end
            elseif pbc
                d = ij2n(1,j, nx)
                unidirected = p > rand()    # bidirected edge?
                if unidirected
                    right = rand()>0.5 # choose direction
                    if right
                        ϵ = rand(dist)
                        add_edge!(g, s,d)
                        weightmx[s,d] = ϵ
                        en+=1
                    else
                        ϵ = rand(dist)
                        add_edge!(g, d,s)
                        weightmx[d,s] = ϵ
                        en+=1
                    end
                else # add bi-directed
                    ϵ = rand(dist)
                    add_edge!(g, s,d)
                    weightmx[s,d] = ϵ

                    ϵ = rand(dist)
                    add_edge!(g, d,s)
                    weightmx[d,s] = ϵ
                    en+=1
                end
            end

            #add vertical
            if j<ny
                d=ij2n(i,j+1, nx)
                unidirected = p > rand()    # bidirected edge?
                if unidirected
                    up = rand()>0.5 # choose direction
                    if up
                        ϵ = rand(dist)
                        add_edge!(g, s,d)
                        weightmx[s,d] = ϵ
                        en+=1
                    else
                        ϵ = rand(dist)
                        add_edge!(g, d,s)
                        weightmx[d,s] = ϵ
                    end
                    else # add bi-directed - each direction has a different weight
                    ϵ = rand(dist)
                    add_edge!(g, s,d)
                    weightmx[s,d] = ϵ

                    ϵ = rand(dist)
                    add_edge!(g, d,s)
                    weightmx[d,s] = ϵ
                end
            end
        end
    end

    if od # connects origin and destination
        org = nvertices+1
        dst = nvertices+2
        for j=1:ny  #left column
            d = ij2n(1,j, nx)
            add_edge!(g, org, d)
            weightmx[org,d] = 0.0
        end


        for j=1:ny #right column
            s = ij2n(nx, j, nx)
            add_edge!(g, s, dst)
            weightmx[s,dst] = 0.0
        end
        push!(coords, Tuple(center+[0.5*(nx-1.0)*dx, -1.0*dy]))
        push!(coords, Tuple(center+[0.5*(nx-1.0)*dx, (ny+1.0)*dy]))
    end

    return g, coords, weightmx, 0
end
