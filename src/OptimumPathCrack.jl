__precompile__()
module OptimumPathCrack

using DataFrames
using CSV
using Graphs
using SparseArrays
using PyCall
using HTTP
using JSON
using Dates
using Random
using Statistics
using Distributions
using LinearAlgebra
using Geodesy
using Memento
import Random:rand


const logger = getlogger(@__MODULE__)
function __init__()
    Memento.config!("debug"; fmt="{level}: {msg}")
    # time_now = Dates.format(Dates.now(), "yy-mm-dd_HH_MM")
    # log_file = "opc_$(time_now).log"
    # hndlr = DefaultHandler(
    #     log_file,
    #     DefaultFormatter("{level}: {msg}")
    #     #DictFormatter(JSON3.write)
    # )
    # push!(LOGGER, hndlr)
    
    setlevel!(logger, "debug")
    Memento.register(logger)
end


include("getGoogleDirection.jl")
include("getTravelTimes.jl")
include("getMapOSM.jl")
include("buildCityNetwork.jl")
include("buildSquareNetwork.jl")
include("cellList.jl")
include("odMatrix.jl")
include("crackOptimalPaths.jl")
include("writeShapeFile.jl")
include("writeGML.jl")
include("DisorderDist.jl")


export DisorderDist, rand, buildCityNetwork, buildSquareNetwork,
cellList, crackOptimalPaths, getGoogleDirection, getMapOSM, getTravelTimes,
odMatrix, writeGML, writeShapeFile


end
