using Ranking

n_players = 3

D = [1 2 1.0;
     1 3 1.0;
     2 3 0.5;]

m = fit(BradleyTerry, D, n_players)

D = [1 2 1.0;
     1 3 1.0;
     2 3 0.0;]

m = fit(BradleyTerry, D, n_players)
