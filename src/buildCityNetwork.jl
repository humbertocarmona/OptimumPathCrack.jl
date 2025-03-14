function buildCityNetwork(efile::String, nfile::String)
    es = CSV.read(efile)|>DataFrame
    ns = CSV.read(nfile)|>DataFrame
    g, coords, distmx, weightmx, eidic = buildCityNetwork(es, ns)
    return g, coords, distmx, weightmx, eidic
end


function buildCityNetwork(es::DataFrame, ns::DataFrame)
    coords = collect(zip(ns.lat, ns.lon))


    sort!(es, (:src, :dst), rev=(false, false))
    nes = size(es, 1)  # number od edges
    nns = size(ns, 1)  # number of nodes

    distmx = spzeros(nns, nns)
    weightmx = spzeros(nns, nns)
    g = SimpleDiGraph(nns)

    for i = 1:nes
        s = es.src[i]
        d = es.dst[i]
        l = es.len[i]
        w = es.tt[i]
        if add_edge!(g, s, d)
            distmx[s, d] = l
            weightmx[s, d] = w
        else
            println("problem w/ ($s, $d)")
        end
    end

    # edges are not added in order...
    eidic = Dict()
    gedges = collect(edges(g))
    gedges = [(e.src, e.dst) for e in gedges]
    sg = size(gedges,1)

    for i = 1:sg
        s = es.src[i]
        d = es.dst[i]
        t = (s,d)
        e = findall(x->x==t, gedges)
        eidic[i] = e[1]
        # if t in gedges
        #     eidic[i] = e[1]
        #     println(e)
        # end
    end


    return g, coords, distmx, weightmx, eidic
end
