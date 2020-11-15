setwd("/Users/ziyuanhan/Desktop/mmm_data")
getwd()

# install.packages('dplyr')
# install.packages('magrittr')
# install.packages('data.table')
# install.packages('car')
# install.packages('reshape')
# install.packages("readxl")
# install.packages('lpSolve')
library('lpSolve')
library('dplyr')
library('magrittr')
library('data.table')
library('readxl')

# ============================================= read data =============================================
df <- read.table("MMM_AF.csv", 
                 header = TRUE,
                 sep = ",")

df$Period <- as.Date(df$Period, format = '%m/%d/%Y')
df$Month <- as.Date(df$Month, format = '%m/%d/%Y')


# next time create data frame to store these value
# data.frame('channel'=c('tv','magazine','paid.search','display','facebook','wechat'))

# lag constant
tv.lag1 <- 0
tv.lag2 <- 1
magazine.lag1 <- 1 
magazine.lag2 <-1
paid.search.lag1 <- 0
paid.search.lag2 <- 1
display.lag1 <- 0
display.lag2 <- 0
facebook.lag1 <- 0
facebook.lag2 <- 1
wechat.lag1 <- 0
wechat.lag2 <- 1

#decay constant
tv.decay1 <- .8
tv.decay2 <- .8
magazine.decay1 <- .7 
magazine.decay2 <-.9
paid.search.decay1 <- .9
paid.search.decay2 <- .9
display.decay1 <- .8
display.decay2 <- 1
facebook.decay1 <- 1
facebook.decay2 <- 1
wechat.decay1 <- .8
wechat.decay2 <- .9

# power constant
tv.pow1 <- .9
tv.pow2 <- .6
magazine.pow1 <- .6
magazine.pow2 <-.9
paid.search.pow1 <- 1
paid.search.pow2 <- .7
display.pow1 <- .8
display.pow2 <- 1
facebook.pow1 <- .8
facebook.pow2 <- 1
wechat.pow1 <- .9
wechat.pow2 <- 1


transformation <- function(dataframe, transformation.type, transformation.type.index, transformation.constant, column.name) {
  ## ============== function explanation ==============
  ## This function performs lag, power and decay transformation
  ## returns the column of final result
  ## ============== function parameter explanation ==============
  ## dataframe: input dataframe
  ## transformation.type: lag, decay or power
  ## transformation.type.index: index of transforamtion. i.e. lag1, lag2, decay1, decay2
  ## transformation.constant: the parameter used for transformation
  ## column.name: dataframe column needed for transformation
  
  ## if need lag
  if (tolower(transformation.type)=='lag') {
    absolute.column <- paste0(c(column.name, transformation.type, transformation.type.index), collapse = '.') # create new column name
    d <- dataframe %>%
      # post: https://sebastiansauer.github.io/prop_fav/#:~:text=The%20double%20exclamation%20mark%20is,out%20of%20a%20data%20frame.
      # post: https://stackoverflow.com/questions/32077483/colons-equals-operator-in-r-new-syntax#:~:text=In%20this%20case%2C%20%3A%3D%20is,to%20use%20in%20this%20context.
      mutate(dataframe, !!absolute.column := lag(dataframe[[column.name]], transformation.constant, default=0)) # data pipeline to create new column
    return (d)
  ## if need decay
  } else if (tolower(transformation.type)=='decay') {
    absolute.column <- paste0(c(column.name, transformation.type, transformation.type.index), collapse = '.')
    # post: https://stackoverflow.com/questions/64414257/how-to-add-new-column-and-calculate-recursive-cum-using-dplyr-and-shift/
    d <- dataframe %>%
      mutate(dataframe, !!absolute.column := purrr::accumulate(dataframe[[column.name]], ~.x * (1-transformation.constant) +  .y*transformation.constant))
    return (d)
  ## if need power
  } else if (tolower(transformation.type)=='power') {
    absolute.column <- paste0(c(column.name, transformation.type, transformation.type.index), collapse = '.')
    d <- dataframe %>%
      mutate(dataframe, !!absolute.column := dataframe[[column.name]] ** transformation.constant)
    return (d)
  } else {
    print("ONLY LAG, DECAY, POWER SUPPORTED")
    return (NULL)
  }
}

# test cases
# var <- c('National.TV.GRPs', 'Magazine.GRPs', 'Paid.Search', 'Display', 'Facebook.Impressions', 'Wechat')
# df.selected.columns <- df[var]

## test pass 
# df.selected.columns
# df.selected.columns <- transformation(df.selected.columns, 'lag', 1, 1, 'National.TV.GRPs')
# df.selected.columns <- transformation(df.selected.columns, 'power', 1, 0.8, 'National.TV.GRPs.lag.1')
# df.selected.columns <- transformation(df.selected.columns, 'decay', 1, 0.4, 'National.TV.GRPs.lag.1.power.1')


transformaton_sequence <- function(dataframe, sequence, sequence.indices, values, column.name) {
  ## ============== function explanation ==============
  ## This function performs a sequence of lag, power and decay transformation using transform
  ## returns the final transformation result
  ## ============== function parameter explanation ==============
  ## dataframe: input dataframe
  ## sequence: sequence of trasnformation
  ## sequence.indices: index number of the transformation
  ## values: value of transformation action
  ## column.name: name of column transformation operates on
  
  tmp <- copy(dataframe)
  ## 1st transformation
  tmp <- transformation(tmp, sequence[1], sequence.indices[1], values[1], column.name)
  first.transformation.column.name <- paste0(c(column.name, sequence[1], sequence.indices[1]), collapse = '.')
  ## 2nd transformation
  tmp <- transformation(tmp, sequence[2], sequence.indices[2], values[2], first.transformation.column.name)
  second.transformation.column.name <- paste0(c(first.transformation.column.name, sequence[2], sequence.indices[2]), collapse = '.')
  ## 3rd transformation
  tmp <- transformation(tmp, sequence[3], sequence.indices[3], values[3], second.transformation.column.name)
  third.transformation.column.name <- paste0(c(second.transformation.column.name, sequence[3], sequence.indices[3]), collapse = '.')
  
  return (select(tmp, third.transformation.column.name))
}


# test pass
# transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(1,.8,.4), 'National.TV.GRPs')
# transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(2,.2,.8), 'Magazine.GRPs')
# transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(0,.6,.6), 'Paid.Search')



df <- cbind(df, 
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(tv.lag1, tv.pow1, tv.decay1), 'National.TV.GRPs'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(tv.lag2, tv.pow2, tv.decay2), 'National.TV.GRPs'),
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(magazine.lag1, magazine.pow1, magazine.decay1), 'Magazine.GRPs'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(magazine.lag2, magazine.pow2, magazine.decay2), 'Magazine.GRPs'),
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(paid.search.lag1, paid.search.pow1, paid.search.decay1), 'Paid.Search'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(paid.search.lag2, paid.search.pow2, paid.search.decay2), 'Paid.Search'),
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(display.lag1, display.pow1, display.decay1), 'Display'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(display.lag2, display.pow2, display.decay2), 'Display'),
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(facebook.lag1, facebook.pow1, facebook.decay1), 'Facebook.Impressions'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(facebook.lag2, facebook.pow2, facebook.decay2), 'Facebook.Impressions'),
      transformaton_sequence(df, c('lag','power','decay'), c(1,1,1), c(wechat.lag1, wechat.pow1, wechat.decay1), 'Wechat'),
      transformaton_sequence(df, c('lag','power','decay'), c(2,2,2), c(wechat.lag2, wechat.pow2, wechat.decay2), 'Wechat')
)

excluded.cols <- c('National.TV.GRPs', 'Magazine.GRPs', 'Paid.Search', 'Display', 'Facebook.Impressions', 'Wechat')
df <- select(df, -excluded.cols)

# all variable names
# t(t(colnames(df)))
# [1] "Period"                                     "Month"                                     
# [3] "CCI"                                        "Sales.Event"                               
# [5] "Black.Friday"                               "July.4th"                                  
# [7] "Comp.Media.Spend"                           "Sales"                                     
# [9] "DisplayAlwaysOnImpression"                  "DisplayBrandingImpression"                 
# [11] "DisplayWebsiteImpression"                   "DisplayHolidayImpression"                  
# [13] "SearchBrandingclicks"                       "SearchAlwasyOnclicks"                      
# [15] "SearchWebsiteclicks"                        "FacebookBrandingImpressions"               
# [17] "FacebookHolidayImpressions"                 "FacebookOtherImpressions"                  
# [19] "National.TV.GRPs.lag.1.power.1.decay.1"     "National.TV.GRPs.lag.2.power.2.decay.2"    
# [21] "Magazine.GRPs.lag.1.power.1.decay.1"        "Magazine.GRPs.lag.2.power.2.decay.2"       
# [23] "Paid.Search.lag.1.power.1.decay.1"          "Paid.Search.lag.2.power.2.decay.2"         
# [25] "Display.lag.1.power.1.decay.1"              "Display.lag.2.power.2.decay.2"             
# [27] "Facebook.Impressions.lag.1.power.1.decay.1" "Facebook.Impressions.lag.2.power.2.decay.2"
# [29] "Wechat.lag.1.power.1.decay.1"               "Wechat.lag.2.power.2.decay.2"

# baseline model 
# explains 94% of variance
# all p-value significant than .001
# all vif just above 1, not significant multicollinearity
model1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend)
summary(model1)

# add TV -- add media channel, starting from with highest budget
# I choose model 1 because p-value is more significant
model2.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
              National.TV.GRPs.lag.1.power.1.decay.1)
summary(model2.1)

# model.residual = resid(model2.1)
# plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time") 
# abline(0, 0) 

model2.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
              National.TV.GRPs.lag.2.power.2.decay.2)
summary(model2.2)

# model.residual = resid(model2.2)
# plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time") 
# abline(0, 0) 

# add Paid Search
# I choose model 2 because P-value is more significant
model2.2.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                  National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1)
summary(model2.2.1)

model2.2.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                  National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.2.power.2.decay.2)
summary(model2.2.2)

# add wechat
# if model CCI coefficient is negative, discard
# both model performs similarly
# I choose model 1
# residual seems more random in model 1, R2 is larger for model 1
# AIC is smaller for model 1
model2.2.1.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                  National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                    Wechat.lag.1.power.1.decay.1)
summary(model2.2.1.1)
car::vif(model2.2.1.1)

AIC(model2.2.1.1)
model.residual = resid(model2.2.1.1)
plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time",ylim = c(-25000,40000)) 
abline(0, 0) 
plot(df$Sales, model.residual, ylab="Residuals", xlab="Period", main="Residual over time",ylim = c(-25000,40000)) 
abline(0, 0) 


model2.2.1.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                    National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                    Wechat.lag.2.power.2.decay.2)
summary(model2.2.1.2)
car::vif(model2.2.1.2)

AIC(model2.2.1.2)
model.residual = resid(model2.2.1.2)
plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time", ylim = c(-25000,40000)) 
abline(0, 0) 
plot(df$Sales, model.residual, ylab="Residuals", xlab="Period", main="Residual over time",ylim = c(-25000,40000)) 
abline(0, 0) 

# add magazine
# I chose model1 because p-value is more significant and didn't move other variables drastically
model2.2.1.1.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                    National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                    Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.1.power.1.decay.1)
summary(model2.2.1.1.1)

model2.2.1.1.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                    National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                    Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.2.power.2.decay.2)
summary(model2.2.1.1.2)

# add display
# I chose model1 because p-value is more significant
model2.2.1.1.1.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                      National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                      Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.1.power.1.decay.1+
                        Display.lag.1.power.1.decay.1)
summary(model2.2.1.1.1.1)

model2.2.1.1.1.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                        National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                        Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.1.power.1.decay.1+
                        Display.lag.2.power.2.decay.2)
summary(model2.2.1.1.1.2)

# add facebook
# I chose model2 since R^2 is higher and p-value is smaller
model2.2.1.1.1.1.1 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                        National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                        Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.1.power.1.decay.1+
                        Display.lag.1.power.1.decay.1+Facebook.Impressions.lag.1.power.1.decay.1)
summary(model2.2.1.1.1.1.1)
car::qqPlot(model2.2.1.1.1.1.1)

car::vif(model2.2.1.1.1.1.1)
AIC(model2.2.1.1.1.1.1)
model.residual = resid(model2.2.1.1.1.1.1)
plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time", ylim = c(-20000,30000)) 
abline(0, 0) 
plot(df$Sales, model.residual, ylab="Residuals", xlab="Period", main="Residual over time",ylim = c(-20000,30000)) 
abline(0, 0) 

model2.2.1.1.1.1.2 = lm(data = df, Sales~CCI+Sales.Event+July.4th+Black.Friday+Comp.Media.Spend+
                          National.TV.GRPs.lag.2.power.2.decay.2+Paid.Search.lag.1.power.1.decay.1+
                          Wechat.lag.1.power.1.decay.1+Magazine.GRPs.lag.1.power.1.decay.1+
                          Display.lag.1.power.1.decay.1+Facebook.Impressions.lag.2.power.2.decay.2, x=T)
summary(model2.2.1.1.1.1.2)

car::vif(model2.2.1.1.1.1.2)
AIC(model2.2.1.1.1.1.2)
model.residual = resid(model2.2.1.1.1.1.2)
plot(df$Period, model.residual, ylab="Residuals", xlab="Period", main="Residual over time", ylim = c(-10000,10000)) 
abline(0, 0) 
plot(df$Sales, model.residual, ylab="Residuals", xlab="Y value", main="Residual over Y",ylim = c(-20000,30000)) 
abline(0, 0) 
car::qqPlot(model2.2.1.1.1.1.2)

transformation.parameters <- matrix(ncol=3, nrow=6)
transformation.parameters[1,1:3] <- c(tv.lag2, tv.pow2, tv.decay2)
transformation.parameters[2,1:3] <- c(paid.search.lag1, paid.search.pow1, paid.search.decay1)
transformation.parameters[3,1:3] <- c(wechat.lag1, wechat.pow1, wechat.decay1)
transformation.parameters[4,1:3] <- c(magazine.lag1, magazine.pow1, magazine.decay1)
transformation.parameters[5,1:3] <- c(display.lag1, display.pow1, display.decay1)
transformation.parameters[6,1:3] <- c(facebook.lag2, facebook.pow2, facebook.decay2)
transformation.parameters <- as.data.frame(transformation.parameters)
transformation.parameters <- cbind(c('tv','paid.search','wechat','magazine','display','facebook'),as.data.frame(transformation.parameters))
colnames(transformation.parameters) <- c('channel','lag','pow','decay')
transformation.parameters

model.final <- model2.2.1.1.1.1.2
model.final$transformation.parameters <- transformation.parameters


# AVM: Actual vs Model
avm <- cbind.data.frame(df$Period, df$Sales, model.final$fitted.values)
colnames(avm) = c('Period','sales','predicted_value')
write.csv(avm, file='./tableau_data/avm.csv', row.names=F)

# Model contribution, media vs organic
select(model.final$model, -c('Sales'))
model.final$coefficients

contribution <- sweep(model.final$x, 2, model.final$coefficients, '*')
contribution <- data.frame(contribution)
contribution$Period <- df$Period

contri <- reshape::melt(contribution, id.vars = ('Period'))
contri
write.csv(contri, file='./tableau_data/contribution.csv', row.names=F)

# MAPE
mean(abs(avm$sales-avm$predicted_value)/avm$sales)

# ROI: Compare incremental sales, spend, media effectiveness/media efficiency
# This part is completed in Tableau


# Budget optimization
# final model parameters
print(model.final$transformation.parameters)
print(model.final$coefficients)

activity <- as.data.frame(read_excel("Optimizer.xlsx", sheet = "2018 activity"))
spend <- as.data.frame(read_excel("Optimizer.xlsx", sheet = "2018 spend"))

p <- model.final$transformation.parameters
p
activity <- cbind(activity, 
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'tv'), ]$lag,
                                           p[which(p$channel == 'tv'), ]$pow,
                                           p[which(p$channel == 'tv'), ]$decay), 'National TV'),
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'magazine'), ]$lag,
                                           p[which(p$channel == 'magazine'), ]$pow,
                                           p[which(p$channel == 'magazine'), ]$decay), 'Magazine'),
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'paid.search'), ]$lag,
                                           p[which(p$channel == 'paid.search'), ]$pow,
                                           p[which(p$channel == 'paid.search'), ]$decay), 'Paid Search'),
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'display'), ]$lag,
                                           p[which(p$channel == 'display'), ]$pow,
                                           p[which(p$channel == 'display'), ]$decay), 'Display'),
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'facebook'), ]$lag,
                                           p[which(p$channel == 'facebook'), ]$pow,
                                           p[which(p$channel == 'facebook'), ]$decay), 'Facebook'),
                  transformaton_sequence(activity, c('lag','power','decay'), c(1,1,1), 
                                         c(p[which(p$channel == 'wechat'), ]$lag,
                                           p[which(p$channel == 'wechat'), ]$pow,
                                           p[which(p$channel == 'wechat'), ]$decay), 'Wechat')
)

excluded.cols <- c('National TV', 'Magazine', 'Paid Search', 'Display', 'Facebook', 'Wechat')
planned.activity <- select(activity, -excluded.cols)
col_order <- c('Intercept','CCI','Sales.Event','July.4th','Black.Friday','Comp Media Spend',
               'National TV.lag.1.power.1.decay.1','Paid Search.lag.1.power.1.decay.1','Wechat.lag.1.power.1.decay.1',
               'Magazine.lag.1.power.1.decay.1','Display.lag.1.power.1.decay.1','Facebook.lag.1.power.1.decay.1')
model.input <- planned.activity[, col_order]

media.channels <- c('National TV.lag.1.power.1.decay.1','Paid Search.lag.1.power.1.decay.1','Wechat.lag.1.power.1.decay.1',
                    'Magazine.lag.1.power.1.decay.1','Display.lag.1.power.1.decay.1','Facebook.lag.1.power.1.decay.1')

colsum.planned.media.activity <- colSums(planned.activity[,c(media.channels)])
colsum.planned.media.activity

# https://stackoverflow.com/questions/18396633/sum-all-values-in-every-column-of-a-data-frame-in-r
colsum.planned.spend <- colSums(spend[,-1], na.rm = FALSE, dims = 1)
colsum.planned.spend

total.budget <- sum(spend[,-1])
total.budget

planned.contribution <- sweep(model.input, 2, model.final$coefficients, '*')
planned.contribution

colSums(planned.contribution)

colSums(model.input) * model.final$coefficients

dim(select(activity.planned, -c('Date')))
length(model.final$coefficients)
model.final$coefficients

current.predicted.sales <- sum(planned.contribution[,c('National TV.lag.1.power.1.decay.1',
                                                       'Paid Search.lag.1.power.1.decay.1',
                                                       'Wechat.lag.1.power.1.decay.1',
                                                       'Magazine.lag.1.power.1.decay.1',
                                                       'Display.lag.1.power.1.decay.1',
                                                       'Facebook.lag.1.power.1.decay.1')])
current.predicted.sales

colsum.planned.spend
colsum.planned.media.activity
model.final$coefficients

typeof(colsum.planned.spend)
names(colsum.planned.media.activity) <- c('National TV','Paid Search','Wechat','Magazine','Display','Facebook')
colsum.planned.media.activity

####################################### Linear Programming Solution #######################################

objective.function <- c(
  model.final$coefficients['National.TV.GRPs.lag.2.power.2.decay.2']*colsum.planned.media.activity['National TV']/colsum.planned.spend['National TV'],
  model.final$coefficients['Paid.Search.lag.1.power.1.decay.1']*colsum.planned.media.activity['Paid Search']/colsum.planned.spend['Paid Search'],
  model.final$coefficients['Wechat.lag.1.power.1.decay.1']*colsum.planned.media.activity['Wechat']/colsum.planned.spend['Wechat'],
  model.final$coefficients['Magazine.GRPs.lag.1.power.1.decay.1']*colsum.planned.media.activity['Magazine']/colsum.planned.spend['Magazine'],
  model.final$coefficients['Display.lag.1.power.1.decay.1']*colsum.planned.media.activity['Display']/colsum.planned.spend['Display'],
  model.final$coefficients['Facebook.Impressions.lag.2.power.2.decay.2']*colsum.planned.media.activity['Facebook']/colsum.planned.spend['Facebook']
)

constraints <- matrix(c(1,1,1,1,1,1,
                        1,0,0,0,0,0,
                        0,1,0,0,0,0,
                        0,0,1,0,0,0,
                        0,0,0,1,0,0,
                        0,0,0,0,1,0,
                        0,0,0,0,0,1,
                        1,0,0,0,0,0,
                        0,1,0,0,0,0,
                        0,0,1,0,0,0,
                        0,0,0,1,0,0,
                        0,0,0,0,1,0,
                        0,0,0,0,0,1), nrow=13, byrow=T)


constraints.directions <- c('<=',
                            '<=',
                            '<=',
                            '<=',
                            '<=',
                            '<=',
                            '<=',
                            '>=',
                            '>=',
                            '>=',
                            '>=',
                            '>=',
                            '>=')

constraints.rhs <- c(sum(colsum.planned.spend),
                     1.3*colsum.planned.spend['National TV'],
                     1.3*colsum.planned.spend['Paid Search'],
                     1.3*colsum.planned.spend['Wechat'],
                     1.3*colsum.planned.spend['Magazine'],
                     1.3*colsum.planned.spend['Display'],
                     1.3*colsum.planned.spend['Facebook'],
                     0.7*colsum.planned.spend['National TV'],
                     0.7*colsum.planned.spend['Paid Search'],
                     0.7*colsum.planned.spend['Wechat'],
                     0.7*colsum.planned.spend['Magazine'],
                     0.7*colsum.planned.spend['Display'],
                     0.7*colsum.planned.spend['Facebook'])

optimum <-  lp(direction="max",
               objective.in = objective.function,
               const.mat = constraints,
               const.dir = constraints.directions,
               const.rhs = constraints.rhs,
               all.int = T)


optimum$solution/colsum.planned.spend2
optimum$solution
colsum.planned.spend
colsum.planned.spend2
colsum.planned.spend2 <- colsum.planned.spend[c('National TV','Paid Search','Wechat','Magazine','Display','Facebook')]

## objective function in lp
c(
  model.final$coefficients['National.TV.GRPs.lag.2.power.2.decay.2']*colsum.planned.media.activity['National TV']/colsum.planned.spend['National TV'],
  model.final$coefficients['Paid.Search.lag.1.power.1.decay.1']*colsum.planned.media.activity['Paid Search']/colsum.planned.spend['Paid Search'],
  model.final$coefficients['Wechat.lag.1.power.1.decay.1']*colsum.planned.media.activity['Wechat']/colsum.planned.spend['Wechat'],
  model.final$coefficients['Magazine.GRPs.lag.1.power.1.decay.1']*colsum.planned.media.activity['Magazine']/colsum.planned.spend['Magazine'],
  model.final$coefficients['Display.lag.1.power.1.decay.1']*colsum.planned.media.activity['Display']/colsum.planned.spend['Display'],
  model.final$coefficients['Facebook.Impressions.lag.2.power.2.decay.2']*colsum.planned.media.activity['Facebook']/colsum.planned.spend['Facebook']
)

model.final$coefficients

model.final$transformation.parameters

optimum$solution
sum(colsum.planned.media.activity * optimum$solution)

# optimized sum of contribution in each channel
c(model.final$coefficients['National.TV.GRPs.lag.2.power.2.decay.2']*colsum.planned.media.activity['National TV']*optimum$solution[1]/colsum.planned.spend['National TV'],
model.final$coefficients['Paid.Search.lag.1.power.1.decay.1']*colsum.planned.media.activity['Paid Search']*optimum$solution[2]/colsum.planned.spend['Paid Search'],
model.final$coefficients['Wechat.lag.1.power.1.decay.1']*colsum.planned.media.activity['Wechat']*optimum$solution[3]/colsum.planned.spend['Wechat'],
model.final$coefficients['Magazine.GRPs.lag.1.power.1.decay.1']*colsum.planned.media.activity['Magazine']*optimum$solution[4]/colsum.planned.spend['Magazine'],
model.final$coefficients['Display.lag.1.power.1.decay.1']*colsum.planned.media.activity['Display']*optimum$solution[5]/colsum.planned.spend['Display'],
model.final$coefficients['Facebook.Impressions.lag.2.power.2.decay.2']*colsum.planned.media.activity['Facebook']*optimum$solution[6]/colsum.planned.spend['Facebook'])

optimum$solution

# optimized sum of activities in each channel
c(colsum.planned.media.activity['National TV']*optimum$solution[1]/colsum.planned.spend['National TV'],
  colsum.planned.media.activity['Paid Search']*optimum$solution[2]/colsum.planned.spend['Paid Search'],
  colsum.planned.media.activity['Wechat']*optimum$solution[3]/colsum.planned.spend['Wechat'],
  colsum.planned.media.activity['Magazine']*optimum$solution[4]/colsum.planned.spend['Magazine'],
  colsum.planned.media.activity['Display']*optimum$solution[5]/colsum.planned.spend['Display'],
  colsum.planned.media.activity['Facebook']*optimum$solution[6]/colsum.planned.spend['Facebook'])

# check
planned.activity[,c(media.channels)]

####################################### End #######################################

####################################### Grid Search Solution #######################################



# Side Diagnostic
# display by campaign
# search by types
# facebook by campaign
# wechat


??sweep















