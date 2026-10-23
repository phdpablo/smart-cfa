$qmdPath = Join-Path (Get-Location) '08_model_comparison.qmd'
$helperPath = Join-Path (Get-Location) 'Scripts/DataAppendixScripts/helpers.R'
$qmd = [IO.File]::ReadAllText($qmdPath)
$start = $qmd.IndexOf('# Combine the reference and fair-discrepancy simulated indices.')
$end = $qmd.IndexOf('# Display the simulated distributions and cutoff references.', $start)
$original = $qmd.Substring($start, $end - $start)
$body = $original.Replace('dfi_adjusted', 'object')
$body = $body.Replace('object$indices$RMSEA_L2', 'object$indices[[paste0("RMSEA_L", level)]]').Replace('object$indices$CFI_L2', 'object$indices[[paste0("CFI_L", level)]]')
$body = $body.Replace('object$cutoffs["Fair",', 'object$cutoffs[reference,').Replace('title = "Fair"', 'title = reference')
$body = $body.Replace('dfi_plot_fair <-', 'result <-').Replace('# Combine the reference and fair-discrepancy simulated indices.', '# Combine the reference and selected discrepancy distributions.')
$doc = @'
# =============================================================================
# Simulated distributions for a DDDFI reference level
# =============================================================================
# Purpose:
# Plot saved CFI and RMSEA distributions with dynamic and conventional cutoffs.
#
# Input:
# object: One completed DDDFI result containing indices and cutoffs.
# reference: "Close" (L1), "Fair" (L2, default), or "Mediocre" (L3).
# Each selected level is compared with the reference distributions in L0.
#
# Output:
# A ggplot with RMSEA and CFI panels. plot_data and plot_cutoffs retain
# the plotted values; reference records the selected level. SRMR_L* fields
# are not used because this DDDFI implementation stores RMSEA upper limits
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
  if (!is.list(object) || !all(columns %in% names(object$indices)) ||
      !reference %in% rownames(object$cutoffs) ||
      !all(c("RMSEA", "CFI") %in% colnames(object$cutoffs))) {
    stop("object must contain saved DDDFI distributions and reference cutoffs.")
  }
  if (!all(vapply(object$indices[columns], is.numeric, logical(1))) ||
      any(vapply(object$indices[columns], length, integer(1)) == 0L)) {
    stop("Selected DDDFI distributions must be nonempty numeric vectors.")
  }
  cutoffs <- suppressWarnings(as.numeric(object$cutoffs[reference, c("RMSEA", "CFI")]))
  if (any(!is.finite(cutoffs))) {
    stop("Selected DDDFI cutoffs must be finite numeric values.")
  }

'@
$indented = (($body.TrimEnd() -split '\r?\n' | ForEach-Object { if ($_.Length) { '  ' + $_ } else { '' } }) -join "`n")
$tail = @'

  # Preserve the plotted inputs for inspection.
  attr(result, "plot_data") <- dfi_plot_data
  attr(result, "plot_cutoffs") <- dfi_plot_cutoffs
  attr(result, "reference") <- reference
  result
}

'@
$helper = [IO.File]::ReadAllText($helperPath)
$pos = $helper.IndexOf('# --- Model comparison tables')
if ($pos -lt 0) { throw 'Helper insertion marker missing.' }
$helper = $helper.Insert($pos, $doc + "`n" + $indented + $tail + "`n")
$replacement = "# Plot the saved distributions for the fair reference.`ndfi_plot_fair <- plot_3dfi(dfi_adjusted, reference = `"Fair`")`n`n"
if (($qmd.Split(@($original), [StringSplitOptions]::None).Length - 1) -ne 2) { throw 'Expected two mirrored plot blocks.' }
$qmd = $qmd.Replace($original, $replacement)
$qmd = $qmd.Replace('O bloco reúne as colunas `CFI_L0` e `RMSEA_L0` para a referência e `CFI_L2` e `RMSEA_L2` para a discrepância razoável. Os dados são reorganizados em formato longo e os painéis recebem a mesma ordem de índices. As colunas `SRMR_L*` não são utilizadas: nesta implementação armazenam limites superiores do intervalo do RMSEA.', 'A função `plot_3dfi()`, de [helpers.R](Scripts/DataAppendixScripts/helpers.R), recebe a calibração salva e a referência desejada: `"Close"`, `"Fair"` ou `"Mediocre"`. Essas opções selecionam, respectivamente, as distribuições `CFI_L1`/`RMSEA_L1`, `CFI_L2`/`RMSEA_L2` ou `CFI_L3`/`RMSEA_L3`, sempre comparadas com `CFI_L0` e `RMSEA_L0`. Nesta figura, utilizamos `reference = "Fair"`. As colunas `SRMR_L*` não são utilizadas: nesta implementação armazenam limites superiores do intervalo do RMSEA.')
$qmd = $qmd.Replace('`dfi_plot_cutoffs` reúne os limites da linha `Fair` e os valores convencionais CFI = 0,95 e RMSEA = 0,06. A figura sobrepõe histogramas e acrescenta linhas para essas referências, separando os índices em painéis.', 'A função recupera os limites dinâmicos da linha correspondente à referência escolhida e acrescenta os valores convencionais CFI = 0,95 e RMSEA = 0,06. A figura sobrepõe histogramas e apresenta as linhas de corte em painéis separados. Os atributos `plot_data` e `plot_cutoffs` preservam os dados utilizados. Para examinar outro nível, altere apenas `reference`; por exemplo, `plot_3dfi(dfi_adjusted, reference = "Mediocre")`.')
[IO.File]::WriteAllText($helperPath, $helper, [Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText($qmdPath, $qmd, [Text.UTF8Encoding]::new($false))
