Ranking.jl
==========

Julia tools for ranking entities based on records of binary comparisons.
Currently, we've implemented drafts of Elo, Bradley-Terry and TrueSkill.

# Usage Example

All of the models we use expect a data matrix, `D`, in which each row
represents a triple: ID of entity 1, ID of entity 2 and the outcome, which
is `1.0` if 1 beat 2, `0.0` if 2 beat 1 and `0.5` if there was a tie. Let's
create data now in which Player 1 beat Player 2 and also beat Player 3, then Player 2 and Player 3 played a match in which they came to a draw:

	n_players = 3

	D = [1 2 1.0;
	     1 3 1.0;
	     2 3 0.5;]

We can then fit Elo:

	using Ranking

	m1 = fit(Elo, D, n_players)

And then try Bradley-Terry(-Luce):

	m2 = fit(BradleyTerry, D, n_players)

Finally, let's try TrueSkill:

    m3 = fit(TrueSkill, D, n_players)

As you can see, Player 1 gets the highest score, whereas Players 2 and 3 get lower (and nearly equal) scores. Let's see what happens if we switch the data so that Player 2 definitively loses to Player 3:

	n_players = 3

	D = [1 2 1.0;
	     1 3 1.0;
	     2 3 0.0;]

	using Ranking

	m1 = fit(Elo, D, n_players)

	m2 = fit(BradleyTerry, D, n_players)

    m3 = fit(TrueSkill, D, n_players)

Here you can see that the order of scores now becomes Player 1, Player 3 and Player 2, which is just what we would expect.
