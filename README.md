# Usage Example

Let's start with Elo, which expects a matrix for now:

	using Ranking

	S = [1.0 0.0;
	     0.0 0.0]
	m = fit(Elo, S)
	predict(m)
	update!(m, S)

Then let's try TrueSkill,

	using Ranking

	data = [1.0 2.0;
	        1.0 3.0;
            2.0 3.0;]
    fit_trueskill(3, data)
