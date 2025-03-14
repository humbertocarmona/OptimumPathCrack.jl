struct DisorderDist <: ContinuousUnivariateDistribution
    beta::Float64
    DisorderDist(beta) = new(Float64(beta))
end


function rand(s::DisorderDist)
    return exp(s.beta*(Random.rand() - 1.0))
end
