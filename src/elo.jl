# Elo assigns ranks to each of N players
# R_b = R[j], R_a = R[i]
# S_ij = S_ab \in [0.0, 0.5, 1.0] # Win, Draw, Lose

# Implement Elo as used by USCF

immutable Elo
	r::Vector{Float64}
end

# function pdf(m::Elo, i::Integer, j::Integer, o::Real)
# 	p = 1 / (1 + 10^((m.r[j] - m.r[i]) / 400))
# end

function predict(m::Elo, i::Integer, j::Integer)
	return 1 / (1 + 10^((m.r[j] - m.r[i]) / 400))
end

# Players below 2100 --> K-factor of 32 used
# Players between 2100 and 2400 --> K-factor of 24 used
# Players above 2400 --> K-factor of 16 used.
function kfactor(r_i::Real)
	if r_i < 2100
		return 32
	elseif r_i <= 2400
		return 24
	else
		return 16
	end
end

function update!(m::Elo, D::Matrix)
	nrows, ncols = size(D)
	if ncols != 3
		error("Data must be in Ranking binary outcome format")
	end
	for ind in 1:nrows
		i, j, o = int(D[ind, 1]), int(D[ind, 2]), D[ind, 3]
		p = predict(m, i, j)
		m.r[i] += kfactor(m.r[i]) * (o - p)
		m.r[j] += kfactor(m.r[j]) * ((1 - o) - (1 - p))
	end
	return
end

function fit(::Type{Elo}, D::Matrix, n::Integer)
	m = Elo(fill(1600.0, n))
	update!(m, D)
	return m
end
