# Controlled experiments: Direct vs Composite surrogates

Code and stored results for the controlled experiments in *Investigating
Composite Modeling in Multi-Objective Bayesian Optimization for Scientific
Design*. Everything needed to regenerate the two tables and the figures is
here; nothing else is required.

The question is when it pays to model structure. For an objective
`f(x) = g(h(x))` with `g` known and cheap and `h` expensive, two arms are
compared under an identical budget:

- **Direct** — a GP on `f`, which never sees `h`.
- **Composite** — a GP on `h`, pushed through the known `g`.

Both fit their own kernel hyperparameters by maximum likelihood, share the
initial design, the acquisition rule and the evaluation budget. The inner
function `h` is drawn from the surrogates' own prior (Matérn 5/2 via random
Fourier features), so Composite's model of `h` is correct by construction
and every difference between the arms is attributable to `g`.

The grid varies `g` alone, over mappings that are bijective on the range `h`
reaches and mappings that are not.

## Reproducing the paper

Stored results are committed, so both commands run in seconds without
re-running any optimisation.

```bash
pip install -r requirements.txt
python paper_tables.py     # -> tables.tex
python make_hv_figs.py     # -> figures/
```

`paper_tables.py` emits both controlled-experiment tables: the
single-objective grid under log10 simple regret, and the two-objective grid
under hypervolume. `make_hv_figs.py` draws the two-objective result three
ways — a forest plot of the per-map gain, the paired Composite-minus-Direct
trace, and the absolute hypervolume curves.

## Re-running the experiments

Optional, and slow. Each produces the JSON the two scripts above read.

```bash
python -m three_arm.run --help                        # single objective
python -m composite_ablation.run_two_stage --help     # two objectives
python -m composite_ablation.check_g1                 # verify the two grids agree
```

`check_g1` is worth running first: it confirms every two-objective mapping
is identical to its single-objective namesake to machine precision, which is
what licenses comparing the two settings map by map.

## Layout

```
three_arm/              single-objective arms, test functions, analysis
  results_matern2/      stored runs, 4 function draws x 5 initial designs
composite_ablation/     two-objective problem, solvers, runner
  results/two_stage_matched/   stored runs, same design
paper_tables.py         regenerates both tables
make_hv_figs.py         regenerates the hypervolume figures
```

## Two things to know about the data

`cos_w4` is excluded. Its frequency is high enough that `omega * sd(h)` spans
most of a half-period, which makes it a different kind of object from the
rest of the grid; it is dropped rather than reported as an outlier.

`spr2s050` and `root2` are the same function. Both place roots at -1 and +1,
and `check_g1` confirms they agree to machine precision, but they were run as
separate jobs. Their runs are pooled into one row. That gives forty runs
against every other row's twenty, so the pooled row is subsampled five per
function draw, with the seed fixed before the outcome was inspected.

Both decisions live in `paper_tables.py` at the point where they take effect.

## Provenance

A snapshot, assembled from two working repositories so that this one is
self-contained. Upstream, and the source of truth for any later change:

- https://github.com/MuhammadAli-CS/three-arm-composite — single objective
- https://github.com/MuhammadAli-CS/MOBO-HighDim — two objectives
