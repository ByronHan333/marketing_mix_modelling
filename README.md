# Marketing Mix Modelling project
This is an end-to-end project on marketing mix modelling of a consumer product's marketing activities and environment activities between 2014 and 2018. <br /> 
 \
This project includes data ETL, model optimization, side diagonistic, business insight and budget optimization. <br />

## TLDR for HR
* Collected, aggreagted, cleaned data using MySQL to manage ETL process.
* Created EDA data visualizaiton using Tableau.
* Performed multivariate regression models using R to evaluate marketing tactics impact.
* Built Tableau dashboards to visualize model results; Also including informative AVM, model contributions, media ROIs to deliver key business insights.
* Analyzed effectiveness and efficiency of media activities (e.g., TV GRPs, Paid Search Clicks, Facebook ads, Display Impressions, etc.).
* Provided actionable recommendation on budget optimization using Excel Solver.
* Created presentation deck to summarize model findings and presented result to marketing team.

## Table of Content
* [Goal](#goal)
* [Data Description](#data-description)
* [Data Preprocess](#data-preprocess)
* [Modelling](#modelling)
* [Visualization](#visualization)
* [Evaluation & Side Diagonistic](#evalutaion-&-side-diagnostic)
* [Budget Optimization](#budget-optimization)
* [Presentation](#presentation)

## Goal

## Data Description
Data [(link)]() has been limited to header and 1 line of encoded value.
* Sales
    - MMM_Sales_Raw.csv
* Marketing activity
    - MMM_AdWordsSearch_2015.csv
    - MMM_AdWordsSearch_2017.csv
    - MMM_DCMDisplay_2015.csv
    - MMM_DCMDisplay_2017.csv
    - MMM_Event.csv
    - MMM_Facebook.csv
    - MMM_Offline_TV_Magazine.csv
    - MMM_Wechat.csv
* Competitor
    - MMM_Comp_Media_Spend.csv
* Environment (could include market specific) 
* Other
    - MMM_Date_Metadata.csv
    - MMM_DMA_HH.csv


## Data Preprocess
* To make ETL more robust, I assume 2015-data is preloaded and 2017-data which has 6-month overlap is added later.
* Each channel has 1-3 drivers to reduce model collinearity and for simplicity of this project.
* Dependent variables (sales volume) and independent variables (drivers of growth) are aggregated on weekly level to reduce daily noise.
* Special event such as Black-Friday/Christmas/July-4th are later added in modelling stage.


## Modelling

## Visualization

## Evaluation & Side Diagonistic

## Budget optimization

## Presentation




