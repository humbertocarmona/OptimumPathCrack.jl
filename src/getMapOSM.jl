function getMapOSM(;place::String="",
                    location::Tuple{Float64,Float64}=(-3.7327, -38.5270),
                    radius::Float64=500.0,
                    nfile::String="data/nodes.csv",
                    efile::String="data/edges.csv",
                    city::String="",
                    )

    """
        download map from Open Street Map using python osmnx
        require python:
            osmnx, networkx
        arguments:
            place = string description of the place
            location =  tuple (lat, lon) centre of download area (if not place)
            radius = radius of the download area (meters)
            nfile, efile =  output files for nodes and edges
            city =  name of the city for saving shapefile
        examples:
        G = OPC.getMapOSM(place="San Francisco, California, USA",
                          nfile="data/sanfrancisco_nodes.csv",
                          efile="data/sanfrancisco_edges.csv",
                          city = "sanfrancisco")
        or
        G = OPC.getMapOSM(location=(-3.7327, -38.5270),
                          radius=15000.0,
                          nfile"data/fortaleza_nodes.csv",
                          efile"data/fortaleza_edges.csv",
                          city::String="fortaleza")
    """

    ox = pyimport("osmnx")
    nx = pyimport("networkx")

    if length(place) == 0
        G = ox.graph_from_point(location, distance=radius,
                                network_type="drive", simplify=true)
    else
        G = ox.graph_from_place(place,
                                network_type="drive", simplify=true)
    end

    println("")
    println("number of nodes = ", G.number_of_nodes())
    println("number of edges = ", G.number_of_edges())
    println("is directed = ", G.is_directed())
    x = nx.get_node_attributes(G, "x")
    y = nx.get_node_attributes(G, "y")
    idx = []
    lat = []
    lon = []
    nidx = []
    nodedic = Dict()
    for (i, node) in enumerate(G.nodes())
        push!(idx,i)
        push!(nidx, node)
        push!(lon, x[node])
        push!(lat, y[node])
        nodedic[node] = i
    end

    dfn = DataFrame(idx=idx, nidx=nidx, lat=lat, lon=lon)
    CSV.write(nfile, dfn)

    L = nx.get_edge_attributes(G, "length")
    uniqueedges = []
    for e in G.edges()
        s,d = e
        push!(uniqueedges, (s,d))
    end
    uniqueedges = unique(uniqueedges)


    edgelength = []
    src = []
    dst = []
    for e in uniqueedges
        s,d = e
        et = (s,d,0)
        push!(edgelength, L[et])
        push!(src, nodedic[s])
        push!(dst, nodedic[d])
    end
    #src,dst,length

    dfe = DataFrame(src=src, dst=dst, length=edgelength)
    CSV.write(efile, dfe)

    if length(city) > 0
        ox.save_graph_shapefile(G, filename=city, folder="data/")
    end
    return dfe, dfn
end
