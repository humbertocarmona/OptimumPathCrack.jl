function getTravelTimes(g::SimpleDiGraph,
                        coords::Vector{Tuple{Float64,Float64}},
                        key::String)
    """
        gets travel times for all edges using google directions api
        coods = vector of (lon, lat)
        g =  simple directed graph created by edgeList2simpleGraph
    """

    departure = DateTime(2023,9,28,4,0,0)  # thursdays 4 am (future=eman time)
    departure = Dates.value(departure)
    nedges = ne(g)
    nnodes = nv(g)
    travelTimes = zeros(nedges)

    i = 1
    datadic = Dict()
    outputdic = Dict()
    travelTimes = Dict()
    # TODO ... garantir que salva mesmo que interromper....s
    for edge in edges(g)
        if mod(i, 100) == 0
            println(i)
        end
        s, d = edge.src, edge.dst
        origin = coords[s]
        destination = coords[d]
        datajson, output = OPC.getGoogleDirection(origin, destination, departure, key)
        travelTimes[(s,d)] = output["travelTimeSec"]

        datadic[(s,d)] = datajson
        outputdic[(s,d)] = output
        if i==10
            break
        end
        i = i + 1
    end
    return datadic, outputdic, travelTimes
end
