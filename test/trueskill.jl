# Demo of the TrueSkill model
# PMTKauthor Carl Rasmussen and  Joaquin Quinonero-Candela,
# PMTKurl http://mlg.eng.cam.ac.uk/teaching/4f13/1112
# PMTKmodified Kevin Murphy

function trueskillDemo()
    srand(0)

    # Let us assume the following partial order on players
    # where higher up is better
    #     1
    #    / \
    #   2   3
    #    \ /
    #     4
    #    / \
    #   5   6
    # We will sample data from this graph, where we let each player
    # beat its children K times

    Nplayers = 6
    G = zeros(Nplayers, Nplayers)
    G[1, [2, 3]] = 1
    G[2, 4] = 1
    G[3, 4] = 1
    G[4, [5, 6]] = 1

    data = zeros(0, 2)
    game = 1
    for i = 1:Nplayers
        ch = find(G[i, :] .== 1.0) # Need all children
        for j in ch
            # Sample the number of games between this pair
            K = rand(Categorical([0.3, 0.1, 0.1, 0.1, 0.4]))
            for k = 1:K
                data = vcat(data, [i j])
                game = game + 1
            end
        end
    end
    Ngames = zeros(1, Nplayers)
    for i = 1:Nplayers
        Ngames[i] = sum(data[:, 1] .== i) + sum(data[:, 2] .== i)
    end

    Ms, Ps = fit_trueskill(Nplayers, data)
    order = sortperm(vec(Ms), rev = true)

    sigmas = sqrt(1 ./ Ps)
    for i = 1:Nplayers
        j = order[i]
        @printf "rank %d, player %d, num games %d, skill = %5.3f (std %5.3f)\n" i j Ngames[j] Ms[j] sigmas[j]
    end
end
