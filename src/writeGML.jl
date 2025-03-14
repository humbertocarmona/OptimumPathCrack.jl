function writeGML(g::SimpleDiGraph,
               coords::Vector{Tuple{Float64,Float64}},
               weightmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
               distmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
               remmx::SparseArrays.SparseMatrixCSC{Float64,Int64},
               outfile::String = "reduced.gml")

    nnodes = nv(g)
    links = collect(edges(g))

    s = open(outfile, "w") do file
        write(file,"graph\n")
        write(file,"[\n")
        write(file,"  Creator \"Gephi\"\n")
        write(file,"  directed 1\n")
        for i in 1:nv(g)
            x = coord[i][2]
            y = coord[i][1]
            write(file,"  node\n")
            write(file,"  [\n")
            write(file,"    id $(i-1)\n")
            write(file,"    label \"$(i-1)\"\n")
            write(file,"    graphics\n")
            write(file,"    [\n")
            write(file,"      x $x\n")
            write(file,"      y $y\n")
            write(file,"      z 0.0\n")
            write(file,"      w 10.0\n")
            write(file,"      h 10.0\n")
            write(file,"      d 10.0\n")
            write(file,"      c 1,0\n")
            write(file,"    ]\n")
            write(file,"  ]\n")
        end

        n = 0
        for e in links
            s = e.src
            d = e.dst
            w = weightmx[s,d]
            d = distmx[s,d]
            r = remmx[s,d]
            write(file,"  edge\n")
            write(file,"  [\n")
            write(file,"    id $n\n")
            write(file,"    source $(s-1)\n")
            write(file,"    target $(d-1)\n")
            write(file,"    weight $w\n")
            write(file,"    l $d\n")
            write(file,"    nr $r\n")
            write(file,"  ]\n")
            n+=1
        end

        write(file,"]")
    end
    filename
end
