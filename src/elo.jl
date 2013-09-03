# Elo assigns ranks to each of N players
# R_b = R[j], R_a = R[i]
# S_ij = S_ab \in [0.0, 0.5, 1.0] # Win, Draw, Lose
immutable Elo
	r::Vector{Float64}
	k::Float64
end

Elo(r::Vector{Float64}; k::Real = 0.1) = Elo(r, k)

function predict(m::Elo, i::Integer, j::Integer)
	return 1 / (1 + 10^((m.r[j] - m.r[i]) / 400))
end

function predict(m::Elo)
	n = length(m.r)
	S = Array(Float64, n, n)
	for j in 1:n
		for i in (j + 1):n
			 S[i, j] = 1 / (1 + 10^((m.r[j] - m.r[i]) / 400))
			 S[j, i] = 1 - 1 / (1 + 10^((m.r[j] - m.r[i]) / 400))
		end
	end
	for i in 1:n
		S[i, i] = 0.5
	end
	return S
end

function update!(m::Elo, S::Matrix)
	n1, n = size(S)
	if n1 != n
		error("Matrix must be square")
	end
	for j in 1:n
		for i in (j + 1):n
			p = predict(m, i, j)
			m.r[i] = m.r[i] + m.k * (p - S[i, j])
			m.r[j] = m.r[j] - m.k * (p - S[i, j])
		end
	end
	return
end

function fit(::Type{Elo}, S::Matrix)
	n1, n = size(S)
	if n1 != n
		error("Matrix must be square")
	end
	m = Elo(zeros(n))
	update!(m, S)
	return m
end
