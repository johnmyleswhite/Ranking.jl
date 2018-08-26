# Based on code from PMTK. Translated by John Myles White
# Demo of the TrueSkill model
# PMTKauthor Carl Rasmussen and  Joaquin Quinonero-Candela,
# PMTKurl http://mlg.eng.cam.ac.uk/teaching/4f13/1112
# PMTKmodified Kevin Murphy

struct TrueSkill
    Ms::Vector{Float64}
    Ps::Vector{Float64}

    function TrueSkill(m::Vector, p::Vector)
        if length(m) != length(p)
            error("Lengths of m and p must match")
        end
        new(m, p)
    end
end

# This is terrible practice
ψ(x::Real) = pdf(Normal(), x)/cdf(Normal(), x)

function λ(x::Real)
    ψx = ψ(x)
    return ψx*(ψx+x)
end

function fit(::Type{TrueSkill}, D::Matrix, M::Integer)
    # Input:
    # G[i, 1] = id of winner for game i
    # G[i, 2] = id of loser for game i
    # M = number of players
    #
    # Output:
    # Ms[p] = mean of skill for player p
    # Ps[p] = precision of skill for player p

    # Need to translate into TrueSkill format temporarily
    # number of games. This is bad hack for representing draws
    # since it increases precision of estimates artificially.
    G = round(Int, translateDtoG(D)) # cast type of G to Int

    N = size(G, 1)

    # prior skill variance (prior mean is always 0)
    pv = 0.5

    # initialize matrices of skill marginals - means and variances
    Ms = fill(NaN, M)
    Ps = fill(NaN, M)

    # initialize matrices of game to skill messages - means and precisions
    Mgs = zeros(N, 2)
    Pgs = zeros(N, 2)

    # allocate matrices of skill to game messages - means and precisions
    Msg = fill(NaN, N, 2)
    Psg = fill(NaN, N, 2)

    for iter = 1:5
        # (1) compute marginal skills
        for p = 1:M
            # compute this first because it is needed for the mean update
            # In Matlab these produced vectors
            Ps[p] = 1 / pv + sum(Pgs[G .== p])
            Ms[p] = sum(Pgs[G .== p] .* Mgs[G .== p]) / Ps[p]
        end

        # (2) compute skill to game messages
        # compute this first because it is needed for the mean update
        Psg = Ps[G] - Pgs
        Msg = (Ps[G] .* Ms[G] - Pgs .* Mgs) ./ Psg

        # (3) compute game to performance messages
        # player 1 always wins the way we store data
        vgt = 1 .+ sum(1 ./ Psg, dims=2)
        mgt = Msg[:, 1] - Msg[:, 2]

        # (4) approximate the marginal on performance differences
        Mt = mgt + sqrt.(vgt) .* ψ.(mgt ./ sqrt.(vgt))
        Pt = 1 ./ (vgt .* (1 .- λ.(mgt ./ sqrt.(vgt))))

        # (5) compute performance to game messages
        ptg = Pt - 1 ./ vgt
        mtg = (Mt .* Pt - mgt ./ vgt) ./ ptg

        # (6) compute game to skills messages
        Pgs = 1 ./ (1 .+ repeat(1 ./ ptg, 1, 2) + 1 ./ Psg[:, [2, 1]])
        Mgs = [mtg -mtg] + Msg[:, [2, 1]]
    end

    return TrueSkill(Ms, Ps)
end
