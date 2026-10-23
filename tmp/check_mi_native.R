# Use the existing library without changing the project environment.
.libPaths(c("C:/Users/pablo/AppData/Local/R/win-library/4.5", .libPaths()))
source("Scripts/DataAppendixScripts/models.R")

# Load the old and new MI implementations in separate environments.
load_mi <- function(lines) {
  Encoding(lines) <- "UTF-8"
  env <- new.env()
  for (expr in parse(text = lines)) {
    if (is.call(expr) && identical(expr[[1]], as.name("<-")) &&
        as.character(expr[[2]]) %in% c("tidy_mi", "table_mi")) {
      eval(expr, env)
    }
  }
  env
}
old <- load_mi(system2("git", c("show", "HEAD:Scripts/DataAppendixScripts/helpers.R"), stdout = TRUE))
new <- load_mi(readLines("Scripts/DataAppendixScripts/helpers.R", encoding = "UTF-8"))
cv <- readr::read_csv2("Data/AnalysisData/whoqol_cv.csv", show_col_types = FALSE)

# Compare actual tables, native rankings and complete inline data in both sections.
for (section in c(7, 8)) {
  model <- if (section == 7) analyzemodel else adjustedzemodel
  fit <- lavaan::cfa(model, data = cv[cv$sample_group == section - 7, ],
    estimator = "MLR", missing = "fiml", std.lv = TRUE)
  for (n in list(10, 15, 20, NULL, 10000)) {
    for (lang in c("pt", "en")) {
      before <- old$table_mi(fit, top_n = n, lang = lang)
      after <- new$table_mi(fit, top_n = n, lang = lang)
      stopifnot(identical(as.character(before), as.character(after)),
        identical(attr(before, "table_data"), attr(after, "table_data")))
      cols <- c("lhs", "op", "rhs", "mi", "epc", "sepc.all")
      stopifnot(isTRUE(all.equal(
        as.matrix(attr(before, "mi_data")[, cols]),
        as.matrix(attr(after, "mi_data")[, cols]), check.attributes = FALSE)))
      native <- if (is.null(n)) lavaan::modindices(fit, sort. = TRUE) else
        lavaan::modindices(fit, sort. = TRUE, maximum.number = n)
      stopifnot(nrow(attr(after, "table_data")) == nrow(native))
    }
  }
  cat("Section", section, ": old/new tables identical; full precision data preserved; top 10/15/20/all/10000, pt/en passed.\n")
}

# Parse executable R chunks without running the article simulations.
for (path in c("07_model_fit.qmd", "08_model_comparison.qmd")) {
  lines <- readLines(path, encoding = "UTF-8")
  active <- FALSE
  chunk <- character()
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
  cat(path, ": R chunk syntax passed.\n")
}
