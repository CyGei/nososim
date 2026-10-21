# Methods

## Initial conditions

Transmission is simulated in discrete daily time steps. Each individual
has an identifier, admission and discharge dates, a baseline
reproduction number $`R_i`$, and optional attributes such as ward or
group. Individuals are present from admission up to, but excluding,
discharge. Initial cases and their infection dates are specified in
advance, while all other individuals are susceptible on admission.
Individuals can be infected only once.

For individual $`i`$ infected on date $`T_i`$, the baseline daily
infectiousness $`\lambda_i(t)`$ is

``` math
\lambda_i(t)=R_i\,w(t-T_i)
```

Where $`w`$ refers to the PMF of the generation time.

## Distribution of infectiousness

Mixing matrices describe how infectiousness is distributed among
individuals according to attributes such as location or group. Rows
represent source attributes and columns represent recipient attributes.
Matrix entries are non-negative, may be asymmetric, and are zero for
excluded transmission routes.

The relative mixing weight from source $`i`$ to recipient $`j`$ denoted
$`m_{ij}(t)\in[0,\infty)`$, is the product of the corresponding weights
across attributes. For example, given a location matrix $`L`$ and a
group matrix $`G`$:

``` math
m_{ij}(t)=L_{l_i(t),l_j(t)}\,G_{g_i,g_j},\qquad i\ne j
```

where $`l_i(t)`$ is the location of individual $`i`$ on day $`t`$, and
$`g_i`$ is their fixed group. The attribute matrices can remain constant
while pairwise weights change with daily locations. Self-transmission is
excluded by setting $`m_{ii}(t)=0`$. In the absence of mixing matrices,
all distinct pairs receive equal weights $`m_{ij}(t)=1`$ by default.

These weights are normalised separately for each source over all
individuals present on day $`t`$ (except the source itself), denoted
$`\mathcal P(t)`$:

``` math
q_{ij}(t)=\frac{m_{ij}(t)}{\sum_{\ell\in\mathcal P(t)}m_{i\ell}(t)},\qquad i,j\in\mathcal P(t)
```

Thus $`q_{ij}(t)`$ represents the proportion of source $`i`$’s baseline
infectiousness allocated to recipient $`j`$. Weights sum to one for each
source when the denominator is positive, and are otherwise set to zero.
All individuals present, including those previously infected, contribute
to the normalisation.

## Interventions

Iterventions are represented by a time-varying matrix $`E(t)`$ whose
entries $`e_{ij}(t)\in[0,1]`$ specify the proportional reduction in
transmission hazard from source $`i`$ to recipient $`j`$. A value of
zero indicates no reduction, while one prevents transmission entirely.
Intervention effects may vary over time and across individuals or
attributes.

The resulting daily infection hazard from source $`i`$ to recipient
$`j`$ is

``` math
h_{ij}(t)=\lambda_i(t)\,q_{ij}(t)\,[1-e_{ij}(t)]
```

Interventions are applied after mixing weights have been normalised, so
reductions in infectiousness are not redistributed among other
recipients.

## Infection and source assignment

The total daily infection hazard for recipient $`j`$ is the sum of
contributions from all individuals present:

``` math
H_j(t)=\sum_{i\in\mathcal P(t)}h_{ij}(t)
```

The corresponding infection probability is

``` math
p_j(t)=1-e^{-H_j(t)}
```

For each susceptible individual $`j\in S(t)`$, where $`S(t)`$ is the set
of susceptible individuals present on day $`t`$, infection is simulated
independently as

``` math
X_j(t)\sim\operatorname{Bernoulli}(p_j(t))
```

For each newly infected individual, the source is sampled from the
previously infected individuals present and infectious that day, with
probabilities proportional to their contributions to the recipient’s
total hazard:

``` math
\Pr(\text{source}=i\mid j\text{ infected on day }t)
=\frac{h_{ij}(t)}{H_j(t)}
```

This assignment is defined for $`H_j(t)>0`$, infection states are
updated simultaneously at the end of each day, so newly infected
individuals can begin transmitting on the following day. The simulation
records each infected individual’s identifier, infection date and
transmission source. Initial cases have no assigned source.

| Quantity | Interpretation |
|----|----|
| $`T_i`$ | Infection date of individual $`i`$. |
| $`R_i=2`$ | Basic reprodcution number for individual $`i`$. Realised secondary infections may be lower |
| $`w(2)=0.3`$ | 30% of baseline infectiousness is allocated to the second day after infection. |
| $`\lambda_i(t)=0.6`$ | Source $`i`$ has 0.6 units of baseline infectiousness on day $`t`$. |
| $`L_{A,B}=2`$, $`L_{A,A}=1`$ | A source in ward A allocates twice as much infectiousness to each individual in B as to each other individual in A, all else equal. |
| $`G_{\mathrm{patient,staff}}=2`$, $`G_{\mathrm{patient,patient}}=1`$ | A patient allocates twice as much infectiousness to each staff member as to each other patient, all else equal. |
| $`m_{ij}(t)=6`$, $`m_{ik}(t)=1`$ | Source $`i`$ allocates six times as much infectiousness to $`j`$ as to $`k`$, when both are present. |
| $`q_{ij}(t)=0.1`$ | Recipient $`j`$ receives 10% of source $`i`$’s baseline infectiousness that day. |
| $`e_{ij}(t)=0.5`$ | Intervention reduces the hazard from $`i`$ to $`j`$ by 50%. |
| $`h_{ij}(t)=0.06`$ | Source $`i`$ contributes 0.06 to recipient $`j`$’s daily infection hazard. |
| $`H_j(t)=0.2`$ | Total daily hazard of 0.2, corresponding to an infection probability of approximately 18.1%. |
| $`p_j(t)=0.2`$ | A susceptible individual has a 20% probability of infection that day. |
| $`h_{ij}(t)/H_j(t)=0.3`$ | Conditional on infection, source $`i`$ has a 30% probability of being assigned as the infector. |
