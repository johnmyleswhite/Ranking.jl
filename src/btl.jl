immutable BradleyTerry
	r::Vector{Float64}
	lambda::Float64
end

predict(m::BradleyTerry, i::Integer, j::Integer) = invlogit(m.r[i] - m.r[j])

function logposterior(m::BradleyTerry, D::Matrix)
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
	for i in 1:length(m.r)
		lp -= m.r[i]^2
	end

	return -(ll + m.lambda * lp)
end

function fit(::Type{BradleyTerry},
	         D::Matrix,
	         n::Integer,
	         lambda::Real = 1.0)
	f(r::Vector{Float64}) = logposterior(BradleyTerry(r, lambda), D)

	res = optimize(f, zeros(n), method = :l_bfgs)

	return BradleyTerry(res.minimum, lambda)
end
