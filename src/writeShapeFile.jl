function writeShapeFile(g::SimpleDiGraph, coords::Vector{Tuple{Float64,Float64}},
    distmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
    weightmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
    outfile::String = "reduced.gpkg")

    println("")
    gpd = pyimport("geopandas")
    geom = pyimport("shapely.geometry")

    pos = [geom.Point((lon, lat)) for (lat, lon) in coords]
    links = collect(edges(g))

    dist  = []
    weight  = []
    geometry = []
    i=1
    for e in links
        s = e.src
        d = e.dst
        push!(geometry, geom.LineString([pos[s],pos[d]]))
        push!(weight, weightmx[s,d])
        push!(dist, distmx[s,d])
        i = i+1
    end
    data = Dict("tt" => weight, "len"=>dist)
    gdf = gpd.GeoDataFrame(data=data, geometry=geometry)

    println("saving $outfile")

    gdf.to_file(outfile, layer="SimpleDiGraph", driver="GPKG")

    return outfile
end
