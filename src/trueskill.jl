# Based on code from PMTK. Translated by John Myles White
# Demo of the TrueSkill model
# PMTKauthor Carl Rasmussen and  Joaquin Quinonero-Candela,
# PMTKurl http://mlg.eng.cam.ac.uk/teaching/4f13/1112
# PMTKmodified Kevin Murphy

immutable TrueSkill
    Ms::Vector{Float64}
    Ps::Vector{Float64}

    function TrueSkill(m::Vector, p::Vector)
        if length(m) != length(p)
            error("Length of m and p must match")
        end
        new(m, p)
    end
end

# This is terrible practice
psi(x) = pdf(Normal(), x) ./ cdf(Normal(), x)

# As is this, especially since it computes stuff above twice!
lambda(x) = (pdf(Normal(), x) ./ cdf(Normal(), x)) .*
            ((pdf(Normal(), x) ./ cdf(Normal(), x)) + x)

function fit(::Type{TrueSkill}, M::Integer, G::Matrix)
    # Input:
    # M = number of players
    # G[i, 1] = id of winner for game i
    # G[i, 2] = id of loser for hgame i
    #
    # Output:
    # Ms[p] = mean of skill for player p
    # Ps[p] = precision of skill for player p

    # number of games
    N = size(G, 1)

    # prior skill variance (prior mean is always 0)
    pv = 0.5

    # initialize matrices of skill marginals - means and variances
    Ms = nans(M)
    Ps = nans(M)

    # initialize matrices of game to skill messages - means and precisions
    Mgs = zeros(N, 2)
    Pgs = zeros(N, 2)

    # allocate matrices of skill to game messages - means and precisions
    Msg = nans(N, 2)
    Psg = nans(N, 2)

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
        Msg = (Ps[G] .* Ms[G] - Pgs .* Mgs) ./ Psg[G]

        # (3) compute game to performance messages
        # player 1 always wins the way we store data
        vgt = 1 + sum(1 ./ Psg, 2)
        mgt = Msg[:, 1] - Msg[:, 2]

        # (4) approximate the marginal on performance differences
        Mt = mgt + sqrt(vgt) .* psi(mgt ./ sqrt(vgt))
        Pt = 1 ./ (vgt .* (1 - lambda(mgt ./ sqrt(vgt))))

        # (5) compute performance to game messages
        ptg = Pt - 1 ./ vgt
        mtg = (Mt .* Pt - mgt ./ vgt) ./ ptg

        # (6) compute game to skills messages
        Pgs = 1 ./ (1 + repmat(1 ./ ptg, 1, 2) + 1 ./ Psg[:, [2, 1]])
        Mgs = [mtg -mtg] + Msg[:, [2, 1]]
    end

    return TrueSkill(Ms, Ps)
end
