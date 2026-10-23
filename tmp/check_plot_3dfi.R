.libPaths(c("C:/Users/pablo/AppData/Local/R/win-library/4.5", .libPaths()))

# Load the plotting helper without loading unrelated project dependencies.
for (expr in parse("Scripts/DataAppendixScripts/helpers.R")) {
  if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
      identical(expr[[2]], as.name("plot_3dfi"))) eval(expr)
}
dfi_adjusted <- readRDS("Data/IntermediateData/dfi_adjusted.rds")

# Recreate the previous plot directly from its saved source.
old <- system2("git", c("show", "HEAD:08_model_comparison.qmd"), stdout = TRUE)
Encoding(old) <- "UTF-8"
start <- grep("^# Combine the reference and fair-discrepancy", old)[1]
end <- grep("^# Display the simulated distributions", old)[1] - 1L
eval(parse(text = old[start:end]))
baseline <- ggplot2::ggplot_build(dfi_plot_fair)$data
stopifnot(identical(baseline, ggplot2::ggplot_build(plot_3dfi(dfi_adjusted))$data))
cat("Fair: histogram and cutoff layers identical to previous plot.\n")

# Verify that each option uses its own distributions and dynamic cutoffs.
for (reference in c("Close", "Fair", "Mediocre")) {
  level <- match(reference, c("Close", "Fair", "Mediocre"))
  plot <- plot_3dfi(dfi_adjusted, reference)
  data <- attr(plot, "plot_data")
  cutoffs <- attr(plot, "plot_cutoffs")
  for (index in c("CFI", "RMSEA")) {
    stopifnot(identical(data$Value[data$Model == "Misspecified" & data$Index == index],
      dfi_adjusted$indices[[paste0(index, "_L", level)]]))
    stopifnot(identical(data$Value[data$Model == "True" & data$Index == index],
      dfi_adjusted$indices[[paste0(index, "_L0")]]))
    stopifnot(cutoffs$Cutoff[cutoffs$Index == index &
      cutoffs$Reference == "Dynamic Cutoff"] ==
      as.numeric(dfi_adjusted$cutoffs[reference, index]))
  }
  stopifnot(identical(plot$labels$title, reference))
  ggplot2::ggsave(paste0("tmp/plot-3dfi-", tolower(reference), ".png"),
    plot, width = 10, height = 5, dpi = 120)
  cat(reference, ": source distributions, cutoffs, title and PNG passed.\n")
}

# Reject unsupported levels and incomplete results.
stopifnot(inherits(try(plot_3dfi(dfi_adjusted, "Poor"), silent = TRUE), "try-error"),
  inherits(try(plot_3dfi(list()), silent = TRUE), "try-error"))

# Parse all R chunks without rerunning the simulations.
lines <- readLines("08_model_comparison.qmd", encoding = "UTF-8")
active <- FALSE
for (line in lines) {
  if (!active && grepl("^```\\{r", line)) {
    active <- TRUE
    chunk <- character()
  } else if (active && grepl("^```\\s*$", line)) {
    parse(text = chunk)
    active <- FALSE
  } else if (active) chunk <- c(chunk, line)
}
stopifnot(!active)
cat("Invalid inputs and section R syntax passed.\n")
