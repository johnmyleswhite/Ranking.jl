# Bipartite data
immutable Rasch
	a::Vector{Float64}
	b::Vector{Float64}
	lambda::Float64
end

predict(m::Rasch, i::Integer, j::Integer) = invlogit(m.a[i] - m.b[j])

function logposterior(m::Rasch, D::Matrix)
	ll = 0.0
	nrows, ncols = size(D)

	# Latent variable logit likelihood
	for ind in 1:nrows
		i, j, o = int(D[ind, 1]), int(D[ind, 2]), D[ind, 3]
		p = predict(m, i, j)
		ll += log((1 - p) * (1 - o) + p * o)
	end

	# Gaussian prior
	lp = 0.0
	for i in 1:length(m.a)
		lp -= m.a[i]^2
	end
	for i in 1:length(m.b)
		lp -= m.b[i]^2
	end

	return -(ll + m.lambda * lp)
end

function fit(::Type{Rasch},
	         D::Matrix,
	         n_a::Integer,
	         n_b::Integer,
	         lambda::Real = 1.0)
	f(x::Vector{Float64}) =
	  logposterior(Rasch(x[1:n_a], x[(n_a + 1):(n_a + n_b)], lambda), D)

	res = optimize(f, zeros(n_a + n_b), method = :l_bfgs)

	a = res.minimum[1:n_a]
	b = res.minimum[(n_a + 1):(n_a + n_b)]

	return Rasch(a, b, lambda)
end
