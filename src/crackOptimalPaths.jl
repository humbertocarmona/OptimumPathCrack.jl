function crackOptimalPaths(g::SimpleDiGraph, org::Int64, dst::Int64,
                           weightmx::SparseMatrixCSC{Float64,Int64};
                           nMaxRem::Integer = 0)


    gr = copy(g)
    N = nv(gr)
    if nMaxRem == 0
        nMaxRem = N
    end
    dij = LightGraphs.dijkstra_shortest_paths(gr, org, weightmx, allpaths=true)

    sv = dij.predecessors[dst]
    havepath = size(sv,1) > 0

    pathmx = spzeros(N,N)
    removedmx = spzeros(N,N)
    nremoved = 0
    while havepath && nremoved < nMaxRem
        # find maximum weight edge ----
        j = dst # first target is the destination
        i = dij.predecessors[j][1]
        if pathmx[i, j] == 0  # keep  the first path intact
             pathmx[i, j] = nremoved + 1
        end

        ir, jr = i,j
        wmax =  weightmx[i,j]
        while i != org
            j = i
            i = dij.predecessors[j][1]
            if pathmx[i, j] == 0
                 pathmx[i, j] = nremoved + 1
            end
            w =  weightmx[i,j]
            if w > wmax
                wmax = w
                ir, jr = i, j
            end
        end # go through this path
        removedmx[ir, jr] = nremoved + 1

        rem_edge!(gr, ir, jr)
        dij = dijkstra_shortest_paths(gr, org, weightmx, allpaths=true) # re-eval Dijkstra
        sv = dij.predecessors[dst]
        havepath = size(sv,1) > 0
        # remove this edge and find new shortest path
        nremoved = nremoved + 1
    end # while havepath
    return nremoved, gr, removedmx, pathmx
end
