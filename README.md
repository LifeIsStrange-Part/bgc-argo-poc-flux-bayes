# BGC-Argo POC flux distribution

Log-normal models of particulate organic carbon (POC) flux at 100, 200, 500 and 900 m from BGC-Argo floats, with no
profile effect. Part of a Bayesian statistics course project. The method follows Edwards et al. (2026, GRL).

## Status (2026-11-04)

| Part | Status |
|---|---|
| Data cleaning (steps 0–2) | Done; can be reused |
| One log-normal model per depth (step 3) | Done |
| All depths in one model, comparison with Edwards et al. (step 4) | Done |
| Test on floats the model has not seen | Not done |
| Profile effect (the core of the proposal) | Not started |

Steps 3–4 are one way to fit the data, not a template. The next parts can use a different approach.

## Data

| Quantity | Source |
|---|---|
| POC flux F, date, position | BGC-Argo floats: BBP converted to sPOC and lPOC concentrations by the existing pipeline (Galí et al. 2022) |
| Chl-a | Satellite, not the float: [Copernicus GlobColour](https://data.marine.copernicus.eu/product/OCEANCOLOUR_GLO_BGC_L4_MY_009_104/description), `cmems_obs-oc_glo_bgc-plankton_my_l4-gapfree-multi-4km_P1D` |
| SST | Satellite, not the float: [NOAA OISST](https://www.ncei.noaa.gov/products/optimum-interpolation-sst), daily |

- Flux: F = 5 × sPOC + 12 × lPOC, in mmol C m⁻² d⁻¹. The sinking speeds of 5 and 12 m/d are assumed, not measured.
- Each depth value is the arithmetic mean over ±10 dbar.
- Chl-a and SST are the same-day median in a ±0.5° box around the profile. `source_data_perdepth.xlsx` also holds 1° monthly means, which are not used in the notebooks.
- Edwards et al. use other products (OC-CCI v6 for Chl-a, Merged Hadley-NOAA/OI for SST) at 1° monthly resolution.

## Data cleaning

Rows left after each rule, applied in order:

| Rule | 100 m | 200 m | 500 m | 900 m |
|---|---:|---:|---:|---:|
| All profiles | 80,645 | 80,645 | 80,645 | 80,645 |
| F exists | 80,573 | 80,359 | 78,903 | 77,439 |
| Median BBP below 500 dbar ≤ 0.005 m⁻¹, or no data there | 80,462 | 80,248 | 78,792 | 77,331 |
| Same-day SST exists | 79,127 | 78,913 | 77,448 | 75,993 |
| Same-day Chl-a exists | 75,276 | 75,062 | 73,614 | 72,170 |

- lPOC is averaged over `zoo_excluded = 0` levels only; sPOC is averaged over all levels.
- The deep BBP rule removes whole profiles and is what removes the extreme values: without it the largest F is 1.7–7.6 × 10⁶, with it 298–852. The tail of deep BBP is continuous, so 0.005 is a choice, not a natural break.
- No low-value cut and no percentile cut are applied.

## Models

```
ln F ~ Normal(mu, sigma)
Step 3, per depth:  mu, ln sigma = linear in T, C, T C
Step 4, all depths: mu, ln sigma = linear in T, C, Z, T C, T Z, C Z
T = ln(SST + 2), C = ln(Chl-a), Z = ln(depth), each standardized
```

Stan NUTS, 4 chains, 1000 warm-up and 1000 sampling iterations, priors Normal(0, 5) on mu terms and Normal(0, 2) on ln sigma terms. All fits converged: R-hat ≤ 1.003, ESS above 2,300, no divergent transitions.

Differences from Edwards et al.: ln σ instead of σ is linear in the predictors, weakly informative priors, SST + 2 instead of SST + 1.79, same-day instead of monthly predictors, and four fixed depths.

## Results

| Per-depth model (step 3) | 100 m | 200 m | 500 m | 900 m |
|---|---:|---:|---:|---:|
| K-S with σ | 0.048 | 0.053 | 0.070 | 0.075 |
| K-S with σ = 0 | 0.426 | 0.300 | 0.223 | 0.221 |
| K-S with no predictors | 0.057 | 0.068 | 0.076 | 0.079 |
| Model / observed at P50 | 1.03 | 1.02 | 1.02 | 1.02 |
| Model / observed at P99 | 0.78 | 0.78 | 0.71 | 0.73 |
| Model / observed at P99.9 | 0.49 | 0.37 | 0.31 | 0.28 |
| r², σ = 0 | 0.01 | 0.08 | 0.09 | 0.09 |
| Within ±30%: model | 56.4% | 64.7% | 68.7% | 67.6% |
| Within ±30%: depth median only | 57.0% | 63.8% | 66.6% | 65.0% |

1. **Distribution:** the main body is reproduced. P1–P95 are within ±30%.
2. **Upper tail:** it is not reproduced. P99 is 22–29% too low and P99.9 is 51–72% too low.
3. **Why the distribution fits:** mainly because the flux is close to log-normal. One mean and one SD per depth, taken from the POC data, already give K-S 0.06–0.08. SST and Chl-a improve it by 0.004–0.015.
4. **Individual values, within one depth:** SST and Chl-a explain 1–9% of the variance of ln F, and the model is almost no better than one median per depth.
5. **Individual values, all depths together:** depth does most of the work.

   | Prediction | Within ±30% | Typical error factor | r² |
   |---|---:|---:|---:|
   | One median, no depth | 20.7% | 1.92 | −0.01 |
   | One median per depth | 63.1% | 1.25 | 0.750 |
   | Per-depth model | 64.3% | 1.24 | 0.767 |
   | All-depth model | 61.1% | 1.26 | 0.750 |

6. **Against Edwards et al.:**

   | | This work (step 4) | Edwards et al. |
   |---|---:|---:|
   | Observations | 296,122 | 12,936 |
   | K-S with σ / σ = 0 | 0.040 / 0.138 | 0.044 / 0.12 |
   | r with σ / σ = 0 | 0.75 / 0.87 | 0.45 / 0.68 |
   | SST, Chl-a, depth effect on μ | 0.04, 0.10, −0.73 | 0.39, 0.73, −0.73 |

   Our SST and Chl-a effects are clearly smaller than those they report. Each effect is per 1 SD of the predictor in its own data set, so the exact ratio cannot be read from these numbers. Our r comes mostly from four widely spaced depths, and they do not report how much of their r comes from depth alone.

## Limits

- All numbers in the notebooks are in-sample. Earlier random 90/10 splits gave similar values (K-S 0.049–0.079), but those splits share floats between training and test data.
- There is no float effect, so profiles of one float are treated as independent and posterior widths are too narrow.
- The results for σ and the upper tail change with the sinking speeds. With 5 and 74 m/d, median σ is 0.53–0.68 and K-S at 500 and 900 m falls to about 0.035, while the P99 ratio drops to 0.62–0.72. This run is not in this repository.
- Same-day Chl-a is missing mostly at |lat| > 50°, so high latitudes are under-sampled.
- Each profile appears up to four times in step 4.
- The density scatter in `step4_pooled_fit.ipynb` has a colour scale that saturates at 800, while the largest count is 10,202.

## Open tasks

1. **Unseen floats:** hold out whole floats and check whether the results hold.
2. **Weak SST and Chl-a:** try monthly satellite values, Chl-a from days or weeks earlier, or the float's own temperature and chlorophyll. The float chlorophyll needs care: check that adjusted values are used, because the existing pipeline stored raw ones.
3. **Flux values:** compare with sediment trap data, and test other sinking speeds.
4. **Upper tail:** try a heavier-tailed distribution, e.g. Student-t.
5. **Profile effect:** is a high profile high at all depths, and does this capture the highest values?

## Files

| File | Content |
|---|---|
| `step0-2_data_cleaning.ipynb` | Source data, raw distributions, data cleaning |
| `step3_fit_model.ipynb` | One model per depth |
| `step4_pooled_fit.ipynb` | All depths in one model, comparison with Edwards et al. |
| `source_data_perdepth.xlsx` | Per-depth values and profile information (README sheet explains the columns) |
| `cleaned_data.csv` | The rows used in the fits |
| `source/` | Input tables for step 0: per-depth concentrations, deep BBP, profile tags, SST and Chl-a |
| `model/` | Stan model |
| `fits/`, `figures/` | Posterior draws and figures |

## Running the notebooks

Run them from the repository folder, in order. Steps 3 and 4 need CmdStan, and they refit the models, so they take several minutes per fit.

```
pip install numpy pandas scipy matplotlib seaborn cmcrameri openpyxl xlsxwriter cmdstanpy ipykernel
python -m cmdstanpy.install_cmdstan
```

The per-level profile files are not included: `source/` starts from ±10 dbar window means.
