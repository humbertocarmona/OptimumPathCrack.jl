function getGoogleDirection(origin::Tuple{Float64,Float64},
                            destination::Tuple{Float64,Float64},
                            deptime::Int64,
                            key::String)

    """
        origin = (lat, lon)
        destination = (lat, lon)
        key =  directions api key
    """

    ostr = "origin=$(origin[1]),$(origin[2])"
    dstr = "destination=$(destination[2]),$(destination[1])"
    qstr = "$ostr&$dstr&travel_mode=driving&units=metric&key=$key"
    url = "https://maps.googleapis.com/maps/api/directions/json?$qstr"

    r = HTTP.request("GET", url)
    datajson = Nothing
    output = Nothing
    if r.status == 200
        data = String(r.body)
        datajson = JSON.Parser.parse(data)
        hasRoute = haskey(datajson,"routes") && size(datajson["routes"],1)>0
        hasleg = false

        output = Dict()
        output["travelTimeSec"] = Inf
        output["travelDistMt"] = Inf
        output["numberOfSteps"] = 0
        output["stepDuration"] = []
        output["stepDistance"] = []
        if hasRoute
            route = datajson["routes"][1]
            hasLeg = haskey(route,"legs") && size(route["legs"],1)>0
            if hasLeg
                leg = route["legs"][1]
                steps = leg["steps"]
                output["travelTimeSec"] = leg["duration"]["value"]
                output["travelDistMt"] = leg["distance"]["value"]
                output["numberOfSteps"] = size(steps,1)
                for step in steps
                    append!(output["stepDuration"], step["duration"]["value"])
                    append!(output["stepDistance"], step["distance"]["value"])
                end
            end
        end
    end

    return datajson, output
end
