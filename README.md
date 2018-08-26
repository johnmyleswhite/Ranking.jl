Ranking.jl
==========

Julia tools for ranking entities based on records of binary comparisons.
Currently, we've implemented drafts of Elo, Bradley-Terry and TrueSkill.

It is tested with Julia 0.4.

# Usage Example

All of the models we use expect a data matrix, `D`, in which each row
represents a triple: ID of entity 1, ID of entity 2 and the outcome, which
is `1.0` if 1 beat 2, `0.0` if 2 beat 1 and `0.5` if there was a tie. Let's
create data now in which Player 1 beat Player 2 and also beat Player 3, then Player 2 and Player 3 played a match in which they came to a draw:

```julia
	n_players = 3

	D = [1 2 1.0;
	     1 3 1.0;
	     2 3 0.5;]
```

We can then fit Elo:

```julia
    include("Ranking.jl")
	using Ranking

	m1 = fit(Elo, D, n_players)
```

And then try Bradley-Terry(-Luce):

```julia
	m2 = fit(BradleyTerry, D, n_players)
```

Finally, let's try TrueSkill:

```julia
    m3 = fit(TrueSkill, D, n_players)
```

As you can see, Player 1 gets the highest score, whereas Players 2 and 3 get lower (and nearly equal) scores. Let's see what happens if we switch the data so that Player 2 definitively loses to Player 3:

```julia
	n_players = 3

	D = [1 2 1.0;
	     1 3 1.0;
	     2 3 0.0;]

    include("Ranking.jl")
	using Ranking

	m1 = fit(Elo, D, n_players)

	m2 = fit(BradleyTerry, D, n_players)

    m3 = fit(TrueSkill, D, n_players)
```

Here you can see that the order of scores now becomes Player 1, Player 3 and Player 2, which is just what we would expect.

All of these examples assume that you a single group of players that compete against one another. This can be viewed as a unipartite graph.

Another common task in ranking comes from educational testing, where you have students completing questions that they either answer correctly (1) or incorrectly. In this case, we work with a bipartite graph. From the data perspective, what matters is that the first and second columns of our data matrix maintain completely separate indices:

```julia
	n_students = 2
	n_questions = 5

	D = [1 1 1.0;
	     1 2 1.0;
	     1 3 1.0;
	     1 4 1.0;
	     1 5 0.0;
		 2 1 1.0;
	     2 2 1.0;
	     2 3 1.0;
	     2 4 0.0;
	     2 5 0.0;]
```

Given this data, we can fit the Rasch model, which is like Bradley-Terry, but for bipartite data:

```julia
	m = fit(Rasch, D, n_students, n_questions)
```

This produces separate estimates for all students and all questions, but puts them on a common scale. In reality, we could do the same thing with the Bradley-Terry model if we extended the indices to grow from `1` to `n_students + n_questions`. The Rasch model is simply more convenient when we would like to employ the "natural" ID assignment in which students and questions have independent ID counters.
