__precompile__()
module OptimumPathCrack

using CSV
using DataFrames
using Dates
using Distributions
using Geodesy
using Graphs
using HTTP
using JSON
using LinearAlgebra
using Memento
using PyCall
using Random
using SparseArrays
using Statistics
import Random: rand

const logger = getlogger(@__MODULE__)
function __init__()
	Memento.config!("debug"; fmt = "{level}: {msg}")
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
	cellList_lat_lon, cellList_euclidean, crackOptimalPaths, getGoogleDirection, getMapOSM,
	getTravelTimes,
	OD_matrix, writeGML, writeShapeFile

end
