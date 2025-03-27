__precompile__()
module OptimumPathCrack

using CSV
using DataFrames
using Dates
using Distributions
using GeoDataFrames
using Geodesy
using GeometryBasics
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
	#==
		using OptimumPathCrack
		# Get the module logger
		logger = getlogger("OptimumPathCrack")

		# Set log level
		setlevel!(logger, "info")  # or "debug" if desired

		# Generate log file name
		using Dates
		time_now = Dates.format(Dates.now(), "yy-mm-dd_HH-MM")
		log_file = "opc_$(time_now).log"

		# Create a file handler with simple formatting
		file_handler = DefaultHandler(log_file, DefaultFormatter("{level}: {msg}"))

		# Attach the file handler only
		push!(logger, file_handler)
	==#
	setlevel!(logger, "debug")
	handler = DefaultHandler(stderr, DefaultFormatter("{level}: {msg}"))
	push!(logger, handler)
	Memento.register(logger)
end
swap(t::Tuple) = (t[2], t[1])

include("getGoogleDirection.jl")
include("getTravelTimes.jl")
include("getMapOSM.jl")
include("buildCityNetwork.jl")
include("buildSquareNetwork.jl")
include("cellList.jl")
include("create_ODs.jl")
include("crackOptimalPaths.jl")
include("writeGPKGFile.jl")
include("writeGML.jl")
include("DisorderDist.jl")

export DisorderDist, rand, buildCityNetwork, buildSquareNetwork,
	cellList_lat_lon, cellList_euclidean, crackOptimalPaths, getGoogleDirection, getMapOSM,
	getTravelTimes,
	create_ODs, writeGML, writeGPKGFile

end
