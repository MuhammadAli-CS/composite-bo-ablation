# Two objectives, one shared intermediate

Controlled two-objective experiment where both objectives are built from the
same scalar intermediate. Companion to Table 4 of the paper, which uses two
independent intermediates. Run 2026-11-07, 21 outer maps, 20 paired runs each.

## Question

Table 4 uses `f1 = g1(h0)` and `f2 = h1` with `h0`, `h1` independent GP draws.
The second draw was questioned as a possible confounder for the Direct arm.
This grid removes it: `f2 = h0`, so one intermediate feeds both objectives.

## Setup

```
Matched (Table 4)                      Shared (this grid)

x -> h0 -> g1 -> f1                    x -> h0 -> g1 -> f1
x -> h1 -------> f2                          h0 -------> f2
```

| | Matched (Table 4) | Shared |
|---|---|---|
| Intermediates | h0, h1, independent Matern-5/2 RFF draws | h0 only |
| Objective 1 | g1(h0) | g1(h0) |
| Objective 2 | h1 | h0 |
| Composite arm | two GPs on (h0, h1), composed through g | one GP on h0, composed through g |
| Direct arm | two GPs on (f1, f2) | two GPs on (f1, f2) |

Both arms share the inner function draw, the initial design, qLogEHVI, the
reference point and the evaluation budget within every pair. Everything else
matches Table 4: input dimension 6, 10 initial points, 40 adaptive
evaluations, Matern-5/2 kernel, 4 function draws x 5 initial designs = 20
paired runs per map, all 21 maps in `OUTER_G1`. Both objectives are
minimised and affinely normalised to roughly [0, 1] on a fixed reference set.

Code: `make_two_stage(..., g2="shared")` in `composite_ablation/two_stage.py`,
`--g2 shared` in `composite_ablation/run_two_stage.py`. Driver and per-map
JSON results in `composite_ablation/results/two_stage_shared/`.

## Metrics

Per paired run, with `d` and `c` the final hypervolume of the Direct and
Composite arm on the same draw and initial design:

- **Gain** = `c - d`, mean +- one standard deviation over the 20 runs.
- **Final-HV %** = `100 * (c - d) / d`, mean +- one standard deviation.
- **p** is a one-sided paired t-test on Final-HV % for a positive mean.
- **wins** counts runs where Composite's final hypervolume beat Direct's.

Direct and Composite columns are the mean final hypervolume of each arm.
They carry no spread because each map pools four function draws whose
hypervolumes differ a lot; that spread cancels in the paired Gain.

## Results

SH = shared grid (this run). T4 = matched grid, identical to the paper's
Table 4. Bold marks p < 0.05, unadjusted. Rows sorted by SH Final-HV within
each group.

| g1 | Bijective | SH Direct | SH Comp | SH Gain +- SD | SH Final-HV % +- SD | SH p | SH wins | T4 Final-HV % +- SD | T4 p | T4 wins |
|---|---|---|---|---|---|---|---|---|---|---|
| mono5 | yes | 84.78 | 88.00 | +3.22 +- 11.94 | +5.82 +- 23.76 | 0.144 | 10/20 | +2.91 +- 12.76 | 0.160 | 13/20 |
| identity | yes | 75.54 | 77.87 | +2.33 +- 8.45 | +4.61 +- 7.90 | **0.009** | 16/20 | +0.01 +- 3.81 | 0.496 | 8/20 |
| sinh_b1 | yes | 79.37 | 82.13 | +2.76 +- 7.33 | +4.35 +- 9.97 | **0.033** | 12/20 | -0.19 +- 3.73 | 0.587 | 9/20 |
| exp_b1 | yes | 75.52 | 76.80 | +1.28 +- 9.23 | +2.02 +- 10.90 | 0.208 | 10/20 | +1.14 +- 4.54 | 0.138 | 14/20 |
| mono3 | yes | 80.26 | 79.47 | -0.79 +- 7.46 | -1.23 +- 9.74 | 0.711 | 6/20 | +1.58 +- 8.36 | 0.204 | 11/20 |
| root5 | no | 97.14 | 112.62 | +15.48 +- 40.83 | +39.04 +- 75.43 | **0.016** | 15/20 | +31.24 +- 57.77 | **0.013** | 14/20 |
| root2 | no | 73.62 | 74.80 | +1.17 +- 2.73 | +4.03 +- 5.99 | **0.004** | 15/20 | +1.26 +- 7.51 | 0.231 | 11/20 |
| spr2s050 | no | 73.62 | 74.80 | +1.17 +- 2.73 | +4.03 +- 5.99 | **0.004** | 15/20 | +4.15 +- 7.17 | **0.009** | 18/20 |
| shiftsq_c2 | no | 74.65 | 77.05 | +2.40 +- 8.43 | +3.73 +- 9.99 | 0.056 | 13/20 | +0.17 +- 6.25 | 0.451 | 13/20 |
| spr4s050 | no | 73.99 | 75.48 | +1.49 +- 7.65 | +3.64 +- 7.03 | **0.016** | 14/20 | +0.52 +- 5.23 | 0.332 | 12/20 |
| shiftsq_c1 | no | 75.05 | 76.69 | +1.65 +- 5.61 | +3.27 +- 7.28 | **0.030** | 12/20 | +1.16 +- 3.70 | 0.088 | 14/20 |
| root4 | no | 74.53 | 76.06 | +1.53 +- 5.91 | +3.16 +- 7.00 | **0.029** | 16/20 | +0.69 +- 5.99 | 0.307 | 14/20 |
| shiftsq_c0 | no | 74.43 | 74.04 | -0.39 +- 5.90 | +2.98 +- 7.54 | **0.047** | 13/20 | +2.70 +- 5.64 | **0.023** | 15/20 |
| spr6s100 | no | 73.01 | 74.05 | +1.04 +- 3.21 | +1.61 +- 2.45 | **0.004** | 15/20 | +0.14 +- 5.41 | 0.454 | 11/20 |
| shiftsq_c0.5 | no | 74.51 | 75.69 | +1.18 +- 6.79 | +1.55 +- 8.18 | 0.203 | 12/20 | +3.53 +- 9.03 | **0.048** | 15/20 |
| cos_w2 | no | 76.42 | 76.64 | +0.22 +- 9.23 | +1.36 +- 11.00 | 0.293 | 9/20 | +2.01 +- 3.76 | **0.014** | 14/20 |
| cos_w4 | no | 76.39 | 75.79 | -0.60 +- 4.36 | +0.31 +- 9.58 | 0.444 | 11/20 | +1.39 +- 8.13 | 0.227 | 13/20 |
| spr3s050 | no | 79.09 | 78.91 | -0.18 +- 9.84 | -0.65 +- 13.23 | 0.586 | 11/20 | +1.59 +- 6.40 | 0.141 | 14/20 |
| shiftsq_c3 | no | 74.74 | 72.71 | -2.03 +- 8.13 | -0.74 +- 9.76 | 0.632 | 9/20 | +1.69 +- 5.23 | 0.082 | 12/20 |
| cos_w1 | no | 77.05 | 75.90 | -1.15 +- 4.90 | -1.33 +- 6.95 | 0.798 | 7/20 | -2.39 +- 4.50 | 0.986 | 8/20 |
| root3 | no | 80.25 | 79.36 | -0.89 +- 7.84 | -3.41 +- 13.48 | 0.864 | 8/20 | +5.28 +- 11.18 | **0.024** | 15/20 |

`root2` and `spr2s050` are the same function (roots at -1 and +1) and give
identical rows; the paper pools them. `shiftsq_c3` is `(h-3)^2` with its
vertex inside the range h reaches, so it is listed as not bijective.

## What changed

Bijectivity no longer separates the groups. In Table 4 none of the five
bijective maps is significant. Here two of them are: identity (p = 0.009,
16 wins) and sinh (p = 0.033). Both rows have a degenerate front, explained
in the next section, so they cannot be read as composition helping.

The non-bijective rows reshuffle. Nine of sixteen are significant here
against six of fourteen in Table 4, and they are different rows. root3 falls
from +5.28 % (p = 0.024) to -3.41 % (p = 0.864). cos_w2 and shiftsq_c0.5
lose significance. root2, root4, spr4s050, spr6s100 and shiftsq_c1 gain it.
Six rows show Composite flat or worse.

Variance did not fall. The standard deviation of Final-HV % runs from 2.5 to
75 points here, against 3.7 to 58 in Table 4.

Gain and Final-HV % can disagree in sign. shiftsq_c0 has a negative mean Gain
and a positive, significant Final-HV %. The percentage divides each run by
its own Direct hypervolume, so draws with small hypervolume weigh more. Table
4 has the same caveat.

## Why the shared design measures something else

With `f2 = h0`, the Direct arm's second GP is fit to h0 itself. Whatever g1 folds or hides in f1, Direct recovers h0
exactly at every evaluated point. The information gap that Proposition 1 and
the bijective versus non-bijective split rest on is gone for every g1.

The front also collapses for monotone g1. Both objectives are functions of
one scalar z = h0(x), so the objective image is the curve (g1(z), z). For
identity, exp, sinh, cube and quintic, g1 is increasing on the range h
reaches, so the point with the smallest z also has the smallest g1(z). The
Pareto front is one point and the problem is single-objective minimisation
of h0. Hypervolume then only measures how small a z each arm
found. The non-monotone maps keep a trade-off segment, still on a 1-D curve.

The identity and sinh gains come from the acquisition's joint distribution.
Direct fits two independent GPs, so its posterior samples f1 and f2 at a
candidate independently. In the
shared design f1 is a function of f2, and for identity the truth is f1 = f2
on every sample. Direct's samples scatter off that diagonal onto pairs that
cannot occur. Expected hypervolume improvement is a nonlinear expectation
over those joint samples, so a wrong joint gives a wrong expectation even
with correct marginals. With a one-point front at (z*, z*), a candidate
improves only if both coordinates beat z*; the true probability is
P(h0 < z*) = p, Direct's independent model gives p squared. Direct
underweights every improving candidate. Composite's single GP, pushed
through the known map, samples f1 and f2 perfectly correlated, so its joint
is exact. The gain measures that calibration gap in the acquisition. It says
nothing about information in the intermediates.

In the matched design h0 and h1 are independent, so Direct's independence
assumption holds and the identity row is a true null (+0.01 %).

## Caveats

- The paper's Table 4 design is the one that isolates composition in f1.
  The shared design changes the question to cross-objective dependence.
- Twenty paired runs per map. Standard deviations of 5 to 10 points on
  effects of 1 to 4 points leave most rows underpowered individually.
- p-values are unadjusted across 21 rows.

## Reproduce

```
python composite_ablation/run_two_stage.py --g2 shared --g1 <map> \
    --trials 5 --draws 4 --n-init 10 --n-iter 40 --jobs 6 \
    --out composite_ablation/results/two_stage_shared/<map>.json
python composite_ablation/collect_two_stage.py \
    --out composite_ablation/results/two_stage_shared
python paper_tables.py --mo composite_ablation/results/two_stage_shared --out tables_shared.tex
```

`composite_ablation/results/two_stage_shared/run_grid.ps1` runs all 21 maps
and skips ones already written. One map takes 10 to 25 minutes on six
workers; the grid took 5 h 50 min.
