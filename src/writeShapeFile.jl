function writeShapeFile(g::SimpleDiGraph, 
    coords::Vector{Tuple{Float64,Float64}},
    distance_matrix::SparseArrays.SparseMatrixCSC{Float64,Int64},
    weight_matrix::SparseArrays.SparseMatrixCSC{Float64,Int64};
    removed_edges::SparseArrays.SparseMatrixCSC{Float64,Int64}=spzeros(0,0),
    path_edges::SparseArrays.SparseMatrixCSC{Float64,Int64}=spzeros(0,0),
    orig=0,
    dest=0,
    out_file::String = "reduced",
    out_driver = "GPKG")

    @assert out_driver in ["GPKG", "GeoJSON"]
    println("")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")

    pos = [geom.Point((lon, lat)) for (lat, lon) in coords]
    links = collect(edges(g))

    # edges  ------------------------------------------------------

    dist  = []
    weight  = []
    edges_geometry = []
    edges_path = []
    edges_removed = []
    n_removed = size(findnz(removed_edges)[3],1)
    for e in links
        s = e.src
        d = e.dst
        push!(edges_geometry, geom.LineString([pos[s],pos[d]]))
        push!(weight, weight_matrix[s,d])
        push!(dist, distance_matrix[s,d])
        if n_removed>0
            push!(edges_path, path_edges[s,d])
            push!(edges_removed, removed_edges[s,d])
        end
    end
    push!(edges_geometry, geom.LineString([pos[orig],pos[dest]]))
    push!(weight, 0)
    push!(dist, 0)
    if n_removed>0
        push!(edges_path, 0)
        push!(edges_removed, 0)
    end

    data_edges = Dict("travelTime" => weight, "len"=>dist, "removed"=>edges_removed, "path"=>edges_path)
    gdf_edges = gpd.GeoDataFrame(data=data_edges, geometry=edges_geometry)

    # edges  ------------------------------------------------------
    nodes_geometry = []
    nodes_od = []
    nodes = collect(vertices(g))
    for n in nodes
        push!(nodes_geometry, geom.Point(pos[n]))
        if n == orig
            push!(nodes_od, 1)
        elseif n == dest
                push!(nodes_od, 2)
        else
            push!(nodes_od, 0)
        end
    end

    data_nodes = Dict("od" => nodes_od)
    gdf_nodes = gpd.GeoDataFrame(data=data_nodes, geometry=nodes_geometry)

    

    if out_driver=="GPKG"
        gdf_edges.to_file(out_file*"_edges.gpkg", layer="Edges", driver="GPKG")
        gdf_nodes.to_file(out_file*"_nodes.gpkg", layer="Nodes", driver="GPKG")
        info(logger, "saved $(out_file)_edges.gpkg $(out_file)_nodes.gpkg ")

    else
        gdf_edges.to_file(out_file*"_edges.geojson", driver="GeoJSON")
        gdf_nodes.to_file(out_file*"_nodes.geojson", driver="GeoJSON")
        info(logger, "saved $(out_file)_edges.geojson $(out_file)_nodes.geojson ")
    end
    return out_file
end
