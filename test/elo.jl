using Ranking

S = [0.0 0.0;
     1.0 0.0]

m = fit(Elo, S)

predict(m)

update!(m, S)

predict(m)
