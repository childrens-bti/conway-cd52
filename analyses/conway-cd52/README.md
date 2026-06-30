# CD52 KO Conway flow cytometry analysis

This module analyzes Conway lab CD52 KO spectral flow cytometry data across edited and unedited samples. It compares CD52+ vs CD52- cells, annotates T cell subtypes, and performs subtype-specific differential abundance/state analyses using diffcyt.

## Data inputs

The module expects the v1 data release to be present under `data/v1`.

- `01-cd52-analysis.Rmd` uses summary CSVs from:
  - `data/v1/CD52KO_BC0610/`
  - `data/v1/CD52KO_BC8599/`
  - `data/v1/CD52KO_BC9507/`
- `02-cd52-celltype-de.Rmd` uses annotated cell-level CSVs from:
  - `data/v1/conway-annotated/`

From the repository root, download the data release before running this module:

```bash
bash download_data.sh
```

## Usage

From the repository root:

```bash
cd analyses/conway-cd52
bash run_modules.sh
```

The runner renders both notebooks and writes refreshed HTML, result CSVs, and plot PNGs in this module directory.

## Module contents

- `01-cd52-analysis.Rmd`: Loads Conway CD52 KO processed CSV files, reshapes cluster-level marker summaries, checks CD52 signal patterns, annotates T cell subtypes (CD4 T, CD8 T, gamma-delta T), compares marker distributions between CD52+ control and CD52- KO groups, and reports Wilcoxon test results.
- `02-cd52-celltype-de.Rmd`: Loads Conway CD52 KO annotated cell-level data, defines CD52+ vs CD52- cells, visualizes tSNE distributions, and runs diffcyt DA/DS analyses within T cell subtypes for edited vs unedited and CD52 status comparisons.

## Analysis module directory structure

```
.
├── 01-cd52-analysis.Rmd
├── 01-cd52-analysis.html
├── 02-cd52-celltype-de.Rmd
├── 02-cd52-celltype-de.html
├── README.md
├── run_modules.sh
├── util/
│   └── helpers.R
├── plots/
│   ├── cd4_cd8_composition_by_cd52_status_edited_samples.png
│   ├── cd52plus_vs_cd52neg_KO_diff_abundance_boxplots.png
│   ├── cd52plus_vs_cd52neg_KO_diff_state_volcano_plots.png
│   ├── cd52plus_vs_cd52neg_control_diff_abundance_boxplots.png
│   ├── cd52plus_vs_cd52neg_control_diff_state_volcano_plots.png
│   ├── combined_cd52plus_vs_cd52neg_diff_abundance_boxplots.png
│   ├── control_vs_KO_cd52neg_diff_abundance_boxplots.png
│   ├── control_vs_KO_cd52neg_diff_state_volcano_plots.png
│   ├── control_vs_KO_cd52plus_diff_abundance_boxplots.png
│   ├── control_vs_KO_cd52plus_diff_state_volcano_plots.png
│   ├── tsne_celltype_split.png
│   ├── tsne_condition_split.png
│   └── tsne_plots.png
└── results/
    ├── cd52plus_vs_cd52neg_KO_diff_abundance_results.csv
    ├── cd52plus_vs_cd52neg_KO_diff_state_results.csv
    ├── cd52plus_vs_cd52neg_control_diff_abundance_results.csv
    ├── cd52plus_vs_cd52neg_control_diff_state_results.csv
    ├── control_vs_KO_cd52neg_diff_abundance_results.csv
    ├── control_vs_KO_cd52neg_diff_state_results.csv
    ├── control_vs_KO_cd52plus_diff_abundance_results.csv
    ├── control_vs_KO_cd52plus_diff_state_results.csv
    └── wilcox_results.csv
```
