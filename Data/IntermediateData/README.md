# IntermediateData Folder

## Overview

The `IntermediateData` folder stores data files generated during processing steps. These are not the final analysis data. They are intermediary products of data transformations, cleaning, and other preprocessing. They document the evolution of the data from raw input to final analysis data.

## Contents

-   **Intermediate Data Files**: These files capture various stages of data processing. They may include data that has been cleaned, merged, filtered, or otherwise transformed but is not yet in its final form for analysis.
-   **Chapter 4 RDS files**: `popmodel_realistic.rds` and `h1model_realistic.rds` are created by the two simulation chunks in `04_pa.qmd`. The repository distributes the definitive files so ordinary rendering does not repeat the simulations. Delete only these files and rerun those chunks to audit the calculations from zero.

## Guidelines

-   **File Naming**: Use descriptive and consistent names. Names should reflect the processing stage and specific transformations applied.
-   **Documentation**: Document each intermediate data file thoroughly. Include:
    -   **Transformation Steps**: A detailed account of the transformations applied to generate the file.
    -   **Rationale**: Reasoning behind each transformation step. Explain how it contributes to the overall analysis.
    -   **Version Control**: Track different versions if files are updated or modified.
-   **Data Integrity**: Maintain data integrity at each processing stage. Document any issues and the steps taken to resolve them.

## Additional Resources

For more detailed instructions and best practices, refer to the [TIER Protocol 4.0 IntermediateData Guidelines](https://www.projecttier.org/tier-protocol/protocol-4-0/root/data/intermediatedata/).
