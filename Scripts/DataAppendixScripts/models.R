# =============================================================================
# WHOQOL-Bref CFA models used in the executable tutorial
# =============================================================================
# This file is the authoritative reusable source for model specifications used
# by later analytical chapters. Chapter 3 intentionally mirrors the two free
# models inside copy-ready HTML examples; those mirrors must remain synchronized
# with `analyzemodel` and `h1modelfree` below. This file contains two kinds
# of lavaan syntax:
#
# 1. Fixed population models (`popmodel` and `h1model`) for power analysis.
#    Their numerical values define a population covariance structure.
# 2. Free analysis models (`analyzemodel` and `h1modelfree`) for fitting
#    empirical data and drawing the structural diagrams in Chapter 3.
#
#
# Sources
# - Lin and Yao (2022): meta-analytic EFA estimates for WHOQOL-Bref.
# - Mosqueira-Taipe et al. (2026): systematic review of structural validity.
#
# Item allocation used in every model
# - Psychological: Q5, Q6, Q7, Q11, Q19, Q26
# - Physical:      Q3, Q4, Q10, Q15, Q16, Q17, Q18
# - Social:        Q20, Q21, Q22
# - Environment:   Q8, Q9, Q12, Q13, Q14, Q23, Q24, Q25
#
# Q1 and Q2 are global quality-of-life items and are not indicators of the
# four-domain measurement model.

# =============================================================================
# Fixed population model: meta-analytic four-factor structure
# =============================================================================
# `popmodel` represents the population under the more parsimonious model.
# All loadings are fixed to the values reported by Lin and Yao (2022), so this
# object is intended for data generation and model-based power calculations,
# not for direct estimation from the tutorial sample.

popmodel <- '
  # Factor loadings: meta-analytic estimates from Lin and Yao (2022)
  psycho =~ 0.92*Q5 + 0.81*Q6 + 0.94*Q7 +
            0.73*Q11 + 0.75*Q19 + 0.63*Q26

  physical =~ 0.84*Q3 + 0.83*Q4 + 0.63*Q10 +
              0.71*Q15 + 0.68*Q16 + 0.89*Q17 + 0.61*Q18

  social =~ 0.94*Q20 + 0.89*Q21 + 0.78*Q22

  environment =~ 0.37*Q8 + 0.49*Q9 + 0.79*Q12 + 0.81*Q13 +
                 0.77*Q14 + 0.75*Q23 + 0.64*Q24 + 0.73*Q25

  # Residual covariance between Q3 and Q4
  # Both items belong to the physical domain and share negatively worded,
  # closely related content. A residual correlation of .30 is translated to
  # covariance because the population model uses standardized indicators:
  #   cov(e3, e4) = .30 * sqrt(1 - .84^2) * sqrt(1 - .83^2)
  #               = .0908
  Q4 ~~ 0.0908*Q3

  # Factor variances are fixed to 1, so covariances equal correlations.
  # Lin and Yao (2022) reported interfactor correlations from .08 to .31.
  # A common value of .20 represents the middle of that empirical range.
  psycho ~~ 1*psycho + 0.20*physical + 0.20*social + 0.20*environment
  physical ~~ 1*physical + 0.20*social + 0.20*environment
  social ~~ 1*social + 0.20*environment
  environment ~~ 1*environment

  # Residual variances preserve unit variance for each indicator:
  #   theta_i = 1 - lambda_i^2
  Q5 ~~ 0.1536*Q5     # 1 - .92^2
  Q6 ~~ 0.3439*Q6     # 1 - .81^2
  Q7 ~~ 0.1164*Q7     # 1 - .94^2
  Q11 ~~ 0.4671*Q11   # 1 - .73^2
  Q19 ~~ 0.4375*Q19   # 1 - .75^2
  Q26 ~~ 0.6031*Q26   # 1 - .63^2
  Q3 ~~ 0.2944*Q3     # 1 - .84^2
  Q4 ~~ 0.3111*Q4     # 1 - .83^2
  Q10 ~~ 0.6031*Q10   # 1 - .63^2
  Q15 ~~ 0.4959*Q15   # 1 - .71^2
  Q16 ~~ 0.5376*Q16   # 1 - .68^2
  Q17 ~~ 0.2079*Q17   # 1 - .89^2
  Q18 ~~ 0.6279*Q18   # 1 - .61^2
  Q20 ~~ 0.1164*Q20   # 1 - .94^2
  Q21 ~~ 0.2079*Q21   # 1 - .89^2
  Q22 ~~ 0.3916*Q22   # 1 - .78^2
  Q8 ~~ 0.8631*Q8     # 1 - .37^2; lowest loading and bridge item
  Q9 ~~ 0.7599*Q9     # 1 - .49^2
  Q12 ~~ 0.3759*Q12   # 1 - .79^2
  Q13 ~~ 0.3439*Q13   # 1 - .81^2
  Q14 ~~ 0.4071*Q14   # 1 - .77^2
  Q23 ~~ 0.4375*Q23   # 1 - .75^2
  Q24 ~~ 0.5904*Q24   # 1 - .64^2
  Q25 ~~ 0.4671*Q25   # 1 - .73^2
'

# =============================================================================
# Fixed H1 population model: three substantively selected cross-loadings
# =============================================================================
# `h1model` retains every feature of `popmodel` and adds three secondary
# loadings taken from the exploratory solution discussed in the article:
# - Q8 and Q9 also load on the psychological factor.
# - Q15 also loads on the environmental factor.
#
# These items keep their primary loadings. The cross-loadings supplement rather
# than reassign the items, creating the misspecified population used to examine
# whether the simpler analysis model can detect those omitted relations.

h1model <- '
  # Primary loadings plus Q8 and Q9 cross-loadings on psychological
  psycho =~ 0.92*Q5 + 0.81*Q6 + 0.94*Q7 +
            0.73*Q11 + 0.75*Q19 + 0.63*Q26 +
            0.55*Q8 +                       # Cross-loading 1
            0.21*Q9                         # Cross-loading 2

  physical =~ 0.84*Q3 + 0.83*Q4 + 0.63*Q10 +
              0.71*Q15 + 0.68*Q16 + 0.89*Q17 + 0.61*Q18

  social =~ 0.94*Q20 + 0.89*Q21 + 0.78*Q22

  # Q15 retains its physical loading and also loads on environment.
  environment =~ 0.37*Q8 + 0.49*Q9 + 0.79*Q12 + 0.81*Q13 +
                 0.77*Q14 + 0.75*Q23 + 0.64*Q24 + 0.73*Q25 +
                 0.24*Q15                   # Cross-loading 3

  # The Q3--Q4 residual covariance is part of both population models.
  Q4 ~~ 0.0908*Q3

  # The same standardized factor structure is retained for comparability.
  psycho ~~ 1*psycho + 0.20*physical + 0.20*social + 0.20*environment
  physical ~~ 1*physical + 0.20*social + 0.20*environment
  social ~~ 1*social + 0.20*environment
  environment ~~ 1*environment

  # Residual variances for indicators with one loading remain 1 - lambda^2.
  Q5 ~~ 0.1536*Q5
  Q6 ~~ 0.3439*Q6
  Q7 ~~ 0.1164*Q7
  Q11 ~~ 0.4671*Q11
  Q19 ~~ 0.4375*Q19
  Q26 ~~ 0.6031*Q26
  Q3 ~~ 0.2944*Q3
  Q4 ~~ 0.3111*Q4
  Q10 ~~ 0.6031*Q10

  # Cross-loaded indicators require the covariance between their factors in
  # the explained-variance calculation. With phi = .20:
  #   theta_Q15 = 1 - (.71^2 + .24^2 + 2*.71*.24*.20) = .3701
  Q15 ~~ 0.3701*Q15

  Q16 ~~ 0.5376*Q16
  Q17 ~~ 0.2079*Q17
  Q18 ~~ 0.6279*Q18
  Q20 ~~ 0.1164*Q20
  Q21 ~~ 0.2079*Q21
  Q22 ~~ 0.3916*Q22

  #   theta_Q8 = 1 - (.37^2 + .55^2 + 2*.37*.55*.20) = .4792
  #   theta_Q9 = 1 - (.49^2 + .21^2 + 2*.49*.21*.20) = .6746
  Q8 ~~ 0.4792*Q8
  Q9 ~~ 0.6746*Q9

  Q12 ~~ 0.3759*Q12
  Q13 ~~ 0.3439*Q13
  Q14 ~~ 0.4071*Q14
  Q23 ~~ 0.4375*Q23
  Q24 ~~ 0.5904*Q24
  Q25 ~~ 0.4671*Q25
'

# =============================================================================
# Free analysis model: four correlated factors and Q3--Q4 covariance
# =============================================================================
# This is the primary model shown in Figure 1 and fitted to empirical data.
# Identification comes from fixing each factor variance to 1, rather than from fixing a
# marker loading. Consequently, every loading shown below is estimated from the data.
# Residual variances are omitted because lavaan estimates them automatically.

analyzemodel <- '
  # Freely estimated primary loadings
  psycho =~ Q5 + Q6 + Q7 + Q11 + Q19 + Q26
  physical =~ Q3 + Q4 + Q10 + Q15 + Q16 + Q17 + Q18
  social =~ Q20 + Q21 + Q22
  environment =~ Q8 + Q9 + Q12 + Q13 + Q14 + Q23 + Q24 + Q25

  # Unit-variance identification and freely estimated factor covariances
  psycho ~~ 1*psycho + physical + social + environment
  physical ~~ 1*physical + social + environment
  social ~~ 1*social + environment
  environment ~~ 1*environment

  # Freely estimated local dependence between Q3 and Q4
  Q4 ~~ Q3
'

# =============================================================================
# Free H1 analysis model: primary model plus three cross-loadings
# =============================================================================
# This is the alternative model shown in Figure 2. It uses the same indicators,
# identification, factor covariances, and Q3--Q4 residual covariance as
# `analyzemodel`. The only difference is that Q8, Q9, and Q15 receive the
# three additional freely estimated loadings described above.

h1modelfree <- '
  # Primary loadings plus freely estimated Q8 and Q9 cross-loadings
  psycho =~ Q5 + Q6 + Q7 + Q11 + Q19 + Q26 + Q8 + Q9
  physical =~ Q3 + Q4 + Q10 + Q15 + Q16 + Q17 + Q18
  social =~ Q20 + Q21 + Q22

  # Q15 keeps its physical loading and gains an environmental loading.
  environment =~ Q8 + Q9 + Q12 + Q13 + Q14 + Q23 + Q24 + Q25 + Q15

  # The identification and factor-covariance structure match analyzemodel.
  psycho ~~ 1*psycho + physical + social + environment
  physical ~~ 1*physical + social + environment
  social ~~ 1*social + environment
  environment ~~ 1*environment

  # The Q3--Q4 residual covariance is retained in the alternative model.
  Q4 ~~ Q3
'
