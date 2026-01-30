1. Data Access
Imports TSA claims data from a CSV file using PROC IMPORT
Assigns a permanent SAS library for data processing

2. Data Exploration
Reviews variable metadata using PROC CONTENTS
Performs initial frequency checks to understand categorical variables

3. Data Preparation & Cleaning
Removes duplicate records
Standardizes inconsistent categorical values
Handles missing and invalid values
Applies proper formats and descriptive labels
Validates incident and received dates
Flags records with potential date issues

4. Analysis
Evaluates overall data quality
Analyzes year-wise trends in TSA claims
Performs state-level analysis using macro variables
Computes summary statistics for claim close amounts

5. Reporting & Visualization
Generates an automated PDF report using ODS PDF
Creates visualizations using PROC SGPLOT, including:
Claims trend by year
Claim type distribution
Close amount distributi

Most important:"The program is designed to be reusable and parameter-driven.
To analyze a different state, update the macro variable in the SAS program:
%let statename=Florida;
"






on
