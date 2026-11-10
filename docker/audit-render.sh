#!/usr/bin/env bash
set -euo pipefail

cd /home/rstudio
test -d /export/docs || { echo "Missing export directory: /export/docs" >&2; exit 1; }

# Refuse to launch expensive simulations because an expected RDS is absent.
for result in popmodel_101to400 h1model_101to400 popmodel_200 h1model_200 \
  sim_h0_empirical sim_h1_empirical dfi_adjusted perm_metric; do
  test -s "Data/IntermediateData/$result.rds" || {
    echo "Missing distributed result: $result.rds" >&2
    exit 1
  }
done

echo "CFA Tutorial: executing the article with the eight distributed RDS files."
echo "This run renders HTML/PDF; it does not recompute the cached simulations."
su rstudio -c 'cd /home/rstudio && quarto render --to all --execute'

# Export only after both document formats have been produced successfully.
test -s docs/index.html
test -s docs/cfa-tutorial.pdf
su rstudio -c 'cd /home/rstudio && Rscript -' <<'RSCRIPT'
for (source in list.files("Article", "[.]qmd$", full.names = TRUE)) {
  lines <- readLines(source, warn = FALSE)
  labels <- grep("^(#|//)[|] label: fig-", lines, value = TRUE)
  labels <- sub("^(#|//)[|] label: *", "", labels)
  if (!length(labels)) next
  page <- file.path("docs", "Article", paste0(tools::file_path_sans_ext(basename(source)), ".html"))
  document <- xml2::read_html(page)
  for (label in labels) {
    figure <- xml2::xml_find_first(document, sprintf("//*[@id='%s']", label))
    if (inherits(figure, "xml_missing")) stop("Missing figure in HTML: ", label)
    files <- list.files("docs/Output/Results/Figures")
    if (!any(startsWith(files, paste0(label, ".")) |
             grepl(paste0("^", label, "-[0-9]+[.]"), files))) {
      stop("Missing exported figure: ", label)
    }
    resources <- xml2::xml_attr(xml2::xml_find_all(figure, ".//img"), "src")
    if (any(!file.exists(file.path(dirname(page), URLdecode(resources))))) {
      stop("Missing HTML image resource: ", label)
    }
  }
}
cat("All article figures and exported images are present.\n")
RSCRIPT
{
  echo "CFA Tutorial: HTML/PDF render completed successfully."
  echo "Completed (UTC): $(date -u +%FT%TZ)"
  echo "Mode: article execution with eight distributed RDS files."
  quarto --version
  Rscript --vanilla -e 'cat(R.version.string, "\n")'
} > docs/audit-summary.txt
sha256sum _quarto.yml renv.lock index.qmd Article/*.qmd \
  Article/references.bib Article/apa7ed.csl \
  Scripts/DataAppendixScripts/*.R Data/IntermediateData/*.rds \
  > docs/audit-inputs.sha256

cp -R docs/. /export/docs/
chown -R "${AUDIT_UID:-1000}:${AUDIT_GID:-1000}" /export/docs
echo "Audit completed successfully. Results exported to docs/."
