function graph_to_shp(g::SimpleGraph,
	edge_props_km::AbstractArray,
    edge_props_vol::AbstractArray,
	edge_props_jur::AbstractArray,
	node_props_lat_lon::AbstractArray,
	node_props_ibge::AbstractArray; filename="test")


    num_edges = ne(g)
    num_vertices = nv(g)

    geom_edges = LineString{2,Float64}[]
    dists_edges = Float64[]
    volume_edges = Float64[]
    jur_edges = Int[]
    for e in edges(g)
        s = src(e)
        d = dst(e)
        lon_lat_s = swap(node_props_lat_lon[s])
        lon_lat_d = swap(node_props_lat_lon[d])

        point_s = Point2(lon_lat_s...)
        point_d = Point2(lon_lat_d...)

        push!(geom_edges, LineString([point_s, point_d]))
        push!(dists_edges, edge_props_km[s,d])
        push!(jur_edges, edge_props_jur[s,d])
        push!(volume_edges, edge_props_vol[s,d])
        
    end

    geom_nodes = Point{2,Float64}[]
    for n in vertices(g)
        lon_lat = swap(node_props_lat_lon[n])
        push!(geom_nodes, Point2(lon_lat))
    end

    tbl_edges = DataFrame(geometry=geom_edges, jur=jur_edges, distance=dists_edges, volume=volume_edges)

    tbl_nodes = DataFrame(geometry=geom_nodes,  IBGE=node_props_ibge)



    edges_file = "$(filename)_edges.shp"
    vertices_file = "$(filename)_vertices.shp"

    Shapefile.write(edges_file, tbl_edges,force=true)
    info(LOGGER, "saved $edges_file")
    Shapefile.write(vertices_file, tbl_nodes,force=true)
    info(LOGGER, "saved $vertices_file")




    
end
