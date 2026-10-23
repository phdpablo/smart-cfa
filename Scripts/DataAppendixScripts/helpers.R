# =============================================================================
# helpers.R -- Shared packages, constants, and reusable functions
# =============================================================================
# Source it once at the beginning of an analytical section to load
# the packages and objects shared by the project.

# --- Packages ----------------------------------------------------------------

library(lavaan)
library(semTools)
library(semPower)
library(semPlot)
library(simsem)
library(MASS)
library(ggplot2)
library(dplyr)
library(here)
library(knitr)
library(quantreg)
library(parallel)
library(tibble)
library(purrr)
library(stringr)
library(readr)
library(careless)
library(modi)
library(psych)
library(likert)
library(dynamic)

# --- Configuration -----------------------------------------------------------

# Number of Monte Carlo replications at every value of N.
REP <- 10

# Number of Monte Carlo replications at fixed value of N.
SIM <- 1000

# Sample-size sequences.
SEQ <- rep(101:400, each = REP)

# Target N used to inspect power and cutoffs after varying N simulations.
N_TARGET <- 200

# Random seed used by simsem to make the simulations reproducible.
SEED <- 123321

# A priori decision criteria.
ALPHA <- 0.05
POWER <- 0.80

# Number of observed indicators in the four-domain WHOQOL-Bref model.
P <- 24

# Fit indices used to evaluate power and derive model-calibrated cutoffs.
FITS <- c("rmsea", "srmr", "cfi", "tli")
FITS_ROB <- c("rmsea.robust", "srmr", "cfi.robust", "tli.robust")

# Conventional cutoffs retained only as descriptive reference values.
RULE_OF_THUMB <- c(
  rmsea = 0.06,
  cfi = 0.95,
  tli = 0.95,
  srmr = 0.06
)

# Mild non-normality based on Yoshitake et al. (2015). Across the 24 items,
# skewness ranges from -1 to +1 and kurtosis ranges from 1.7 to 2.0.
DIST <- bindDist(
  skewness = seq(-1, 1, length.out = P),
  kurtosis = seq(1.7, 2, length.out = P)
)

# Missing Complete at Random (MCAR) percent
P_MCAR <- 0.10

#
options(max.print = 1e6)

# Named character vector mapping original node names to display labels.
LABELS <- c(
  psycho = "PSI",
  physical = "FIS",
  social = "SOC",
  environment = "AMB"
)

# --- Reusable plotting function ---------------------------------------------

# =============================================================================
# CFA path diagram in color or black and white
# =============================================================================
# Purpose:
# Draw a SEM diagram with consistent styling and optional custom node labels.
#
# Input:
# model: A model specification or fitted object accepted by semPlotModel().
# color: "color" (default) uses automatic latent-group colors; "BW" uses
# white nodes with black edges, borders, and labels.
# what_labels: Edge labels passed to semPaths(); defaults to "est".
# Use "no" to omit numerical labels or "std" for standardized estimates.
# node_labels: Optional named character vector mapping original node names
# to display labels. Unspecified nodes retain their original names.
# layout: Layout passed to semPaths(); defaults to "circle".
#
# Output:
# A path diagram drawn by semPaths(), with its return value passed through.
# In color mode, semPaths() chooses colors automatically for latent groups.
# Original node names are preserved unless explicitly replaced. The function
# does not estimate a model or save a file. In color mode, lines, borders,
# and text use the plotting defaults; BW explicitly makes them black.
#
# Example:
# plot_cfa(fit)
# plot_cfa(popmodel, color = "BW", node_labels = c(
#   psycho = "PSI", physical = "FIS", social = "SOC", environment = "AMB"
# ))
# plot_cfa(adjustedzemodel, color = "color", what_labels = "no")
plot_cfa <- function(
  model,
  what_labels = "est",
  node_labels = NULL,
  layout = "circle",
  color = "color"
) {
  # Select the diagram appearance independently of its model and layout.
  color <- match.arg(color, c("color", "BW"))

  # Convert the supplied model and preserve its original node names.
  plot_model <- semPlot::semPlotModel(model)
  original_names <- plot_model@Vars[["name"]]
  display_labels <- original_names

  # Validate optional replacements and match them by original node name.
  if (!is.null(node_labels)) {
    if (
      !is.character(node_labels) ||
        is.null(names(node_labels)) ||
        anyNA(node_labels) ||
        anyNA(names(node_labels)) ||
        any(names(node_labels) == "") ||
        anyDuplicated(names(node_labels))
    ) {
      stop("node_labels must be a named character vector with unique names.")
    }
    unknown_names <- setdiff(names(node_labels), original_names)
    if (length(unknown_names) > 0) {
      stop("Unknown node names: ", paste(unknown_names, collapse = ", "))
    }
    replacements <- match(original_names, names(node_labels))
    matched <- !is.na(replacements)
    display_labels[matched] <- unname(node_labels[replacements[matched]])
  }

  # Share the model, geometry, and labels between both appearances.
  arguments <- list(
    object = plot_model,
    whatLabels = what_labels,
    style = "lisrel",
    layout = layout,
    intercepts = FALSE,
    thresholds = FALSE,
    residuals = FALSE,
    nodeLabels = display_labels,
    nCharNodes = 0,
    reorder = FALSE,
    sizeLat = 9,
    sizeMan = 5,
    sizeMan2 = 5,
    label.cex = 1.2,
    edge.label.cex = 1.2,
    edge.label.bg = TRUE,
    weighted = FALSE,
    mar = c(2, 1.5, 2, 1.5)
  )

  # Apply automatic group colors or the monochrome publication style.
  if (color == "color") {
    arguments$groups <- "latents"
  } else {
    arguments$color <- "white"
    arguments$edge.color <- "black"
    arguments$border.color <- "black"
    arguments$label.color <- "black"
    arguments$edge.label.color <- "black"
  }
  do.call(semPlot::semPaths, arguments)
}

# --- semPower Output Decoupling Helpers ----------------------------------------

# =============================================================================
# Numeric formatting for analytical power summaries
# =============================================================================
# Purpose:
# Format one numeric value for the semPower summary table.
#
# Input:
# x: A numeric scalar, NULL, or an empty numeric vector.
# digits: Decimal places for fixed notation; defaults to 3.
#
# Output:
# A character value. Missing or empty inputs become NA_character_.
# Positive values below 1e-4 use scientific notation with two decimal places;
# other values use fixed notation. This helper expects at most one value.
#
# Example:
# format_metric_val(0.04912)
format_metric_val <- function(x, digits = 3) {
  # Preserve missing or empty inputs as a missing character value.
  if (is.null(x) || length(x) == 0 || is.na(x)) {
    return(NA_character_)
  }
  # Use scientific notation for small positive values.
  if (abs(x) < 1e-4 && x > 0) {
    return(formatC(x, format = "e", digits = 2))
  }
  # Format the remaining values with the requested decimal places.
  formatC(x, format = "f", digits = digits)
}

# =============================================================================
# Organized analytical power summary
# =============================================================================
# Purpose:
# Extract the selected semPower results and prepare their display values.
#
# Input:
# object: An a priori or post hoc semPower result, including model-based
# results from semPower.powerLav(), with the corresponding result fields.
# lang: Display language, "en" (default) or "pt".
#
# Output:
# Internal helper used automatically by table_sempower().
# A data.frame with Measure, Symbol, Value (en) or Medida, Símbolo, Valor (pt).
# Values are formatted character strings, not full-precision numeric data;
# the original values remain available in object. Optional fit-index rows
# are included when their fields exist. A priori results use requiredN and
# the implied NCP, beta, and power; post hoc results use N, ncp, beta, and power.
# Power above 0.9999 is displayed as "> 0.9999".
#
# Example:
# tidy_sempower(ap_h1model)
tidy_sempower <- function(object, lang = "en") {
  # Validate the display language without changing the numerical results.
  lang <- match.arg(lang, c("en", "pt"))
  # Select the result fields for a priori or post hoc analysis.
  is_apriori <- inherits(object, "semPower.aPriori") ||
    identical(object[["type"]], "a-priori")
  n_label <- if (is_apriori) {
    "Tamanho amostral necessário"
  } else {
    "Tamanho amostral observado"
  }
  n_val <- if (is_apriori) object[["requiredN"]] else object[["N"]]
  ncp_val <- if (is_apriori) object[["impliedNCP"]] else object[["ncp"]]
  beta_val <- if (is_apriori) object[["impliedBeta"]] else object[["beta"]]
  power_val <- if (is_apriori) object[["impliedPower"]] else object[["power"]]

  # Assemble the selected measures and their formatted display values.
  res <- list(
    c(
      "Discrepância populacional",
      "$F_0$",
      format_metric_val(object[["fmin"]])
    ),
    c(
      "Raiz do erro quadrático médio de aproximação",
      "$\\text{RMSEA}$",
      format_metric_val(object[["rmsea"]])
    ),
    c(
      "Índice de centralidade de McDonald",
      "$Mc$",
      format_metric_val(object[["mc"]])
    ),
    if (!is.null(object[["gfi"]])) {
      c(
        "Índice de qualidade do ajuste",
        "$\\text{GFI}$",
        format_metric_val(object[["gfi"]])
      )
    },
    if (!is.null(object[["agfi"]])) {
      c(
        "Índice de qualidade do ajuste ajustado",
        "$\\text{AGFI}$",
        format_metric_val(object[["agfi"]])
      )
    },
    if (!is.null(object[["srmr"]])) {
      c(
        "Raiz do resíduo quadrático médio padronizado",
        "$\\text{SRMR}$",
        format_metric_val(object[["srmr"]])
      )
    },
    if (!is.null(object[["cfi"]])) {
      c(
        "Índice de ajuste comparativo",
        "$\\text{CFI}$",
        format_metric_val(object[["cfi"]])
      )
    },
    c("Graus de liberdade", "$df$", as.character(object[["df"]])),
    c(n_label, "$N$", as.character(n_val)),
    c(
      "Qui-quadrado crítico",
      "$\\chi^2_{\\text{crit}}$",
      format_metric_val(object[["chiCrit"]])
    ),
    c(
      "Parâmetro de não centralidade",
      "$\\lambda$",
      format_metric_val(ncp_val)
    ),
    c(
      "Nível de significância (alfa)",
      "$\\alpha$",
      format_metric_val(object[["alpha"]])
    ),
    c(
      "Erro tipo II (beta)",
      "$\\beta$",
      format_metric_val(beta_val, digits = 4)
    ),
    c(
      "Poder estatístico",
      "$1 - \\beta$",
      if (power_val > 0.9999) {
        "> 0.9999"
      } else {
        format_metric_val(power_val, digits = 4)
      }
    )
  )
  # Remove absent optional measures and name the display columns.
  res <- do.call(rbind, res[!sapply(res, is.null)])
  # Translate only the measure descriptions and column headings.
  if (lang == "en") {
    labels_en <- c(
      "Discrepância populacional" = "Population discrepancy",
      "Raiz do erro quadrático médio de aproximação" = "Root mean square error of approximation",
      "Índice de centralidade de McDonald" = "McDonald centrality index",
      "Índice de qualidade do ajuste" = "Goodness-of-fit index",
      "Índice de qualidade do ajuste ajustado" = "Adjusted goodness-of-fit index",
      "Raiz do resíduo quadrático médio padronizado" = "Standardized root mean square residual",
      "Índice de ajuste comparativo" = "Comparative fit index",
      "Graus de liberdade" = "Degrees of freedom",
      "Tamanho amostral necessário" = "Required sample size",
      "Tamanho amostral observado" = "Observed sample size",
      "Qui-quadrado crítico" = "Critical chi-square",
      "Parâmetro de não centralidade" = "Noncentrality parameter",
      "Nível de significância (alfa)" = "Significance level (alpha)",
      "Erro tipo II (beta)" = "Type II error rate (beta)",
      "Poder estatístico" = "Statistical power"
    )
    res[, 1] <- unname(labels_en[res[, 1]])
    colnames(res) <- c("Measure", "Symbol", "Value")
  } else {
    colnames(res) <- c("Medida", "Símbolo", "Valor")
  }
  as.data.frame(res, stringsAsFactors = FALSE)
}

# =============================================================================
# Formatted analytical power table
# =============================================================================
# Purpose:
# Present the selected semPower results separately from the distribution plot.
#
# Input:
# object: A semPower result supported by tidy_sempower().
# align: Column alignment passed to knitr::kable(); defaults to left,
# center, and right for the measure, symbol, and value columns, respectively.
# lang: Display language, "en" (default) or "pt"; passed to tidy_sempower().
#
# Output:
# A knitr_kable table using the display values from tidy_sempower().
# No model is estimated and no file is saved by this function.
#
# Example:
# table_sempower(ap_h1model)
# table_sempower(ap_h1model, lang = "pt")
table_sempower <- function(object, align = c("l", "c", "r"), lang = "en") {
  # Prepare the selected measures and display values.
  df_tidy <- tidy_sempower(object, lang = lang)
  # Render the table using the requested column alignment.
  knitr::kable(df_tidy, align = align)
}

# =============================================================================
# Analytical power distribution plot
# =============================================================================
# Purpose:
# Draw central and noncentral chi-square distributions without a text summary.
# Plot labels retain the original English wording from semPower.
#
# Input:
# object: A semPower result containing chiCrit, df, and impliedNCP or ncp.
# linewidth: Curve width; defaults to 1.2.
# show_labels: Whether to display the plot labels; defaults to TRUE.
#
# Output:
# A plot drawn by semPower.showPlot(), with its return value passed through.
# Uses impliedNCP when available, otherwise ncp. It does not rerun the power
# analysis or save a figure file.
#
# Example:
# plot_sempower(ap_h1model)
plot_sempower <- function(object, linewidth = 1.2, show_labels = TRUE) {
  # Select the noncentrality parameter available in the result.
  ncp <- if (!is.null(object[["impliedNCP"]])) {
    object[["impliedNCP"]]
  } else {
    object[["ncp"]]
  }
  # Draw the distributions without printing the analytical summary.
  semPower::semPower.showPlot(
    chiCrit = object[["chiCrit"]],
    ncp = ncp,
    df = object[["df"]],
    linewidth = linewidth,
    showLabels = show_labels
  )
}

# --- Table Global Fit --------------------------------------------------------

# =============================================================================
# Organized global fit measures
# =============================================================================
# Purpose:
# Internal helper called automatically by table_fit(). Preserve every measure
# returned by lavaan and identify the eleven measures used in the summary.
#
# Input:
# object: One fitted, converged lavaan model with an available model test.
#
# Output:
# A data.frame with measure, estimate, and selected columns. Estimates retain
# their original numerical precision. The selected_measures attribute gives
# the summary order; test_version and index_version identify its variants.
# Inspect actual corrected tests, rather than inferring robustness from the
# estimator name. Prefer robust CFI/TLI/RMSEA when a corrected test exists;
# otherwise use scaled indices if robust fields are absent. Standard tests
# use standard indices. Missing selected values remain NA with a warning;
# there is no silent substitution of individual measures between variants.
# N is read from lavInspect(object, "ntotal") if fitMeasures() omits it.
# RMSEA uses a 90% CI and a close-fit null of RMSEA <= .05.
# No model is estimated and no file is saved.
#
# Example:
# fit_data <- tidy_fit(fit_adjustedzemodel)
# fit_data[fit_data$selected, ]
tidy_fit <- function(object) {
  # Validate the fitted model before requesting its fit measures.
  if (!inherits(object, "lavaan")) {
    stop("object must be one fitted lavaan model.")
  }
  if (!isTRUE(lavaan::lavInspect(object, "converged"))) {
    stop("Global fit measures require a converged model.")
  }

  # Inspect the actual tests and retain every native numerical measure.
  tests <- lavaan::lavInspect(object, "test")
  corrected_tests <- c(
    "satorra.bentler",
    "yuan.bentler",
    "yuan.bentler.mplus",
    "mean.var.adjusted",
    "scaled.shifted",
    "satterthwaite"
  )
  has_correction <- any(names(tests) %in% corrected_tests)
  measures <- lavaan::fitMeasures(
    object,
    fm.args = list(rmsea.ci.level = 0.90, rmsea.close.h0 = 0.05)
  )
  # Recover the actual sample size when the fit-measure vector omits N.
  if (!"ntotal" %in% names(measures)) {
    measures <- c(
      measures,
      ntotal = as.numeric(
        lavaan::lavInspect(object, "ntotal")
      )
    )
  }
  test_version <- if (has_correction) "scaled" else "standard"
  index_version <- "standard"
  if (has_correction) {
    if (
      any(
        c("cfi.robust", "tli.robust", "rmsea.robust") %in%
          names(measures)
      )
    ) {
      index_version <- "robust"
    } else {
      index_version <- "scaled"
      warning("Robust index fields are absent; using scaled indices.")
    }
  }

  # Select the test and one consistent CFI/TLI/RMSEA family by native names.
  test_suffix <- if (has_correction) ".scaled" else ""
  index_suffix <- if (index_version == "standard") {
    ""
  } else {
    paste0(".", index_version)
  }
  selected_measures <- c(
    "ntotal",
    paste0(c("chisq", "df", "pvalue"), test_suffix),
    paste0(c("cfi", "tli", "rmsea"), index_suffix),
    paste0(c("rmsea.ci.lower", "rmsea.ci.upper", "rmsea.pvalue"), index_suffix),
    "srmr"
  )

  # Preserve unavailable summary fields and flag them without relabeling.
  missing_names <- setdiff(selected_measures, names(measures))
  if (length(missing_names) > 0) {
    measures <- c(
      measures,
      stats::setNames(
        rep(NA_real_, length(missing_names)),
        missing_names
      )
    )
  }
  unavailable <- selected_measures[
    !is.finite(measures[selected_measures])
  ]
  if (length(unavailable) > 0) {
    warning(
      "Unavailable fit measures retained as NA: ",
      paste(unavailable, collapse = ", ")
    )
  }

  # Return full-precision values and metadata for presentation or reuse.
  result <- data.frame(
    measure = names(measures),
    estimate = as.numeric(measures),
    selected = names(measures) %in% selected_measures,
    stringsAsFactors = FALSE
  )
  attr(result, "selected_measures") <- selected_measures
  attr(result, "test_version") <- test_version
  attr(result, "index_version") <- index_version
  result
}

# =============================================================================
# Formatted global fit table
# =============================================================================
# Purpose:
# Present the usual eleven global fit measures for one fitted lavaan model.
#
# Input:
# object: One fitted lavaan model, passed to tidy_fit() automatically.
# lang: Label language, "en" (default) or "pt". Acronyms remain unchanged.
#
# Output:
# A knitr_kable table with compact labels and unchanged index acronyms.
# N and df use
# integer display, other measures three decimals, and p values three
# decimal places with values below .001 displayed as < 0.001.
# Robust/scaled index families are marked in their labels; RMSEA CI bounds
# and its close-fit p value use that same family. SRMR has no robust suffix.
# The table_data attribute contains exactly the displayed labels and values
# for CSV export. The fit_data attribute contains all full-precision measures.
# Original model estimates are not changed; no file is saved.
#
# Example:
# table_fit(fit_adjustedzemodel)
# table_fit(fit_adjustedzemodel, lang = "pt")
# fit_data <- tidy_fit(fit_adjustedzemodel)
table_fit <- function(object, lang = "en") {
  # Obtain all numerical measures and select the standard summary order.
  lang <- match.arg(lang, c("en", "pt"))
  fit_data <- tidy_fit(object)
  selected <- attr(fit_data, "selected_measures")
  values <- fit_data$estimate[match(selected, fit_data$measure)]
  index_version <- attr(fit_data, "index_version")
  test_version <- attr(fit_data, "test_version")

  # Build compact labels without translating standardized index acronyms.
  index_tag <- switch(
    index_version,
    standard = "",
    robust = if (lang == "pt") " (robusto)" else " (robust)",
    scaled = if (lang == "pt") " (ajust.)" else " (scaled)"
  )
  chi_label <- if (test_version == "standard") {
    "χ²"
  } else if (lang == "pt") {
    "χ² ajust."
  } else {
    "χ² scaled"
  }
  labels <- c(
    "N",
    chi_label,
    "df",
    if (lang == "pt") "p-valor" else "p",
    paste0(c("CFI", "TLI", "RMSEA"), index_tag),
    if (lang == "pt") {
      c("RMSEA IC90% inf.", "RMSEA IC90% sup.")
    } else {
      c("RMSEA CI90% low", "RMSEA CI90% up")
    },
    if (lang == "pt") "p (RMSEA ≤ 0,05)" else "p (RMSEA ≤ 0.05)",
    "SRMR"
  )

  # Format a display copy while preserving the original numerical data.
  display <- rep("NA", length(values))
  available <- is.finite(values)
  display[available] <- formatC(values[available], format = "f", digits = 3)
  for (i in c(1L, 3L)) {
    if (available[i]) display[i] <- formatC(values[i], format = "f", digits = 0)
  }
  for (i in c(4L, 10L)) {
    if (available[i]) {
      display[i] <- if (values[i] < 0.001) {
        "< 0.001"
      } else {
        formatC(values[i], format = "f", digits = 3)
      }
    }
  }
  output <- data.frame(labels, display, stringsAsFactors = FALSE)
  names(output) <- if (lang == "pt") {
    c("Medida", "Valor")
  } else {
    c("Measure", "Value")
  }

  # Render the table and retain access to its complete numerical source.
  rendered <- output
  if (knitr::is_latex_output()) {
    rendered[[1]] <- gsub("χ²", "$\\chi^2$", rendered[[1]], fixed = TRUE)
    rendered[[1]] <- gsub("≤", "$\\leq$", rendered[[1]], fixed = TRUE)
  }
  result <- knitr::kable(
    rendered,
    format = "pipe",
    align = c("l", "r"),
    row.names = FALSE
  )
  attr(result, "fit_data") <- fit_data
  attr(result, "table_data") <- output
  result
}

# --- Table Parameters --------------------------------------------------------

# =============================================================================
# Organized model parameters
# =============================================================================
# Purpose:
# Internal helper called automatically by table_par(). Organize native lavaan
# parameters, including fixed rows, with parameter types and construct labels.
#
# Input:
# object: One fitted, converged lavaan model.
#
# Output:
# A data.frame retaining the native parameter estimates, standard errors,
# z statistics, p values, confidence intervals, and standardized estimates.
# Additional columns parameter_type, construct, and fixed support selection.
# Construct labels are original latent-variable names. Observed variables are
# mapped to their loading factors within the same group/level; cross-loaded
# items can have several constructs. Unassociated variables receive NA.
# std.all uses cov.std = TRUE: residual covariances are standardized using
# residual variances. SE, z, and p refer to the unstandardized estimates.
# Defined parameters, scaling parameters, and other unsupported operators are
# preserved in the data but classified as other. No model is fitted or saved.
#
# Example:
# par_data <- tidy_par(fit_adjustedzemodel)
tidy_par <- function(object) {
  # Validate the fitted model and retain its native parameter estimates.
  if (!inherits(object, "lavaan")) {
    stop("object must be one fitted lavaan model.")
  }
  if (!isTRUE(lavaan::lavInspect(object, "converged"))) {
    stop("Parameter summaries require a converged model.")
  }
  result <- lavaan::parameterEstimates(
    object,
    standardized = TRUE,
    cov.std = TRUE,
    remove.nonfree = FALSE,
    output = "data.frame"
  )
  parameters <- lavaan::parTable(object)
  latent_names <- unique(parameters$lhs[parameters$op == "=~"])

  # Match rows to their free/fixed status, respecting group and level keys.
  keys <- intersect(
    c("lhs", "op", "rhs", "group", "level", "block"),
    intersect(names(result), names(parameters))
  )
  row_key <- function(data) {
    do.call(paste, c(lapply(data[keys], as.character), sep = "\034"))
  }
  parameter_row <- match(row_key(result), row_key(parameters))
  result$fixed <- parameters$free[parameter_row] == 0L

  # Classify parameter types without confusing intercepts and thresholds.
  result$parameter_type <- "other"
  result$parameter_type[result$op == "=~"] <- "loadings"
  result$parameter_type[result$op == "~~" & result$lhs != result$rhs] <- "cov"
  result$parameter_type[result$op == "~~" & result$lhs == result$rhs] <- "var"
  result$parameter_type[
    result$op == "~1" &
      !result$lhs %in% latent_names
  ] <- "intercepts"
  result$parameter_type[
    result$op == "~1" &
      result$lhs %in% latent_names
  ] <- "means"
  result$parameter_type[result$op == "|"] <- "thresholds"
  result$parameter_type[result$op == "~"] <- "regressions"

  # Associate each row with constructs in its own model group and level.
  context_keys <- intersect(c("group", "level", "block"), names(result))
  result$construct <- vapply(
    seq_len(nrow(result)),
    function(i) {
      if (result$parameter_type[i] == "loadings") {
        return(result$lhs[i])
      }
      same_context <- rep(TRUE, nrow(result))
      for (key in context_keys) {
        same_context <- same_context & result[[key]] == result[[key]][i]
      }
      nodes <- unique(c(result$lhs[i], result$rhs[i]))
      factors <- unique(c(
        nodes[nodes %in% latent_names],
        result$lhs[same_context & result$op == "=~" & result$rhs %in% nodes]
      ))
      if (length(factors) == 0L) {
        NA_character_
      } else {
        paste(factors, collapse = " / ")
      }
    },
    character(1)
  )
  result
}

# =============================================================================
# Formatted model parameter table
# =============================================================================
# Purpose:
# Present selected parameters using their lavaan relations as identifiers.
#
# Input:
# object: One fitted lavaan model, passed to tidy_par() automatically.
# type: Parameter types to show; defaults to loadings. Accepts a character
# vector containing loadings, cov, var, intercepts, means, thresholds, and
# regressions. all selects those seven types, not unsupported operators.
# lang: Label language, en (default) or pt. Variable names are not translated.
# include_fixed: Include fixed parameters; defaults to FALSE. Setting TRUE
# also adds a Fixed column. A marker loading fixed to 1 is omitted by default.
#
# Output:
# A knitr_kable table with Relation, Estimate, SE, z, and Std.
# Estimates and statistics use three decimals. Rows follow the requested type
# order and retain native order within each type. Group/level columns are
# included when needed to distinguish multiple groups or levels.
# Relations retain lavaan operators instead of separate type/factor columns.
# Std. is std.all, including
# residual correlations for residual covariance rows, not a separate SE/z
# test of the standardized estimate. Missing values display as NA.
# table_data contains exactly the displayed content for CSV export.
# par_data retains every organized native parameter at full precision.
# No parameter estimation or file export is performed by this function.
#
# Example:
# table_par(fit_adjustedzemodel)
# table_par(fit_adjustedzemodel, type = c("loadings", "cov"), lang = "pt")
# table_par(fit_adjustedzemodel, type = "all", include_fixed = TRUE)
table_par <- function(
  object,
  type = "loadings",
  lang = "en",
  include_fixed = FALSE
) {
  # Validate the selection and obtain all organized native parameters.
  lang <- match.arg(lang, c("en", "pt"))
  allowed <- c(
    "loadings",
    "cov",
    "var",
    "intercepts",
    "means",
    "thresholds",
    "regressions"
  )
  if (
    !is.character(type) ||
      length(type) == 0L ||
      anyNA(type) ||
      any(!type %in% c(allowed, "all"))
  ) {
    stop(
      "type must contain loadings, cov, var, intercepts, means, ",
      "thresholds, regressions, or all."
    )
  }
  if (
    !is.logical(include_fixed) ||
      length(include_fixed) != 1L ||
      is.na(include_fixed)
  ) {
    stop("include_fixed must be TRUE or FALSE.")
  }
  if ("all" %in% type) {
    type <- allowed
  }
  type <- unique(type)
  par_data <- tidy_par(object)
  selected <- par_data[par_data$parameter_type %in% type, , drop = FALSE]
  if (!include_fixed) {
    selected <- selected[
      !is.na(selected$fixed) &
        !selected$fixed,
      ,
      drop = FALSE
    ]
  }
  selected <- selected[
    order(match(selected$parameter_type, type)),
    ,
    drop = FALSE
  ]
  if (nrow(selected) == 0L) {
    stop("No parameters match the requested types and fixed/free selection.")
  }

  # Preserve grouping information when several model contexts are present.
  output <- data.frame(row.names = seq_len(nrow(selected)))
  for (key in intersect(c("group", "level", "block"), names(selected))) {
    if (length(unique(par_data[[key]])) > 1L) {
      title <- switch(
        key,
        group = if (lang == "pt") "Grupo" else "Group",
        level = if (lang == "pt") "Nível" else "Level",
        block = if (lang == "pt") "Bloco" else "Block"
      )
      output[[title]] <- selected[[key]]
    }
  }

  # Build relations and display values without changing numerical estimates.
  relation <- paste(selected$lhs, selected$op, selected$rhs)
  relation[selected$op == "~1"] <- paste(
    selected$lhs[selected$op == "~1"],
    "~ 1"
  )
  main <- data.frame(relation = relation, stringsAsFactors = FALSE)
  names(main) <- if (lang == "pt") "Relação" else "Relation"
  for (key in c("est", "se", "z", "std.all")) {
    value <- selected[[key]]
    formatted <- rep("NA", length(value))
    formatted[is.finite(value)] <- formatC(
      value[is.finite(value)],
      format = "f",
      digits = 3
    )
    title <- switch(
      key,
      est = if (lang == "pt") "Estimativa" else "Estimate",
      se = if (lang == "pt") "EP" else "SE",
      z = "z",
      std.all = if (lang == "pt") "Padronizada" else "Std."
    )
    main[[title]] <- formatted
  }
  output <- cbind(output, main)
  if (include_fixed) {
    title <- if (lang == "pt") "Fixado" else "Fixed"
    output[[title]] <- if (lang == "pt") {
      ifelse(selected$fixed, "Sim", "Não")
    } else {
      ifelse(selected$fixed, "Yes", "No")
    }
  }

  # Render the table and retain presentation and numerical data for reuse.
  alignment <- rep("l", ncol(output))
  alignment[match(names(main)[2:5], names(output))] <- "r"
  result <- knitr::kable(output, align = alignment, row.names = FALSE)
  attr(result, "table_data") <- output
  attr(result, "par_data") <- par_data
  result
}

# --- Table Reliability -------------------------------------------------------

# =============================================================================
# Organized score reliability
# =============================================================================
# Purpose:
# Internal helper called automatically by table_reliability(). Calculate
# omega and algebraic GLB for equally weighted factor-specific scores.
#
# Input:
# object: One converged, single-group, first-order CFA with continuous items.
# score_items: Optional named list keyed by original factor names. Each item
# set must match that factor's nonzero/freely estimated indicator set in the
# fitted model. A subset of factors may be requested, but not arbitrary item
# subsets: the native factor omega must correspond to the same score as GLB.
# NULL derives the item sets automatically, including cross-loadings.
#
# Output:
# A data.frame with factor, items, omega, glb, and glb_status. Values retain
# full precision. Attributes score_items, omega_result, and glb_results keep
# item composition and native computational results, including solver status.
# Uses compRelSEM(obs.var = TRUE, tau.eq = FALSE) and glb.algebraic() on the
# corresponding observed covariance blocks from lavInspect(). A cross-loaded
# item can belong to several factor scores; factor names are not translated.
# GLB does not model residual covariances, unlike model-based omega.
# Failed GLB calculations remain NA with a warning and diagnostic details.
# Single-indicator scores have NA reliability with a warning. Coefficients
# outside [0,1] are flagged, not clipped. Ordinal, multigroup, higher-order,
# and structural-regression models are outside this initial implementation.
# No model is estimated, no data are simulated, and no file is saved.
#
# Example:
# reliability_data <- tidy_reliability(fit_adjustedzemodel)
tidy_reliability <- function(object, score_items = NULL) {
  # Validate the model scope before calculating comparable score coefficients.
  if (
    !inherits(object, "lavaan") ||
      !isTRUE(lavaan::lavInspect(object, "converged"))
  ) {
    stop("object must be one converged lavaan CFA model.")
  }
  if (
    lavaan::lavInspect(object, "ngroups") != 1L ||
      lavaan::lavInspect(object, "nlevels") != 1L
  ) {
    stop("This version supports single-group, single-level CFA models.")
  }
  if (length(lavaan::lavNames(object, "ov.ord")) > 0L) {
    stop(
      "This version requires continuous indicators to keep omega and GLB ",
      "on the same observed-score scale."
    )
  }
  parameters <- lavaan::parTable(object)
  latent_names <- unique(parameters$lhs[parameters$op == "=~"])
  if (
    length(latent_names) == 0L ||
      any(parameters$op == "~") ||
      any(parameters$op == "=~" & parameters$rhs %in% latent_names)
  ) {
    stop(
      "This version requires a first-order CFA without structural regressions."
    )
  }

  # Derive each factor's equally weighted score, excluding fixed-zero loadings.
  loadings <- parameters[
    parameters$op == "=~" &
      (parameters$free > 0L | parameters$est != 0),
    ,
    drop = FALSE
  ]
  native_items <- stats::setNames(
    lapply(latent_names, function(factor) {
      unique(loadings$rhs[loadings$lhs == factor])
    }),
    latent_names
  )
  native_items <- native_items[lengths(native_items) > 0L]
  if (is.null(score_items)) {
    score_items <- native_items
  }
  if (
    !is.list(score_items) ||
      length(score_items) == 0L ||
      is.null(names(score_items)) ||
      anyNA(names(score_items)) ||
      any(names(score_items) == "") ||
      anyDuplicated(names(score_items)) ||
      any(!names(score_items) %in% names(native_items))
  ) {
    stop("score_items must be a named list of fitted factor scores.")
  }
  for (factor in names(score_items)) {
    items <- score_items[[factor]]
    if (
      !is.character(items) ||
        anyNA(items) ||
        anyDuplicated(items) ||
        !setequal(items, native_items[[factor]])
    ) {
      stop(
        "score_items for ",
        factor,
        " must match its fitted loading set; refit for a different score."
      )
    }
  }

  # Compute native omega and retrieve the observed item covariance matrix.
  omega_result <- semTools::compRelSEM(object, obs.var = TRUE, tau.eq = FALSE)
  observed_cov <- lavaan::lavInspect(object, "sampstat")$cov
  factors <- names(score_items)
  omega <- as.numeric(omega_result[factors])
  glb <- rep(NA_real_, length(factors))
  glb_status <- rep(NA_integer_, length(factors))
  glb_results <- stats::setNames(vector("list", length(factors)), factors)

  # Compute GLB independently for the identical item set of each factor score.
  for (i in seq_along(factors)) {
    items <- score_items[[i]]
    if (length(items) < 2L) {
      omega[i] <- NA_real_
      glb_results[[i]] <- list(error = "At least two indicators are required.")
      warning(
        "Reliability unavailable for single-indicator score: ",
        factors[i]
      )
      next
    }
    if (!all(items %in% colnames(observed_cov))) {
      stop("Observed covariances are missing for score: ", factors[i])
    }
    result <- tryCatch(
      psych::glb.algebraic(observed_cov[items, items, drop = FALSE]),
      error = function(e) {
        list(glb = NA_real_, status = NA_integer_, error = conditionMessage(e))
      }
    )
    glb_results[[i]] <- result
    if (length(result$status) == 1L) {
      glb_status[i] <- as.integer(result$status)
    }
    if (length(result$glb) == 1L && is.finite(result$glb)) {
      glb[i] <- as.numeric(result$glb)
    } else {
      warning(
        "GLB unavailable for score: ",
        factors[i],
        ". Inspect the glb_results attribute."
      )
    }
    if (is.finite(glb_status[i]) && glb_status[i] != 0L) {
      warning("GLB solver returned status ", glb_status[i], " for ", factors[i])
    }
  }

  # Preserve full-precision results and native diagnostics for inspection.
  result <- data.frame(
    factor = factors,
    items = as.integer(lengths(score_items)),
    omega = omega,
    glb = glb,
    glb_status = glb_status,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
  if (any(!is.finite(result$omega) & result$items > 1L)) {
    warning("Some omega values are unavailable; inspect omega_result.")
  }
  coefficients <- c(result$omega, result$glb)
  if (any(is.finite(coefficients) & (coefficients < 0 | coefficients > 1))) {
    warning("Reliability outside [0,1]; inspect the model and native results.")
  }
  attr(result, "score_items") <- score_items
  attr(result, "omega_result") <- omega_result
  attr(result, "glb_results") <- glb_results
  result
}

# =============================================================================
# Formatted score reliability table
# =============================================================================
# Purpose:
# Present factor-specific item counts, omega, and algebraic GLB.
#
# Input:
# object: A fitted CFA supported by tidy_reliability().
# lang: Label language, en (default) or pt; factor names remain unchanged.
# score_items: Optional factor/item list passed to tidy_reliability().
#
# Output:
# A knitr_kable table with Factor, Items, Omega, and GLB (or Portuguese).
# Counts are integers; coefficients use three decimals; missing values are NA.
# table_data contains exactly the displayed content for CSV export.
# reliability_data retains full-precision results, score composition, native
# omega output, and GLB diagnostics. No file export is performed.
#
# Example:
# table_reliability(fit_adjustedzemodel)
# table_reliability(fit_adjustedzemodel, lang = "pt")
table_reliability <- function(object, lang = "en", score_items = NULL) {
  # Calculate comparable score coefficients through the internal helper.
  lang <- match.arg(lang, c("en", "pt"))
  reliability_data <- tidy_reliability(object, score_items = score_items)

  # Format a display copy while retaining full-precision data separately.
  output <- data.frame(
    factor = reliability_data$factor,
    items = as.character(reliability_data$items),
    stringsAsFactors = FALSE
  )
  for (key in c("omega", "glb")) {
    values <- reliability_data[[key]]
    display <- rep("NA", length(values))
    display[is.finite(values)] <- formatC(
      values[is.finite(values)],
      format = "f",
      digits = 3
    )
    output[[key]] <- display
  }
  names(output) <- if (lang == "pt") {
    c("Fator", "Itens", "Ômega", "GLB")
  } else {
    c("Factor", "Items", "Omega", "GLB")
  }

  # Render the summary and retain its presentation data and diagnostics.
  result <- knitr::kable(
    output,
    align = c("l", "r", "r", "r"),
    row.names = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "reliability_data") <- reliability_data
  result
}

# --- Table Modification Indices ----------------------------------------------

# =============================================================================
# Formatted modification index table
# =============================================================================
# Purpose:
# Format lavaan modification indices and corresponding EPCs.
#
# Input:
# object: One fitted lavaan model, passed directly to lavaan::modindices().
# top_n: Positive whole number of rows to display; defaults to 20. NULL shows
# all relations. Fewer rows are shown when fewer candidates exist.
# lang: Label language, en (default) or pt; variable names are not translated.
#
# Output:
# A knitr_kable table with Relation, MI, EPC, and Std. EPC (or Portuguese),
# ordered by decreasing MI. All numerical columns use three decimal places.
# Group/level/block columns appear when needed to distinguish model contexts.
# table_data contains exactly the displayed content, with plain lavaan
# relation text for CSV export. Tildes are protected only in the Markdown
# rendering copy to prevent interpreting covariance operators as formatting.
# mi_data retains the complete native output at full precision. One native
# call sorts all candidates; head() limits display without recomputing MIs.
# lavaan defaults exclude free parameters and unavailable MIs and provide
# standardized EPCs (sepc.all uses residual variances for covariances).
# MI/EPC concern individual releases; equality constraints need lavTestScore().
# No parameter estimation or file export is performed by this function.
#
# Example:
# table_mi(fit_adjustedzemodel)
# table_mi(fit_adjustedzemodel, top_n = 10, lang = "pt")
# table_mi(fit_adjustedzemodel, top_n = NULL, lang = "pt")
table_mi <- function(object, top_n = 20, lang = "en") {
  # Validate the display options.
  lang <- match.arg(lang, c("en", "pt"))
  if (
    !is.null(top_n) &&
      (!is.numeric(top_n) ||
        length(top_n) != 1L ||
        is.na(top_n) ||
        !is.finite(top_n) ||
        top_n < 1 ||
        top_n != floor(top_n))
  ) {
    stop("top_n must be a positive whole number or NULL.")
  }
  # Keep the native output for inline values and limit only the table rows.
  mi_data <- lavaan::modindices(object, sort. = TRUE)
  selected <- if (is.null(top_n)) mi_data else head(mi_data, top_n)
  if (nrow(selected) == 0L) {
    warning("No modification indices are available for this model.")
  }

  # Preserve grouping information when multiple contexts are present.
  output <- data.frame(row.names = seq_len(nrow(selected)))
  for (key in intersect(c("group", "level", "block"), names(selected))) {
    if (length(unique(mi_data[[key]])) > 1L) {
      title <- switch(
        key,
        group = if (lang == "pt") "Grupo" else "Group",
        level = if (lang == "pt") "Nível" else "Level",
        block = if (lang == "pt") "Bloco" else "Block"
      )
      output[[title]] <- selected[[key]]
    }
  }

  # Format only the selected rows, preserving the numerical source separately.
  relation_title <- if (lang == "pt") "Relação" else "Relation"
  output[[relation_title]] <- paste(selected$lhs, selected$op, selected$rhs)
  for (key in c("mi", "epc", "sepc.all")) {
    value <- selected[[key]]
    display <- rep("NA", length(value))
    display[is.finite(value)] <- formatC(
      value[is.finite(value)],
      format = "f",
      digits = 3
    )
    title <- switch(
      key,
      mi = "MI",
      epc = "EPC",
      sepc.all = if (lang == "pt") "EPC padronizado" else "Std. EPC"
    )
    output[[title]] <- display
  }

  # Protect relation syntax for Markdown while keeping CSV text unencoded.
  rendered <- output
  rendered[[relation_title]] <- gsub(
    "~",
    "&#126;",
    rendered[[relation_title]],
    fixed = TRUE
  )
  alignment <- c(rep("l", ncol(output) - 3L), rep("r", 3L))
  result <- knitr::kable(
    rendered,
    format = "pipe",
    align = alignment,
    row.names = FALSE,
    escape = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "mi_data") <- mi_data
  result
}

# --- Heatmap Correlation Residuals -------------------------------------------

# =============================================================================
# Organized correlation residuals
# =============================================================================
# Purpose:
# Internal helper called automatically by plot_stdres(). Keep one row per
# item pair from the observed-minus-model-implied correlation matrix.
#
# Input:
# object: One converged, single-group, single-level lavaan model supported
# by lavResiduals(). Continuous and ordinal fits use lavaan's own statistics.
# item_order: Optional complete permutation of the indicator names; NULL
# preserves the order returned by lavaan. It does not select a subset.
#
# Output:
# A data.frame with item1, item2, and residual. Item factors retain all levels
# for the plot axes. Only the lower triangle is retained, without diagonal
# or duplicate pairs. Missing/nonfinite pairs are omitted with a warning.
# residual_matrix retains the complete matrix before masking (in the chosen
# order); native_result preserves the original lavResiduals() output.
# Despite the plot_stdres name, type = cor is a difference between two
# correlation matrices, not a residual z statistic or a fitted error
# correlation. Ordinal fits refer to their latent-response correlations.
# No model is estimated, no data are simulated, and no file is saved.
#
# Example:
# residual_data <- tidy_stdres(fit_adjustedzemodel)
tidy_stdres <- function(object, item_order = NULL) {
  # Validate the model scope and extract the native correlation differences.
  if (
    !inherits(object, "lavaan") ||
      !isTRUE(lavaan::lavInspect(object, "converged"))
  ) {
    stop("object must be one converged lavaan model.")
  }
  if (
    lavaan::lavInspect(object, "ngroups") != 1L ||
      lavaan::lavInspect(object, "nlevels") != 1L
  ) {
    stop("This version plots one group and one level at a time.")
  }
  native_result <- lavaan::lavResiduals(
    object,
    type = "cor",
    zstat = FALSE,
    summary = FALSE
  )
  residual_matrix <- as.matrix(native_result$cov)
  if (
    !is.numeric(residual_matrix) ||
      nrow(residual_matrix) < 2L ||
      nrow(residual_matrix) != ncol(residual_matrix)
  ) {
    stop("At least two indicators and a square residual matrix are required.")
  }

  # Apply an explicit indicator order only when it is a complete permutation.
  original_order <- rownames(residual_matrix)
  if (is.null(item_order)) {
    item_order <- original_order
  }
  if (
    !is.character(item_order) ||
      anyNA(item_order) ||
      anyDuplicated(item_order) ||
      length(item_order) != length(original_order) ||
      !setequal(item_order, original_order)
  ) {
    stop("item_order must contain each indicator name exactly once.")
  }
  residual_matrix <- residual_matrix[item_order, item_order, drop = FALSE]

  # Keep one finite value per pair, retaining all item levels for both axes.
  lower <- lower.tri(residual_matrix)
  missing_pairs <- lower & !is.finite(residual_matrix)
  if (any(missing_pairs)) {
    warning(sum(missing_pairs), " nonfinite residual pairs omitted.")
  }
  masked <- residual_matrix
  masked[!lower] <- NA_real_
  result <- as.data.frame(as.table(masked), stringsAsFactors = TRUE)
  names(result) <- c("item1", "item2", "residual")
  result <- result[is.finite(result$residual), , drop = FALSE]
  if (nrow(result) == 0L) {
    stop("No finite correlation residual pairs available.")
  }
  rownames(result) <- NULL
  attr(result, "residual_matrix") <- residual_matrix
  attr(result, "native_result") <- native_result
  result
}

# =============================================================================
# Correlation residual heatmap
# =============================================================================
# Purpose:
# Plot one triangular cell per correlation residual, using absolute magnitude
# for color and signed values for text, as in the tutorial figures.
#
# Input:
# object: One fitted lavaan model, passed to tidy_stdres() automatically.
# item_order: Optional full indicator order passed to tidy_stdres().
# limits: Optional c(0, upper) magnitude limits for comparisons between plots.
# upper must be positive and cover every plotted magnitude. NULL scales to
# the largest absolute residual (or 1 if all residuals are exactly zero).
#
# Output:
# A ggplot object with white-to-red magnitude fill and signed two-decimal
# labels. The diagonal and repeated pairs are omitted; original item order,
# square cells, and top-axis labels follow the existing tutorial design.
# residual_data contains the full-precision plotted pairs and native results;
# residual_matrix contains the complete matrix before masking. The return can
# be customized with ggplot layers or exported explicitly using ggsave().
# These are correlation differences, not residual z scores. No model fitting,
# simulation, file export, or automatic printing occurs inside the function.
#
# Example:
# plot_stdres(fit_adjustedzemodel)
# plot_stdres(fit_adjustedzemodel, limits = c(0, 0.20))
plot_stdres <- function(object, item_order = NULL, limits = NULL) {
  # Extract the plotted pairs and determine a valid absolute-value scale.
  residual_data <- tidy_stdres(object, item_order = item_order)
  largest <- max(abs(residual_data$residual))
  if (is.null(limits)) {
    limits <- c(0, if (largest > 0) largest else 1)
  }
  if (
    !is.numeric(limits) ||
      length(limits) != 2L ||
      anyNA(limits) ||
      any(!is.finite(limits)) ||
      limits[1] != 0 ||
      limits[2] <= 0 ||
      limits[2] < largest
  ) {
    stop("limits must be c(0, upper), covering every absolute residual.")
  }

  # Reproduce the existing triangular heatmap, preserving signed cell labels.
  result <- ggplot2::ggplot(
    residual_data,
    ggplot2::aes(x = item2, y = item1, fill = abs(residual))
  ) +
    ggplot2::geom_tile(color = "white", linewidth = 0.2) +
    ggplot2::geom_text(
      ggplot2::aes(label = sprintf("%.2f", residual)),
      size = 2.2
    ) +
    ggplot2::scale_fill_gradient(
      low = "white",
      high = "#B2182B",
      limits = limits,
      name = "|Residual|"
    ) +
    ggplot2::scale_x_discrete(position = "top", drop = FALSE) +
    ggplot2::scale_y_discrete(drop = FALSE) +
    ggplot2::coord_fixed() +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
      axis.title = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )

  # Retain complete numerical data for inspection and explicit export.
  attr(result, "residual_data") <- residual_data
  attr(result, "residual_matrix") <- attr(residual_data, "residual_matrix")
  result
}

# --- Table 3DFI -------------------------------------------------------------

# =============================================================================
# Organized 3DFI reference cutoffs
# =============================================================================
# Purpose:
# Internal helper called automatically by table_3dfi(). Extract the three
# approximate-fit reference levels from an existing 3DFI calibration.
#
# Input:
# object: A completed 3DFI result with a cutoffs matrix or data.frame.
# Required rows: Close, Fair, Mediocre. Required columns: MAD, Sim. MAD,
# CFI, RMSEA, 90% CI. Extra rows and columns are left in native_result.
#
# Output:
# A data.frame with reference, mad, sim_mad, cfi, rmsea, and rmsea_ci_upper.
# Numerical values retain the precision available in the source. 3DFI may
# already have rounded its character-valued cutoffs; no precision is restored.
# native_result preserves the original cutoff table, including other rows.
# The 90% CI column is the upper confidence limit for RMSEA, not an interval.
# Missing values remain NA with a warning; malformed values are rejected.
# No simulation, model estimation, cache management, or export is performed.
#
# Example:
# dfi_data <- tidy_3dfi(dfi_adjusted)
tidy_3dfi <- function(object) {
  # Validate the native cutoff structure before selecting reference levels.
  if (!is.list(object) || is.null(object$cutoffs)) {
    stop("object must be a completed 3DFI result with cutoffs.")
  }
  native_result <- object$cutoffs
  levels <- c("Close", "Fair", "Mediocre")
  columns <- c("MAD", "Sim. MAD", "CFI", "RMSEA", "90% CI")
  if (
    !(is.matrix(native_result) || is.data.frame(native_result)) ||
      !all(levels %in% rownames(native_result)) ||
      !all(columns %in% colnames(native_result))
  ) {
    stop(
      "cutoffs must contain Close, Fair, Mediocre and the five DDDFI measures."
    )
  }

  # Convert available cutoffs without silently accepting malformed text.
  result <- data.frame(reference = levels, stringsAsFactors = FALSE)
  keys <- c("mad", "sim_mad", "cfi", "rmsea", "rmsea_ci_upper")
  for (i in seq_along(columns)) {
    text <- trimws(as.character(native_result[levels, columns[i]]))
    missing <- is.na(text) | text %in% c("", "NA")
    value <- suppressWarnings(as.numeric(text))
    if (any(!missing & !is.finite(value))) {
      stop("Invalid numerical cutoff in column: ", columns[i])
    }
    value[missing] <- NA_real_
    result[[keys[i]]] <- value
  }
  if (anyNA(result[keys])) {
    warning("Some DDDFI cutoffs are unavailable (NA).")
  }
  attr(result, "native_result") <- native_result
  result
}

# =============================================================================
# Formatted 3DFI reference table
# =============================================================================
# Purpose:
# Present already-calibrated 3DFI cutoffs in a compact, reusable table.
#
# Input:
# object: One completed 3DFI result, passed to tidy_3dfi() automatically.
# lang: Label language, en (default) or pt; index acronyms are preserved.
#
# Output:
# A knitr_kable table with three reference levels, requested and simulated
# MAD, CFI, RMSEA, and the RMSEA 90% CI upper limit, with three decimals.
# table_data contains exactly the displayed labels and formatted cells for
# CSV export or combination with other tables. dfi_data retains numerical
# cutoffs and native row keys, with native_result holding the original table.
# No calibration, cache handling, file export, or model fitting occurs here.
#
# Example:
# table_3dfi(dfi_adjusted)
# table_3dfi(dfi_adjusted, lang = "pt")
table_3dfi <- function(object, lang = "en") {
  # Extract the calibrated reference levels and select presentation labels.
  lang <- match.arg(lang, c("en", "pt"))
  dfi_data <- tidy_3dfi(object)
  output <- data.frame(
    reference = if (lang == "pt") {
      c("Próximo", "Razoável", "Medíocre")
    } else {
      dfi_data$reference
    },
    stringsAsFactors = FALSE
  )

  # Format the same cells used for both display and explicit export.
  for (key in names(dfi_data)[-1L]) {
    value <- dfi_data[[key]]
    display <- rep("NA", length(value))
    display[is.finite(value)] <- formatC(
      value[is.finite(value)],
      format = "f",
      digits = 3
    )
    output[[key]] <- display
  }
  names(output) <- if (lang == "pt") {
    c("Referência", "MAD", "MAD simulado", "CFI", "RMSEA", "RMSEA IC90% sup.")
  } else {
    c("Reference", "MAD", "Sim. MAD", "CFI", "RMSEA", "RMSEA 90% CI upper")
  }
  result <- knitr::kable(
    output,
    format = "pipe",
    align = c("l", rep("r", 5L)),
    row.names = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "dfi_data") <- dfi_data
  result
}

# =============================================================================
# Simulated distributions for a 3DFI reference level
# =============================================================================
# Purpose:
# Plot saved CFI and RMSEA distributions with dynamic and conventional cutoffs.
#
# Input:
# object: One completed 3DFI result containing indices and cutoffs.
# reference: "Close" (L1), "Fair" (L2, default), or "Mediocre" (L3).
# Each selected level is compared with the reference distributions in L0.
#
# Output:
# A ggplot with RMSEA and CFI panels. plot_data and plot_cutoffs retain
# the plotted values; reference records the selected level. SRMR_L* fields
# are not used because this 3DFI implementation stores RMSEA upper limits
# there. No simulation, model fitting, cache handling, or file export occurs.
#
# Example:
# plot_3dfi(dfi_adjusted)
# plot_3dfi(dfi_adjusted, reference = "Close")
# plot_3dfi(dfi_adjusted, reference = "Mediocre")
plot_3dfi <- function(object, reference = "Fair") {
  # Match the named reference to the saved simulation level.
  reference <- match.arg(reference, c("Close", "Fair", "Mediocre"))
  level <- match(reference, c("Close", "Fair", "Mediocre"))
  columns <- c("RMSEA_L0", "CFI_L0", paste0(c("RMSEA_L", "CFI_L"), level))
  if (
    !is.list(object) ||
      !all(columns %in% names(object$indices)) ||
      !reference %in% rownames(object$cutoffs) ||
      !all(c("RMSEA", "CFI") %in% colnames(object$cutoffs))
  ) {
    stop("object must contain saved DDDFI distributions and reference cutoffs.")
  }
  if (
    !all(vapply(object$indices[columns], is.numeric, logical(1))) ||
      any(vapply(object$indices[columns], length, integer(1)) == 0L)
  ) {
    stop("Selected DDDFI distributions must be nonempty numeric vectors.")
  }
  cutoffs <- suppressWarnings(as.numeric(object$cutoffs[
    reference,
    c("RMSEA", "CFI")
  ]))
  if (any(!is.finite(cutoffs))) {
    stop("Selected DDDFI cutoffs must be finite numeric values.")
  }

  # Combine the reference and selected discrepancy distributions.
  dfi_plot_data <- rbind(
    data.frame(
      Model = "Misspecified",
      RMSEA = object$indices[[paste0("RMSEA_L", level)]],
      CFI = object$indices[[paste0("CFI_L", level)]]
    ),
    data.frame(
      Model = "True",
      RMSEA = object$indices$RMSEA_L0,
      CFI = object$indices$CFI_L0
    )
  )

  # Reshape the simulated indices into one row per index and replication.
  dfi_plot_data <- tidyr::pivot_longer(
    dfi_plot_data,
    cols = c(RMSEA, CFI),
    names_to = "Index",
    values_to = "Value"
  )

  # Set the display order of the fit indices.
  dfi_plot_data$Index <- factor(
    dfi_plot_data$Index,
    levels = c("RMSEA", "CFI")
  )

  # Recover dynamic cutoffs and add conventional reference values.
  dfi_plot_cutoffs <- data.frame(
    Index = rep(c("RMSEA", "CFI"), 2),
    Reference = rep(
      c("Hu & Bentler Cutoff", "Dynamic Cutoff"),
      each = 2
    ),
    Cutoff = c(
      0.06,
      0.95,
      as.numeric(object$cutoffs[reference, c("RMSEA", "CFI")])
    )
  )

  # Match the cutoff index order to the plotted distributions.
  dfi_plot_cutoffs$Index <- factor(
    dfi_plot_cutoffs$Index,
    levels = c("RMSEA", "CFI")
  )

  # Plot the distributions and both cutoff references.
  result <- ggplot2::ggplot(
    dfi_plot_data,
    ggplot2::aes(x = Value, fill = Model)
  ) +
    ggplot2::geom_histogram(
      position = "identity",
      alpha = 0.5,
      bins = 30
    ) +
    ggplot2::geom_vline(
      data = dfi_plot_cutoffs,
      ggplot2::aes(xintercept = Cutoff, linetype = Reference),
      linewidth = 0.6
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        "Misspecified" = "#E9798C",
        "True" = "#66C2F5"
      )
    ) +
    ggplot2::scale_linetype_manual(
      breaks = c("Hu & Bentler Cutoff", "Dynamic Cutoff"),
      values = c(
        "Hu & Bentler Cutoff" = "dotted",
        "Dynamic Cutoff" = "longdash"
      )
    ) +
    ggplot2::facet_wrap(
      ~Index,
      scales = "free",
      nrow = 1,
      strip.position = "bottom"
    ) +
    ggplot2::labs(
      title = reference,
      x = NULL,
      y = NULL,
      fill = NULL,
      linetype = NULL
    ) +
    ggplot2::theme_classic() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      strip.background = ggplot2::element_blank(),
      strip.placement = "outside",
      legend.position = "bottom"
    )
  # Preserve the plotted inputs for inspection.
  attr(result, "plot_data") <- dfi_plot_data
  attr(result, "plot_cutoffs") <- dfi_plot_cutoffs
  attr(result, "reference") <- reference
  result
}

# --- Model comparison tables -------------------------------------------------

# =============================================================================
# Shared inputs for model comparison tables
# =============================================================================
# Input: A list of two or more fitted lavaan models in increasing restriction order.
# Output: Named fits with matching observed data and strictly increasing df.
# Model names are preserved as row labels. No model is estimated or changed.
.comparison_models <- function(object) {
  if (
    !is.list(object) ||
      length(object) < 2L ||
      !all(vapply(object, inherits, logical(1), what = "lavaan"))
  ) {
    stop("Supply a list of at least two fitted lavaan models.")
  }
  if (is.null(names(object))) {
    names(object) <- paste("Model", seq_along(object))
  }
  if (
    anyNA(names(object)) ||
      any(!nzchar(names(object))) ||
      anyDuplicated(names(object))
  ) {
    stop("Model names must be nonempty and unique.")
  }
  if (
    !all(vapply(
      object,
      function(x) lavaan::lavInspect(x, "converged"),
      logical(1)
    ))
  ) {
    stop("All models must have converged.")
  }

  # Reject comparisons across different variables, observations, or groups.
  reference <- object[[1L]]
  for (fit in object[-1L]) {
    same_data <- identical(
      lavaan::lavInspect(reference, "data"),
      lavaan::lavInspect(fit, "data")
    )
    same_groups <- identical(
      lavaan::lavInspect(reference, "group.label"),
      lavaan::lavInspect(fit, "group.label")
    )
    if (!same_data || !same_groups) {
      stop("Models must use the same observed variables, cases, and groups.")
    }
  }
  dfs <- vapply(
    object,
    function(x) lavaan::lavInspect(x, "test")[[1L]]$df,
    numeric(1)
  )
  if (any(diff(dfs) <= 0)) {
    stop(
      "Supply nested models in strictly increasing degrees-of-freedom order."
    )
  }
  object
}

# =============================================================================
# Organized likelihood-ratio comparison
# =============================================================================
# Purpose: Extract individual tests and consecutive native difference tests.
# Input: object is a named list of nested lavaan fits, least restricted first.
# Output: Full-precision model, chisq, df, delta_chisq, delta_df, p_difference,
# aic, and bic. Native LRT output and test version are retained as attributes.
# Individual corrected statistics come from each fit, not the LRT Chisq column.
# The first row has no difference test. No fitting, simulation, or export occurs.
tidy_lrt <- function(object) {
  object <- .comparison_models(object)
  tests <- lapply(object, function(x) lavaan::lavInspect(x, "test"))
  corrected <- vapply(tests, function(x) length(x) > 1L, logical(1))
  if (length(unique(corrected)) != 1L) {
    stop("All models must use the same standard or corrected test family.")
  }

  # Read fitted test statistics directly, without recalculating fit indices.
  selected <- lapply(tests, function(x) x[[length(x)]])
  result <- data.frame(
    model = names(object),
    chisq = vapply(selected, function(x) x$stat, numeric(1)),
    df = vapply(selected, function(x) x$df, numeric(1)),
    delta_chisq = NA_real_,
    delta_df = NA_real_,
    p_difference = NA_real_,
    aic = vapply(object, stats::AIC, numeric(1)),
    bic = vapply(object, stats::BIC, numeric(1)),
    stringsAsFactors = FALSE
  )
  native <- do.call(lavaan::lavTestLRT, unname(object))
  result$delta_chisq <- native[["Chisq diff"]]
  result$delta_df <- native[["Df diff"]]
  result$p_difference <- native[["Pr(>Chisq)"]]
  attr(result, "native_result") <- native
  attr(result, "test_version") <- if (corrected[1L]) "scaled" else "standard"
  result
}

# =============================================================================
# Formatted likelihood-ratio comparison table
# =============================================================================
# Purpose: Present model tests and consecutive difference tests compactly.
# Input: object is an ordered list of nested lavaan fits; lang is en or pt.
# information = TRUE adds AIC/BIC; FALSE (default) keeps six compact columns.
# Output: knitr_kable; table_data holds displayed cells and lrt_data retains
# full-precision values, native LRT output, and standard/corrected test metadata.
# The corrected individual chi-square is labeled scaled; the difference test
# uses lavaan's correction. Missing cells use an em dash. No fitting or export.
# Example: table_lrt(list(Configural = fit_configural, Metric = fit_metric))
# Example: table_lrt(fits, lang = "pt", information = TRUE)
table_lrt <- function(object, lang = "en", information = FALSE) {
  lang <- match.arg(lang, c("en", "pt"))
  if (
    !is.logical(information) || length(information) != 1L || is.na(information)
  ) {
    stop("information must be TRUE or FALSE.")
  }
  data <- tidy_lrt(object)
  columns <- c(
    "model",
    "chisq",
    "df",
    "delta_chisq",
    "delta_df",
    "p_difference"
  )
  if (information) {
    columns <- c(columns, "aic", "bic")
  }
  output <- data[columns]

  # Format a display copy while retaining numerical precision in lrt_data.
  for (name in setdiff(columns, "model")) {
    x <- output[[name]]
    digits <- if (name %in% c("df", "delta_df")) 0L else 3L
    display <- rep("—", length(x))
    available <- is.finite(x)
    display[available] <- formatC(x[available], format = "f", digits = digits)
    if (name == "p_difference") {
      display[available & x < 0.001] <- "< 0.001"
    }
    output[[name]] <- display
  }
  adjusted <- attr(data, "test_version") == "scaled"
  chi <- if (adjusted) "χ² ajust." else "χ²"
  delta <- if (adjusted) "Δχ² ajust." else "Δχ²"
  if (lang == "en" && adjusted) {
    chi <- "χ² scaled"
    delta <- "Δχ² scaled"
  }
  names(output) <- c(
    if (lang == "pt") "Modelo" else "Model",
    chi,
    "gl",
    delta,
    "Δgl",
    if (lang == "pt") "p da diferença" else "p difference",
    if (information) c("AIC", "BIC")
  )
  if (lang == "en") {
    names(output)[c(3L, 5L)] <- c("df", "Δdf")
  }

  # Render Unicode labels as mathematical symbols in PDF tables.
  rendered <- output
  if (knitr::is_latex_output()) {
    names(rendered) <- gsub(
      "Δχ²",
      "$\\Delta\\chi^2$",
      names(rendered),
      fixed = TRUE
    )
    names(rendered) <- gsub("χ²", "$\\chi^2$", names(rendered), fixed = TRUE)
    names(rendered) <- gsub("Δ", "$\\Delta$", names(rendered), fixed = TRUE)
    rendered[] <- lapply(rendered, function(x) gsub("—", "--", x, fixed = TRUE))
  }
  result <- knitr::kable(
    rendered,
    format = "pipe",
    align = c("l", rep("r", ncol(rendered) - 1L)),
    row.names = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "lrt_data") <- data
  result
}

# --- Fit index changes -------------------------------------------------------

# =============================================================================
# Organized fit indices and consecutive changes
# =============================================================================
# Purpose: Pair CFI, RMSEA, and SRMR with changes relative to the preceding fit.
# Input: object is an ordered list of nested lavaan fits, least restricted first.
# Output: Full-precision model, cfi, delta_cfi, rmsea, delta_rmsea, srmr,
# delta_srmr. Changes are current minus previous, calculated before rounding.
# index_version records the robust, scaled, or standard CFI/RMSEA family.
# Missing robust indices remain NA, without silent substitution by other indices.
tidy_fit_changes <- function(object) {
  object <- .comparison_models(object)
  summaries <- lapply(object, tidy_fit)
  versions <- vapply(summaries, attr, character(1), which = "index_version")
  if (length(unique(versions)) != 1L) {
    stop("All models must use the same fit-index family.")
  }
  suffix <- if (versions[1L] == "standard") "" else paste0(".", versions[1L])
  values <- lapply(summaries, function(x) {
    stats::setNames(x$estimate, x$measure)
  })
  cfi <- vapply(
    values,
    function(x) unname(x[paste0("cfi", suffix)]),
    numeric(1)
  )
  rmsea <- vapply(
    values,
    function(x) unname(x[paste0("rmsea", suffix)]),
    numeric(1)
  )
  srmr <- vapply(values, function(x) unname(x["srmr"]), numeric(1))
  result <- data.frame(
    model = names(object),
    cfi = cfi,
    delta_cfi = c(NA_real_, diff(cfi)),
    rmsea = rmsea,
    delta_rmsea = c(NA_real_, diff(rmsea)),
    srmr = srmr,
    delta_srmr = c(NA_real_, diff(srmr)),
    stringsAsFactors = FALSE
  )
  attr(result, "index_version") <- versions[1L]
  result
}

# =============================================================================
# Formatted fit-index changes table
# =============================================================================
# Purpose: Interleave each fit index and its signed consecutive change.
# Input: object is an ordered list of nested lavaan fits; lang is en or pt.
# Output: knitr_kable with three decimals for indices and four for changes.
# table_data holds displayed cells; fit_data retains full-precision values and
# the index family. Model labels come directly from the named input list.
# No model fitting, simulation, file export, or cache handling occurs.
# Example: table_fit_changes(fits, lang = "pt")
table_fit_changes <- function(object, lang = "en") {
  lang <- match.arg(lang, c("en", "pt"))
  data <- tidy_fit_changes(object)
  output <- data

  # Distinguish unavailable indices from the absent first-row comparison.
  for (name in names(data)[-1L]) {
    x <- data[[name]]
    change <- startsWith(name, "delta_")
    display <- rep("NA", length(x))
    available <- is.finite(x)
    display[available] <- formatC(
      x[available],
      format = "f",
      digits = if (change) 4L else 3L,
      flag = if (change) "+" else ""
    )
    if (change) {
      display[1L] <- "—"
    }
    output[[name]] <- display
  }
  names(output) <- c(
    if (lang == "pt") "Modelo" else "Model",
    "CFI",
    "ΔCFI",
    "RMSEA",
    "ΔRMSEA",
    "SRMR",
    "ΔSRMR"
  )
  rendered <- output
  if (knitr::is_latex_output()) {
    names(rendered) <- gsub("Δ", "$\\Delta$", names(rendered), fixed = TRUE)
    rendered[] <- lapply(rendered, function(x) gsub("—", "--", x, fixed = TRUE))
  }
  result <- knitr::kable(
    rendered,
    format = "pipe",
    align = c("l", rep("r", 6L)),
    row.names = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "fit_data") <- data
  result
}

# --- Permutation comparison table --------------------------------------------

# =============================================================================
# Organized permutation differences and empirical p values
# =============================================================================
# Purpose: Extract the already-computed omnibus permutation results.
# Input: One semTools permuteMeasEq object. No permutations are performed.
# Output: Full-precision index, difference, and p_value columns; convergence
# counts are retained in the permutations attribute. Native index names remain
# available. Empirical p values are extracted unchanged, without recalculation.
tidy_permutation <- function(object) {
  if (!inherits(object, "permuteMeasEq")) {
    stop("Supply a completed semTools permuteMeasEq object.")
  }
  observed <- object@AFI.obs
  p_values <- object@AFI.pval
  if (!length(observed) || !all(names(observed) %in% names(p_values))) {
    stop("Observed differences and matching permutation p values are required.")
  }
  result <- data.frame(
    index = names(observed),
    difference = as.numeric(observed),
    p_value = as.numeric(p_values[names(observed)]),
    stringsAsFactors = FALSE
  )
  attr(result, "permutations") <- c(
    requested = object@n.Permutations,
    converged = object@n.Converged
  )
  result
}

# =============================================================================
# Formatted permutation comparison table
# =============================================================================
# Purpose: Display index differences and empirical permutation p values.
# Input: object is a completed permuteMeasEq result; lang is en or pt.
# Output: knitr_kable with four decimals for differences and three for p values.
# table_data preserves displayed cells; permutation_data retains full precision,
# original index names, and requested/converged counts. A zero empirical p value
# is displayed as 0.000, without assigning precision below the permutation grid.
# No fitting, permutation, plotting, cache management, or file export occurs.
# Example: table_permutation(perm_metric, lang = "pt")
table_permutation <- function(object, lang = "en") {
  lang <- match.arg(lang, c("en", "pt"))
  data <- tidy_permutation(object)
  labels <- data$index
  labels <- gsub(
    ".robust",
    if (lang == "pt") " (robusto)" else " (robust)",
    labels,
    fixed = TRUE
  )
  labels <- gsub(
    ".scaled",
    if (lang == "pt") " (ajust.)" else " (scaled)",
    labels,
    fixed = TRUE
  )
  labels <- sub("^cfi", "CFI", labels)
  labels <- sub("^tli", "TLI", labels)
  labels <- sub("^rmsea", "RMSEA", labels)
  labels <- sub("^srmr", "SRMR", labels)

  # Format display values without losing the numerical source.
  difference <- rep("NA", nrow(data))
  p_value <- rep("NA", nrow(data))
  available <- is.finite(data$difference)
  difference[available] <- formatC(
    data$difference[available],
    format = "f",
    digits = 4,
    flag = "+"
  )
  available <- is.finite(data$p_value)
  p_value[available] <- formatC(
    data$p_value[available],
    format = "f",
    digits = 3
  )
  output <- data.frame(labels, difference, p_value, stringsAsFactors = FALSE)
  names(output) <- if (lang == "pt") {
    c("Índice", "Δ observado", "p da permutação")
  } else {
    c("Index", "Observed Δ", "Permutation p")
  }
  rendered <- output
  if (knitr::is_latex_output()) {
    names(rendered) <- gsub("Δ", "$\\Delta$", names(rendered), fixed = TRUE)
  }
  result <- knitr::kable(
    rendered,
    format = "pipe",
    align = c("l", "r", "r"),
    row.names = FALSE
  )
  attr(result, "table_data") <- output
  attr(result, "permutation_data") <- data
  result
}
