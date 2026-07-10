# About `gpprob.bash`

VoroMarmotte predicts whether Voronoi tessellation-derived contact areas observed in a single protein conformation are likely to persist, i.e. remain stable rather than decrease, in an ensemble of conformations of the same protein.

The `gpprob.bash` script converts VoroMarmotte-style per-contact persistence probabilities into an approximate global probability that the structure preserves at least a chosen fraction of its weighted contact architecture.

## Usage workflow

The intended use is a two-step workflow.

First, run VoroMarmotte on a protein structure and request the per-contact output table. For example:

```
voromarmotte \
  --input model.pdb \
  --output-per-contact contacts.tsv
```

The file `contacts.tsv` should contain one row per an assessed residue-residue contact, including the contact `area` and the VoroMarmotte-predicted `predicted_probability_to_persist` value - these are the two columns used by `gpprob.bash`.

Second, run `gpprob.bash` on the per-contact table:

```
./gpprob.bash "contacts.tsv" 0.8 0.7
```

to get an output that looks similarly to this:

```
probability_to_persist_globally  0.645543362341943
expected_global_persistence      0.682267441209688
global_persistence_threshold     0.7
approx_var                       0.173487638675561
approx_alpha                     0.170248439053627
approx_beta                      0.0792848506366587
```

## Usage explanation

In the command

```
./gpprob.bash "contacts.tsv" 0.8 0.7
```

the three arguments are:

1. `contacts.tsv`: the VoroMarmotte per-contact table. The input table is assumed to contain one row per contact, with at least two columns: `predicted_probability_to_persist` and `area`.
2. `0.8`: the inter-contact correlation/inflation coefficient, $\rho$. Use `0` for the independent-contact model, use larger values to broaden the global persistence distribution.
3. `0.7`: the minimum global persistence threshold, $t$.

The script prints a small summary table containing:

* the approximate probability of exceeding the threshold,
* the expected global persistence,
* the threshold used,
* the approximated variance,
* the fitted beta-distribution parameters.

## Theory behind `gpprob.bash`

For a residue-residue contact $i$, let

$$
p_i = P(X_i = 1)
$$

be the predicted probability that the contact persists, where $X_i$ is a Bernoulli indicator of contact persistence.

The contact area is converted into a normalized weight

$$
a_i = \frac{\mathrm{area}_i}{\sum_j \mathrm{area}_j}, \qquad \sum_i a_i = 1.
$$

The weighted global persistence score is then defined as

$$
Q = \sum_i a_i X_i.
$$

Thus $Q=1$ means all area-weighted contacts persist, while $Q=0$ means none persist.

The expected global persistence is

$$
\mu = E[Q] = \sum_i a_i p_i.
$$

This is the value reported by the script as `expected_global_persistence`.

If contacts are treated as independent Bernoulli variables, the variance of $Q$ is the weighted Poisson-binomial variance

$$
\sigma^2_{\mathrm{ind}} = \sum_i a_i^2 p_i(1-p_i).
$$

Because the weights $a_i$ are normalized and squared, this independent-contact variance can become very small when many contacts contribute to the global score.
In reality, however, protein contacts are often correlated: groups of contacts can appear or disappear together when a loop, secondary-structure element, interface, or domain moves.

To allow this extra spread, the script used an inter-contact correlation/inflation parameter $\rho$.
It interpolates between the independent-contact variance and a coupled, global-state-like variance:

$$
\sigma^2_{\rho} = (1-\rho)\sigma^2_{\mathrm{ind}} + \rho\mu(1-\mu).
$$

Here, $\rho=0$ gives the independent-contact model. Larger values make the global persistence distribution broader.
The term $\mu(1-\mu)$ is the variance of a Bernoulli variable with mean $\mu$ and represents a limiting case where the whole contact map behaves like one coupled persistence state.
In practice, $\rho$ should be interpreted as a heuristic variance-inflation parameter unless it has been calibrated from ensembles.

The true distribution of a weighted sum of Bernoulli variables is discrete and can be difficult to compute exactly.
The script therefore approximates the distribution of $Q$ by a beta distribution,

$$
Q \approx \mathrm{Beta}(\alpha,\beta),
$$

because the beta distribution is naturally bounded between 0 and 1.
The beta parameters are chosen to match the estimated mean $\mu$ and variance $\sigma^2_{\rho}$.

For a beta distribution,

$$
E[Q] = \frac{\alpha}{\alpha+\beta},
$$

and

$$
\mathrm{Var}(Q) = \frac{\mu(1-\mu)}{\alpha+\beta+1}.
$$

Solving for $\alpha$ and $\beta$ gives

$$
\alpha + \beta = \frac{\mu(1-\mu)}{\sigma^2_{\rho}} - 1,
$$

$$
\alpha = \mu(\alpha+\beta),
\qquad
\beta = (1-\mu)(\alpha+\beta).
$$

Finally, the user supplies a minimum acceptable global persistence threshold $t$, called `min_persistence` in the script.
The reported global persistence probability is

$$
P(Q > t) \approx 1 - F_{\mathrm{Beta}(\alpha,\beta)}(t),
$$

implemented in R as

```
1 - pbeta(threshold, shape1=dist_alpha, shape2=dist_beta)
```

and reported as `probability_to_persist_globally`.

## Conclusion

In summary, the script estimates the probability that an area-weighted fraction of persistent contacts exceeds a user-defined threshold.

Its main assumptions are:

* the per-contact probabilities are meaningful persistence probabilities,
* contact areas are meaningful weights,
* the correlation coefficient $\rho$ captures additional collective contact behavior,
* and the beta approximation is adequate for the bounded global score $Q \in [0,1]$.

