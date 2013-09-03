module Ranking
	using Distributions

	include("elo.jl")
	include("trueskill.jl")
	export Elo, TrueSkill
	export predict, fit, update!
end
