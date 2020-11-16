# Marketing Mix Modelling Project
This is an end-to-end project on marketing mix modelling of a Chinese branch US-based female quick fashion brand on data between 2014 and 2017. 

The goal of this project is to evaluate 2017 performance and provide actionable recommendation for 2018. 

Final presentation deck can be viewed here [(Powerpoint)](final_presentation.pdf).

## TLDR: this project includes:
* Maintaining ETL data pipeline in MySQL server [(MySQL code)](MySQL/data_preprocess.sql)
* Data Transformation & model selection in R [(R transformation section)](R/mmm_premodel_transformation.R)
* Business insight & visualization dashboard in Tableau ([Powerpoint](final_presentation.pdf), [Tableau workbook](MySQL/data_preprocess.sql))
* Side diagonistic[(R side diagnosis section)](R/mmm_premodel_transformation.R)
* Budget spending optimization & recommendation in R [(R optimization section)](R/mmm_premodel_transformation.R)
* Final presentation with company team [(Powerpoint)](final_presentation.pdf)

## Technical summary for tools & models
* Collected, aggreagted, cleaned data using MySQL to manage ETL process.
* Created EDA data visualizaiton using Tableau.
* Performed multivariate regression models using R to evaluate marketing tactics impact.
* Built Tableau dashboards to visualize model results; Also including informative AVM, model contributions, media ROIs to deliver key business insights.
* Analyzed effectiveness and efficiency of media activities (e.g., TV GRPs, Paid Search Clicks, Facebook ads, Display Impressions, etc.).
* Provided actionable recommendation on budget optimization using Excel Solver.
* Created presentation deck to summarize model findings and presented result to marketing team.

## Table of Content
* [Data Description](#data-description)
* [MySQL ETL pipeline for preprocessing](#MySQL-ETL-pipeline-for-preprocessing)
* [Data Transformation in R & Python](#Data-Transformation-in-R-&-Python) 
* [Model Selection & Evaluation](#Model-Selection-&-Evaluation)
* [Side Diagonistic](Side-Diagonistic)
* [Visualizaiton data preparation in R](Business-Visualizaiton-data-preparation-in-R)
* [Tableau Visualization](#visualization)
* [Budget Optimization in R](#budget-optimization)


## Data Description
Data [(link)]() is limited to header and 1 line of encoded value.
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
* Marketing spending
	- MMM_Spending.csv
* Competitor
    - MMM_Comp_Media_Spend.csv
* Environment (could include market specific) 
	- CCI.csv
* Other
    - MMM_Date_Metadata.csv
    - MMM_DMA_HH.csv


## MySQL ETL pipeline for preprocessing
Aggregated all teams' marketing activities in MySQL server [(MySQL code)](MySQL/data_preprocess.sql).
* To make ETL more robust, 2015-data is preloaded, and 2017-data with 6-month overlap is added later.
* Only select 1-3 drivers for each channel for simplicity of this project.
* data is aggregated on weekly level to reduce noise and overfitting.
* Other detail can be found in sql notes
```bash
├── app
│   ├── css
│   │   ├── **/*.css
│   ├── favicon.ico
│   ├── images
│   ├── index.html
│   ├── js
│   │   ├── **/*.js
│   └── partials/template
├── dist (or build)
├── node_modules
├── bower_components (if using bower)
├── test
├── Gruntfile.js/gulpfile.js
├── README.md
├── package.json
├── bower.json (if using bower)
└── .gitignore
```


## Data Transformation in R
* Adding Lag, Decay to 6 selected marketing channels, apply Power curve [(R)](R/mmm_premodel_transformation.R).
* Advertising intensity, competitive interference and wear-out impacts on advertising effectiveness, but for simiplicity we only look at:
    - Lag
    - Decay
    - Diminishing return (Power curve)

* Adstock's lag effect is firstly estimated using: 
    - A_{t} = A_{t-lag}  
* Adstock's decay effect is secondly expressed using one carry-over model: 
    - At =  At * decay + At-1 * (1 - decay)
* Adstock's diminishing return effect is estimated using: 
    - At = At ** power(alpha)
* Details for Decay, Lag & Alpha in power curve.
    - Traditional media normally has higher lag.
    - Online media noramlly has high decay.
    - More other decay models can be found [here](https://mpra.ub.uni-muenchen.de/7683/4/MPRA_paper_7683.pdf) or other online resources.
    - More other diminishin return models can be found [here](https://www.lexjansen.com/nesug/nesug08/sa/sa03.pdf) or other online resources.

|             |    Decay    | Lag | Alpha |
|:-----------:|:-----------:|:---:|:-----:|
| National TV |     0.8     |  0  |  0.9  |
| National TV |     0.8     |  1  |  0.6  |
|   Magazine  |     0.7     |  1  |  0.6  |
|   Magazine  |     0.9     |  1  |  0.6  |
| Paid Search |     0.9     |  0  |   1   |
| Paid Search |     0.9     |  1  |  0.7  |
|   Display   |     0.8     |  0  |  0.8  |
|   Display   |      1      |  0  |   1   |
|   Facebook  |      1      |  0  |  0.8  |
|   Facebook  |      1      |  1  |   1   |
|    Wechat   |     0.8     |  0  |  0.9  |
|    Wechat   |     0.9     |  1  |   1   |


## Model Selection & Evaluation

## Evaluation & Side Diagonistic

## Budget optimization




