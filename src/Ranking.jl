module Ranking
	using Distributions

	include("elo.jl")
	export Elo, predict, fit, update!
	include("trueskill.jl")
	export fit_trueskill
end
