module Ranking
	using Distributions
	using Optim

	export Elo, TrueSkill, BradleyTerry, Rasch
	export predict, fit, update!

	include("utils.jl")
	include("elo.jl")
	include("trueskill.jl")
	include("btl.jl")
	include("rasch.jl")
end
