setwd("/Users/ziyuanhan/Desktop/mmm_data/week5")
getwd()

# install.packages('dplyr')
# install.packages('magrittr')
# install.packages('data.table')
library('dplyr')
library('magrittr')
library('data.table')

# ============================================= read data =============================================
df <- read.table("MMM_AF_S11.csv", 
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
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(tv.lag1, tv.pow1, tv.decay1), 'National.TV.GRPs'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(tv.lag2, tv.pow2, tv.decay2), 'National.TV.GRPs'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(magazine.lag1, magazine.pow1, magazine.decay1), 'Magazine.GRPs'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(magazine.lag2, magazine.pow2, magazine.decay2), 'Magazine.GRPs'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(paid.search.lag1, paid.search.pow1, paid.search.decay1), 'Paid.Search'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(paid.search.lag2, paid.search.pow2, paid.search.decay2), 'Paid.Search'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(display.lag1, display.pow1, display.decay1), 'Display'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(display.lag2, display.pow2, display.decay2), 'Display'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(facebook.lag1, facebook.pow1, facebook.decay1), 'Facebook.Impressions'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(facebook.lag2, facebook.pow2, facebook.decay2), 'Facebook.Impressions'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(1,1,1), c(wechat.lag1, wechat.pow1, wechat.decay1), 'Wechat'),
      transformaton_sequence(df.selected.columns, c('lag','power','decay'), c(2,2,2), c(wechat.lag2, wechat.pow2, wechat.decay2), 'Wechat')
)

excluded.cols <- c('National.TV.GRPs', 'Magazine.GRPs', 'Paid.Search', 'Display', 'Facebook.Impressions', 'Wechat')
df <- select(df, -excluded.cols)
































# ========= draft not need =============

tv.lag=1
tv.power=0.8
tv.decay=0.4

ok.1 <- transformation(df.selected.columns, 'lag', 1, 1, 'National.TV.GRPs')
ok.2 <- transformation(ok.1, 'power', 1, 0.8, 'National.TV.GRPs.lag.1')
transformation(ok.2, 'decay', 1, 0.4, 'National.TV.GRPs.lag.1.power.1')[['National.TV.GRPs.lag.1.power.1.decay.1']]

ok.2[['National.TV.GRPs.lag.1.power.1.decay.1']]

ok.2 %>%
  mutate(y1 = purrr::accumulate(lag(ok.2[['National.TV.GRPs.lag.1.power.1.decay.1']]), 
                                ~ok.2[['National.TV.GRPs.lag.1.power.1.decay.1']]* 2 + ok.2[['National.TV.GRPs.lag.1.power.1']], .init = 1))



mutate(y1 = purrr::accumulate(x[-n()], ~.x * 2 +  .y, .init = 1))
purrr::accumulate(lag(x, default = 1), ~ 2*.x + .y)

purrr::accumulate(1:10, ~.^2, .init=3)
lag(ok.2[['National.TV.GRPs.lag.1.power.1']])

purrr::accumulate(ok.2[['National.TV.GRPs.lag.1.power.1']], ~.x * 0.6 +  .y*0.4)
purrr::accumulate(1:8, ~.x +  .y*2, .init = 1)

transformation(df.lagged, 'decay',1,0.2,'National.TV.GRPs',previous.transformation.column='National.TV.GRPs.lag1')






df.lagged <- df.selected.columns %>%
  # tv
  mutate(df.selected.columns, National.TV.GRPs.lag1= lag(df.selected.columns$National.TV.GRPs, tv.lag1)) %>%
  mutate(df.selected.columns, National.TV.GRPs.lag2= lag(df.selected.columns$National.TV.GRPs, tv.lag2)) %>%
  # magazine
  mutate(df.selected.columns, Magazine.GRPs.lag1= lag(df.selected.columns$Magazine.GRPs, magazine.lag1)) %>%
  mutate(df.selected.columns, Magazine.GRPs.lag2= lag(df.selected.columns$Magazine.GRPs, magazine.lag2)) %>%
  mutate_if(is.numeric, ~replace(., is.na(.), 0))

head(df.selected.columns)
head(df.lagged)
  
df.decayed <- copy(df.lagged)
df.decayed$National.TV.GRPs.decay1 <- copy(df.decayed$National.TV.GRPs.lag1)
df.decayed$Magazine.GRPs.decay1 <- copy(df.decayed$Magazine.GRPs.lag1)

tv.decay1 = 0.2
df.decayed <- df.decayed %>%
  # tv
  mutate(df.lagged, National.TV.GRPs.decay1= lag(df.decayed$National.TV.GRPs.decay1, 
                    1, default = first(National.TV.GRPs.decay1)) * (1-tv.decay1) + df.lagged$National.TV.GRPs.lag1 * tv.decay1)
  
  
  mutate(df.lagged, National.TV.GRPs.decay2= lag(df.decayed$National.TV.GRPs.decay2, 
                    1, default = first(National.TV.GRPs.decay2)) * (1-tv.decay2) + df.lagged$National.TV.GRPs.lag2 * tv.decay2) %>%
  # magazine
  mutate(df.lagged, Magazine.GRPs.decay1= lag(df.decayed$Magazine.GRPs.decay1, 
                    1, default = first(National.TV.GRPs.decay1)) * (1-tv.decay1) + df.lagged$National.TV.GRPs.lag1 * tv.decay1) %>%
  mutate(df.lagged, National.TV.GRPs.decay2= lag(df.decayed$National.TV.GRPs.decay2, 
                    1, default = first(National.TV.GRPs.decay2)) * (1-tv.decay2) + df.lagged$National.TV.GRPs.lag2 * tv.decay2) %>%
  
  
  # mutate_if(is.numeric, ~replace(., is.na(.), 0))
  
head(df.decayed)
  



# lag
# mutate(df2, llpm102= lag(pm10))

head(df$Period)
head(lag(df$Period,1))
head(lead(df$Period,1))

# decay

# power





