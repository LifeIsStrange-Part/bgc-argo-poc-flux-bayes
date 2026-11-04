// perdepth_lognormal_v3_1103.stan     Last modified: 2026-11-04
// One depth, no profile effect.  ln F ~ Normal(x beta, exp(x gamma)).
// Differs from stan_noy.stan of Edwards et al. (2026): log link on sigma, weakly informative priors,
// vectorised likelihood, and per-observation mu and sigma are not stored.
data {
  int<lower=1> N;
  int<lower=1> p;
  vector[N] y;      // ln flux
  matrix[N, p] x;   // first column 1, predictors standardized
}
parameters {
  vector[p] beta;
  vector[p] gamma;
}
model {
  beta ~ normal(0, 5);
  gamma ~ normal(0, 2);
  y ~ normal(x * beta, exp(x * gamma));
}
