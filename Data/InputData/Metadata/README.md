# Metadata Folder

## Overview

The `Metadata` folder stores documentation for the raw input data files used in the Smart CFA project. It records dataset provenance, basic file characteristics, and variable-level definitions for files kept in `Data/InputData` before any cleaning or transformation.

## Contents

### 1. Codebooks

-   **Purpose**: Document the variables contained in the raw input data files.
-   **Contents**:
    -   `codebook.csv`: Variable-level documentation for `Data/InputData/data.csv`. It contains one row per column in `data.csv` and the following fields: `position_in_data`, `code_name`, `variable_label`, `measure_level`, and `value_labels`.

### 2. Data Source Information

-   **Purpose**: Record the provenance of the raw data and point readers to additional metadata sources.
-   **Description**: The current raw input file is `Data/InputData/data.csv`, a comma-delimited CSV with 108 columns and 1546 rows. This file represents the raw data before cleaning, so its number of observations does not necessarily match the counts reported in downstream analytical files or in the external repository.
-   **Source**: Rogers, Pablo; Barbosa, Flávia; Peixoto, Fernanda; Silva, Dany Rogers (2024), "Data for 'Asset diversification, financial well-being, quality of life, and mental health: a study in Brazil' published by Revista de Contabilidade & Finanças", Mendeley Data, V2, doi: 10.17632/xvzsd8gk63.2.
-   **Additional Variable Information**: The dataset landing page at https://data.mendeley.com/datasets/xvzsd8gk63/2 includes additional information about the variables.

## Guidelines

-   **File Organization**: Keep metadata files clearly named and aligned with the raw files stored in `Data/InputData`.
-   **Documentation**: Update `codebook.csv` whenever the structure of `data.csv` changes. Preserve the original variable names from the raw file and document labels and coding schemes clearly.
-   **Scope**: Use this folder to document raw data only. Record cleaning steps, transformations, and derived-variable decisions in later workflow stages such as `IntermediateData`, `AnalysisData`, or the Data Appendix outputs.

## Additional Resources

For more detailed instructions and best practices, refer to the [TIER Protocol 4.0 Metadata Guidelines](https://www.projecttier.org/tier-protocol/protocol-4-0/root/data/originaldata/metadata/).
