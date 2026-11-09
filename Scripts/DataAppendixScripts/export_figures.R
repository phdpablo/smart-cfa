# Export the figures already rendered by Quarto, without running analyses.
export_figures <- function(output_dir = "docs") {
  # Preserve existing files when their bytes already match the source.
  copy_if_changed <- function(source, target) {
    if (file.exists(target) &&
        identical(unname(tools::md5sum(source)), unname(tools::md5sum(target)))) {
      return(invisible(FALSE))
    }
    if (!file.copy(source, target, overwrite = TRUE)) {
      stop("Could not copy figure to: ", target)
    }
    invisible(TRUE)
  }
  figure_dir <- file.path("Output", "Results", "Figures")
  published_dir <- file.path(output_dir, figure_dir)
  sources <- list.files("Article", pattern = "\\.qmd$", full.names = TRUE)
  exported <- character()

  for (source in sources) {
    source_text <- readLines(source, warn = FALSE, encoding = "UTF-8")
    label_lines <- grep(
      "^(#|//)\\| label: fig-", source_text, value = TRUE
    )
    labels <- sub("^(#|//)\\| label: *", "", label_lines)
    if (!length(labels)) next

    html_file <- file.path(
      output_dir, "Article",
      paste0(tools::file_path_sans_ext(basename(source)), ".html")
    )
    if (!file.exists(html_file)) next
    document <- xml2::read_html(html_file)

    for (label in labels) {
      figure <- xml2::xml_find_first(
        document, sprintf("//*[@id='%s']", label)
      )
      if (inherits(figure, "xml_missing")) {
        stop("Figure absent from rendered HTML: ", label)
      }
      images <- xml2::xml_find_all(
        figure, ".//img[contains(@class, 'figure-img')]"
      )
      vectors <- xml2::xml_find_all(figure, ".//*[local-name()='svg']")
      if (!length(images) && !length(vectors)) {
        stop("No graphic resource found for: ", label)
      }
      dir.create(figure_dir, recursive = TRUE, showWarnings = FALSE)
      dir.create(published_dir, recursive = TRUE, showWarnings = FALSE)

      for (i in seq_along(images)) {
        resource <- URLdecode(xml2::xml_attr(images[[i]], "src"))
        original <- file.path(dirname(html_file), resource)
        if (!file.exists(original)) stop("Missing figure resource: ", original)
        suffix <- if (length(images) > 1L) paste0("-", i) else ""
        filename <- paste0(label, suffix, ".", tools::file_ext(resource))
        target <- file.path(figure_dir, filename)

        # Keep the higher-resolution files explicitly saved by the QMD.
        explicit <- any(grepl(paste0('"', filename, '"'), source_text, fixed = TRUE))
        if (!explicit || !file.exists(target)) {
          copy_if_changed(original, target)
        }
        copy_if_changed(target, file.path(published_dir, filename))
        exported <- c(exported, filename)
      }

      for (i in seq_along(vectors)) {
        suffix <- if (length(vectors) > 1L) paste0("-", i) else ""
        filename <- paste0(label, suffix, ".svg")
        target <- file.path(figure_dir, filename)
        vector <- vectors[[i]]
        # HTML parsing lowercases this case-sensitive SVG attribute.
        view_box <- xml2::xml_attr(vector, "viewbox")
        if (!is.na(view_box)) {
          xml2::xml_attr(vector, "viewBox") <- view_box
          xml2::xml_attr(vector, "viewbox") <- NULL
        }
        gradients <- xml2::xml_find_all(vector, ".//lineargradient")
        for (gradient in gradients) {
          xml2::xml_name(gradient) <- "linearGradient"
          units <- xml2::xml_attr(gradient, "gradientunits")
          if (!is.na(units)) {
            xml2::xml_attr(gradient, "gradientUnits") <- units
            xml2::xml_attr(gradient, "gradientunits") <- NULL
          }
        }
        temporary_svg <- tempfile(fileext = ".svg")
        tryCatch({
          xml2::write_xml(vector, temporary_svg)
          copy_if_changed(temporary_svg, target)
          copy_if_changed(target, file.path(published_dir, filename))
        }, finally = unlink(temporary_svg))
        exported <- c(exported, filename)
      }
    }
  }
  message("Checked ", length(exported), " figure files; copied only new or changed content.")
  invisible(exported)
}

export_figures()
