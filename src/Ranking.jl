module Ranking
	using Distributions
	using Optim

	include("utils.jl")
	include("elo.jl")
	include("trueskill.jl")
	include("btl.jl")
	export Elo, TrueSkill, BradleyTerry
	export predict, fit, update!
end
