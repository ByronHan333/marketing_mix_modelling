setwd("/Users/ziyuanhan/Desktop/mmm_data/week5")
getwd()

install.packages('corrplot')
library(corrplot)

set.seed(1234)

# ============================ read data ============================ 
df <- read.table("MMM_AF_S11.csv", 
                 header = TRUE,
                 sep = ",")
head(df, n=6)

df$Period <- as.Date(df$Period, format = '%m/%d/%Y')

# ============================ EDA plot 1 ============================
plot(df$Period,df$Sales, type = 'l', xlab = 'period', ylab = 'sales')

par (new=TRUE)
plot(df$Period, df$Sales.Event, type='l', col='green', xlab='', ylab='', axes=FALSE)
axis(side=4)

# ============================ EDA plot 2 ============================ 
# correaltion matrix
correl = cor(df[,c(-1,-2)])
write.csv(correl, file='correlation_matrix.csv')

corrplot(correl, tl.cex=0.8, tl.col='black')





# scatter plot not used
plot(df$Facebook.Impressions, df$Sales, xlab='Faceboook Impresion', ylab='Sales')