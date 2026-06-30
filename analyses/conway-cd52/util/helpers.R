run_diffcyt_analysis <- function(
    df,
    sample_col = "sample",
    group_col = "group",
    celltype_col = "celltype",
    non_marker_cols = c("cell_id", "optsne_1", "optsne_2",
                        "sample", "condition", "fsom_metaclust",
                        "celltype", "CD52_status", "group"),
    marker_class = "state"
) {
  
  library(dplyr)
  library(diffcyt)
  
  ## ---------------------------
  ## 1. Extract expression matrix
  ## ---------------------------
  expr <- as.matrix(df %>% select(-all_of(non_marker_cols)))
  markers <- colnames(expr)
  
  ## ---------------------------
  ## 2. Split by sample × group (pseudo-samples)
  ## ---------------------------
  split_data <- df %>%
    split(interaction(df[[sample_col]], df[[group_col]], drop = TRUE))
  
  expr_list <- lapply(split_data, function(df_samp) {
    as.matrix(df_samp[, markers, drop = FALSE])
  })
  
  cluster_list <- lapply(split_data, function(df_samp) {
    df_samp[[celltype_col]]
  })
  
  ## ---------------------------
  ## 3. Metadata
  ## ---------------------------
  meta_sample <- data.frame(
    sample_id = names(split_data),
    group = sapply(split_data, function(x) unique(x[[group_col]])),
    stringsAsFactors = FALSE
  )
  
  ## ---------------------------
  ## 4. Prepare SummarizedExperiment
  ## ---------------------------
  d_se <- prepareData(
    d_input = expr_list,
    experiment_info = meta_sample,
    marker_info = data.frame(
      marker_name = markers,
      marker_class = marker_class,
      stringsAsFactors = FALSE
    )
  )
  
  ## attach cluster IDs (cell types)
  rowData(d_se)$cluster_id <- unlist(cluster_list)
  
  ## ---------------------------
  ## 5. Calculate summaries
  ## ---------------------------
  d_counts <- calcCounts(d_se)
  d_medians <- calcMedians(d_se)
  
  ## ---------------------------
  ## 6. Design + contrast
  ## ---------------------------
  design <- createDesignMatrix(meta_sample, cols_design = "group")
  contrast <- createContrast(c(0, 1))  # assumes 2 groups
  
  ## ---------------------------
  ## 7. Run tests
  ## ---------------------------
  res_DA <- testDA_edgeR(d_counts, design, contrast)
  res_DS <- testDS_limma(d_counts, d_medians, design, contrast, plot = FALSE)
  
  ## ---------------------------
  ## 8. Extract test results
  ## ---------------------------
  res_da_tbl <- rowData(res_DA) %>% 
    as.data.frame() %>% 
    tidyr::drop_na() %>% 
    dplyr::mutate(celltype = droplevels(as.factor(cluster_id))) %>%
    arrange(p_adj)
  
  res_ds_tbl <- rowData(res_DS) %>%
    as.data.frame() %>%
    tidyr::drop_na() %>%
    dplyr::mutate(
      celltype = droplevels(as.factor(cluster_id)),
      marker = marker_id
    ) %>%
    arrange(p_adj)
  
  ## ---------------------------
  ## 9. Return results
  ## ---------------------------
  list(
    d_se = d_se,
    d_counts = d_counts,
    d_medians = d_medians,
    design = design,
    contrast = contrast,
    res_DA = res_da_tbl,
    res_DS = res_ds_tbl
  )
}

plot_da_boxplot <- function(
    df,
    res_da_tbl,
    sample_col = "sample",
    group_col = "group",
    celltype_col = "celltype",
    p_col = "p_adj"
) {
  
  library(dplyr)
  library(ggplot2)
  
  ## ---------------------------
  ## 1. Prepare p-values
  ## ---------------------------
  pvals <- res_da_tbl %>%
    dplyr::select(cluster_id, !!p_col) %>%
    dplyr::mutate(
      celltype = cluster_id,
      label = paste0("FDR = ", signif(.data[[p_col]], 2))
    )
  
  ## ---------------------------
  ## 2. Compute proportions
  ## ---------------------------
  df_prop <- df %>%
    dplyr::count(!!sym(sample_col), !!sym(group_col), !!sym(celltype_col)) %>%
    dplyr::group_by(!!sym(sample_col), !!sym(group_col)) %>%
    dplyr::mutate(prop = n / sum(n)) %>%
    dplyr::ungroup()
  
  ## ---------------------------
  ## 3. Join stats
  ## ---------------------------
  df_prop <- df_prop %>%
    left_join(pvals, by = c(celltype_col))
  
  ## ---------------------------
  ## 4. Plot
  ## ---------------------------
  ggplot(df_prop, aes(x = .data[[group_col]], y = prop, fill = .data[[group_col]])) +
    geom_boxplot(outlier.shape = NA, width = 0.6) +
    geom_jitter(width = 0.15, size = 1.5, alpha = 0.8) +
    facet_wrap(as.formula(paste("~", celltype_col)), scales = "free_y") +
    geom_text(
      data = distinct(df_prop, .data[[celltype_col]], label),
      aes(x = 1.5, y = Inf, label = label),
      inherit.aes = FALSE,
      vjust = 1.5,
      size = 3
    ) +
    scale_y_continuous(labels = scales::percent) +
    theme_classic(base_size = 12) +
    labs(
      x = "",
      y = "Proportion",
      title = "Differential Abundance of Cell Types"
    )
}


plot_ds_volcano <- function(df,
                            celltype_name = NULL,
                            marker_col = "marker_id",
                            celltype_col = "celltype",
                            lfc_col = "logFC",
                            p_col = "p_adj",
                            title = NULL,
                            subtitle = "",
                            p_cutoff = 0.05,
                            lfc_cutoff = 0.5,
                            label_top_n = 10) {
  
  # optionally filter for one cell type
  if (!is.null(celltype_name)) {
    df <- df[df[[celltype_col]] == celltype_name, ]
  }
  
  # clean marker names
  df <- df %>%
    mutate(
      marker_clean = gsub(".*___", "", .data[[marker_col]]),
      .p = .data[[p_col]],
      .lfc = .data[[lfc_col]]
    ) %>%
    dplyr::filter(is.finite(.p), is.finite(.lfc), !is.na(.p), !is.na(.lfc))
  
  # define default title
  if (is.null(title)) {
    title <- unique(df[[celltype_col]])
  }
  
  # select top labels
  label_df <- df %>%
    dplyr::filter(.p <= p_cutoff, abs(.lfc) >= lfc_cutoff) %>%
    arrange(.p) %>%
    slice_head(n = label_top_n)
  
  lab_vec <- ifelse(df$marker_clean %in% label_df$marker_clean,
                    df$marker_clean, "")
  
  # plot
  EnhancedVolcano::EnhancedVolcano(
    df,
    lab = lab_vec,
    x = lfc_col,
    y = p_col,
    title = title,
    subtitle = subtitle,
    pCutoff = p_cutoff,
    FCcutoff = lfc_cutoff,
    legendPosition = "bottom",
    pointSize = 2,
    colAlpha = 0.8,
    labSize = 3,
    drawConnectors = TRUE,
    widthConnectors = 0.4,
    colConnectors = "black",
    max.overlaps = Inf,
  )
}
