# BGC-Argo POC flux distribution: phase 1

Log-normal models of particulate organic carbon (POC) flux at 100, 200, 500 and 900 m from BGC-Argo floats, with no
profile effect. Part of a Bayesian statistics course project. The method follows Edwards et al. (2026, GRL).

## Conclusions

1. **Distribution:** per-depth log-normal models reproduce the main body of the flux distribution. P1–P95 are within
   ±30% and K-S is 0.05–0.08.
2. **Upper tail:** it is not reproduced. P99 is 22–29% too low and P99.9 is 51–72% too low.
3. **Why the distribution fits:** mainly because the flux is close to log-normal. One mean and one SD per depth already
   give K-S 0.06–0.08; SST and Chl-a improve it by 0.004–0.015.
4. **Individual values:** within one depth, SST and Chl-a explain 1–9% of the variance of ln F. Depth does most of the work:

   | Prediction, all depths together | Within ±30% | Typical error factor | r² |
   |---|---:|---:|---:|
   | One median, no depth | 20.7% | 1.92 | −0.01 |
   | One median per depth | 63.1% | 1.25 | 0.750 |
   | Per-depth model | 64.3% | 1.24 | 0.767 |
   | All-depth model | 61.1% | 1.26 | 0.750 |

5. **Against Edwards et al.:** K-S is similar (0.040 and 0.044). The depth effect on μ is the same (−0.73), while the SST
   and Chl-a effects are about one eighth of theirs (0.04 against 0.39, 0.10 against 0.73).

## Limits

- All numbers in the notebooks are in-sample. Earlier random 90/10 splits gave similar values, but no split by float has been done.
- There is no float effect, so profiles of one float are treated as independent and posterior widths are too narrow.
- F is not measured directly: F = 5 × sPOC + 12 × lPOC, with assumed sinking speeds in m/d. The results for σ and the upper tail change with these speeds.
- Same-day Chl-a is missing mostly at |lat| > 50°, so high latitudes are under-sampled.

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
