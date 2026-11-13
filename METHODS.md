# Methods

## Population and infection history

Transmission is simulated in daily steps using population records with `id`,
`start`, and `end`. Both stay boundaries are included. Repeated IDs represent
separate stays or shifts; infection history is retained across absences.
Each person can be infected once. `simulacr::simulate_outbreak_step()` advances
the epidemic from each contact date $t$ to $t+1$. Imported cases are supplied
with `id` and
`date_infection`; they enter on that date, while earlier imports initialise the
simulation. A scheduled import is ignored if the person has already acquired
infection.

## Contacts and infectiousness

The daily contact matrix $C_t$ contains non-negative, potentially asymmetric
intensities. Rows are sources and columns are recipients. Self-contact is zero.
Absent individuals have no contacts and need not appear in the daily matrix.
Contact rules and attribute weights are combined by `get_contacts()`; their
coefficients are used directly, without normalisation.

For source $i$ infected on date $T_i$, the pairwise force of infection is

$$
\lambda_{t,i\rightarrow j}
= I_{t,i} C_{t,i\rightarrow j} \tau_{t,i} w(t-T_i).
$$

Here $\tau_{t,i}$ is the per-contact transmission rate, and $w$ is a
generation-time PMF constructed with `simulacr::make_pmf_delay()`. Numeric
weights correspond to delays 0, 1, 2, etc., and are normalised by that function.
PMF functions and `distcrete` objects are also accepted. The engine evaluates
$w(t-T_i)$ exactly at contact time $t$, including delay zero.
The `tau(present, date)` callback allows rates to vary with date or individual
attributes; by default it reads the population's `tau` column.

## Optional interventions

An intervention supplies proportional reductions $E_{t,ij}\in[0,1]$ with source
rows and recipient columns named by ID. The adjusted force of infection is

$$
\lambda^{*}_{t,ij}=\lambda_{t,i\rightarrow j}(1-E_{t,ij}).
$$

Without an intervention, $E_{t,ij}=0$. Reductions do not redistribute
infectiousness to other recipients. The baseline contact matrix remains
unchanged. The engine receives the effective contact matrix $C^{*}_{t,ij}=C_{t,ij}(1-E_{t,ij})$.

## Infection and source assignment

Let $S_{t,j}$ indicate whether person $j$ is susceptible at the start of the day.
Their total force of infection and probability of becoming infected at $t+1$ are

$$
H_{t,j}=S_{t,j}\sum_i\lambda^{*}_{t,ij},
\qquad p_{t,j}=1-\exp(-H_{t,j}).
$$

Each susceptible person's infection is drawn independently from
$\operatorname{Bernoulli}(p_{t,j})$. The expected number of new cases produced by that contact step is
$\sum_j p_{t,j}$. Given an infection at $t+1$, its source is sampled with
probability

$$
\Pr(\alpha_j=i\mid j\text{ infected at }t+1)
=\frac{\lambda^{*}_{t,ij}}{\sum_k\lambda^{*}_{t,kj}}.
$$

The engine returns new infections dated $t+1$. They join infection history
before the next step and cannot transmit within the step that generated them.
The final contact date can therefore produce cases on the following day.
Imported infections have no assigned source.

## Summed force of infection and realised offspring

The model-defined quantity in equation 12 is recorded for each individual as

$$
R_i=\sum_t\sum_j\lambda^{*}_{t,ij}.
$$

`outbreak$reproduction` contains these sums over the simulation dates, including
intervention effects. This is cumulative outgoing FOI, not generally the expected
number of successful secondary infections in a finite population.
`offspring(outbreak)` counts realised secondary infections from the recorded
transmission tree. `count_edges()` groups transmissions using source and
recipient attributes on the contact date, one day before the recorded infection
date.
