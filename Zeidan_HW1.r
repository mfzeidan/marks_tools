# Applied Predictive Modeling Chapter 3: Exercise 3.1




library(AppliedPredictiveModeling)
library(caret)
library(e1071) # misc library including skewness function
library(mlbench)


### Question 1

data(Glass)

# (a) Using visualizations, explore the predictor variables to understand their 
# distributions as well as the relationships between predictors.


#########
p <- ggplot(Glass,aes(x=Type))
p <- p + geom_bar(fill="light blue", color="black")      
p <- p + ggtitle("Number of Observations by Type of Glass")
p

# most glass is either type 1 or type 2
########

#average makeup of compound by glass

aggregate(Glass[,1:9],list(Glass$Type),mean)

## Can start to see that some elements are consistent throughout the types of glass, such as RI and Si
## However, elements like MG, K and Ba offer some promise to figure out which glass is which based on its element makeup

## Box Plots of compound by glass type to visualize what glass types more often contain a specific type of compound.

### RI - compound 1

plot(Glass$Type,Glass[,1],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[1],main=paste("Series Chart",1,": Box Plot of Chemical Elements",
                                                          names(Glass)[1],"by Type of Glass"))

## relativly consistent, most outliers lie in glass type 2

### NA - compound 2


plot(Glass$Type,Glass[,2],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[2],main=paste("Series Chart",2,": Box Plot of Chemical Elements",
                                                          names(Glass)[2],"by Type of Glass"))
## relatively stable through all glass types


# relatively consistent

### Mg - compound 3

plot(Glass$Type,Glass[,3],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[3],main=paste("Series Chart",3,": Box Plot of Chemical Elements",
                                                          names(Glass)[3],"by Type of Glass"))
#lots of differences here, high MG content leads one to predict its most likely types 1,2, or 3 of the glass.
## low mg content 

### Al - compound 4


plot(Glass$Type,Glass[,4],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[4],main=paste("Series Chart",4,": Box Plot of Chemical Elements",
                                                          names(Glass)[4],"by Type of Glass"))

# types 5 6 and 7 on average have more Al

### Si - compound 5

plot(Glass$Type,Glass[,5],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[5],main=paste("Series Chart",5,": Box Plot of Chemical Elements",
                                                          names(Glass)[5],"by Type of Glass"))
#relatively stable throughout

### K - compound 6


plot(Glass$Type,Glass[,6],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[6],main=paste("Series Chart",6,": Box Plot of Chemical Elements",
                                                          names(Glass)[6],"by Type of Glass"))
# relatively stable throughout

### Ca - compound 7

plot(Glass$Type,Glass[,7],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[7],main=paste("Series Chart",7,": Box Plot of Chemical Elements",
                                                          names(Glass)[7],"by Type of Glass"))
## highest Ca content belongs to type 5

### Ba - compound 8


plot(Glass$Type,Glass[,8],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[8],main=paste("Series Chart",8,": Box Plot of Chemical Elements",
                                                          names(Glass)[8],"by Type of Glass"))

## most types of glass do not have much Ba besides type 7

### Fe - compound 9


plot(Glass$Type,Glass[,9],col="light blue",
     xlab="Type of Glass",ylab=names(Glass)[9],main=paste("Series Chart",9,": Box Plot of Chemical Elements",
                                                          names(Glass)[0],"by Type of Glass"))

## most types of glass that have Fe belong to types 1 2 or 3

###########################################################################
### check skewness of compounds
skewness(Glass$RI) ## 1.6
skewness(log(Glass$RI)) ## 1.6
skewness(Glass$Na) # 0.44
skewness(log(Glass$Na)) ## 0.03
skewness(Glass$Mg) # -1.13
skewness(log(Glass$Mg)) ## nan
skewness(Glass$Al) # 0.89
skewness(log(Glass$Al)) ## -0.83
skewness(Glass$Si) # -0.72
skewness(log(Glass$Si)) ## -0.79
skewness(Glass$K) # 6.46
skewness(log(Glass$K)) ## nan
skewness(Glass$Ca) # 2.02
skewness(log(Glass$Ca)) ## 1.05
skewness(Glass$Ba) # 3.37
skewness(log(Glass$Ba)) ## -0.79
skewness(Glass$Fe) # 1.73
skewness(log(Glass$Fe)) ## nan

# the most skewed predictors are Si, Ba and Ca


## are there any relevevant transformations of one or more predictors?

#1 preprocess the data
glassPP <- preProcess(Glass, method = "BoxCox")
#2 predict (preprocess variable from 1, data)
glassPred <- predict(glassPP,Glass)

max(glassPred$RI)/min(glassPred$RI)
max(glassPred$Na)/min(glassPred$Na)
max(glassPred$Mg)/min(glassPred$Mg)
max(glassPred$Al)/min(glassPred$Al)
max(glassPred$Si)/min(glassPred$Si)
max(glassPred$K)/min(glassPred$K)
max(glassPred$Ca)/min(glassPred$Ca)
max(glassPred$Ba)/min(glassPred$Ba)
max(glassPred$Fe)/min(glassPred$Fe)

## none of the calculations above result in a difference of 20

###

#glassPP$bc$RI

#histogram(Glass$RI, xlab = "Natural Units", type="count")
#histogram(segTrainTrans$RI, xlab = "Natural Units", type="count")


# (c) Are there any relevant transformations of one or more predictors that
# might improve the classification model?

# Apply Boxcox, center, and scale transformations
glassPP <- preProcess(Glass, c("BoxCox", "center", "scale"))
glassPred <- predict(glassPP, Glass)

# Apply PCA on all predictors
Glass$Type <- as.numeric(Glass$Type)

glassPCA <- prcomp(Glass, center = TRUE, scale. = TRUE)
transparentTheme(pchSize = .8, trans = .3)

panelRange <- extendrange(glassPCA$x[, 1:3])
splom(as.data.frame(glassPCA$x[, 1:3]), 
      groups = , 
      type = c("p", "g"), 
      as.table = TRUE, 
      auto.key = list(columns = 2), 
      prepanel.limits = function(x) panelRange)

## compute the percentage of variance for each component
percentVariancePCA = glassPCA$sd^2/sum(glassPCA$sd^2)*100

sum(percentVariancePCA[1:4])   # first 4 components account for 79% of variance
plot(percentVariancePCA, xlab="Component", ylab="Percentage of Total Variance", type="l", main="PCA")





## To filter on correlations, we first get the correlation matrix for the predictor set

glassCorr <- cor(glassPred)

library(corrplot)
corrplot(glassCorr, order = "hclust", tl.cex = .35)

## caret's findCorrelation function is used to identify columns to remove.
highCorr <- findCorrelation(glassCorr, cutoff = .75)  # correlation coefficient > 0.75


filteredGlassData = glassPred#[, -highCorr]

cor_data <- cor(filteredGlassData.r.)
# new plot 
corrplot(cor_data, order = "hclust", tl.cex = .35)


#### QUESTION 3.2

library(mlbench)
library(dplyr)
data(Soybean)


# (a)Investigate the frequency distributions for the categorical predictors. 
#   Are any of the distributions degenerate in the ways discussed earlier in this chapter?

unique(Soybean$Class, incomparable=FALSE) ## there are 19 different classes in this dataset
sapply(Soybean, function(x) length(unique(x)))


## there are no degenerate distributions in the dataset as all values have at least more then 1 unique value within


########

# Roughly 18 % of the data are missing. 
# Are there particular predictors that are more likely to be missing? 
# Is the pattern of missing data related to the classes?
data(Soybean)

### shows me how many predictors have over 100 NA values in the data
sapply(Soybean, function(x) sum(is.na(x))) > 100

cols <- c("Class", "leaf.mild","germ","lodging","fruiting.bodies","hail","seed.tmt","sever","fruit.spots","seed.discolor","shriveling")


## getting a subset of data containing only the columns where NA values total to over 100
## trying to see if there is a pattern in what predictors have the most NA values
Soybean_NA <- Soybean[,cols]
#Soybean_NA

## adding a column to the subset of data to let me figure out which predictors have the highest number of NA values
Soybean_NA$na_count <- apply(Soybean_NA, 1, function(x) sum(is.na(x)))
Soybean_NA
## removing the variables in the dataset to just leave the soybean type and its total number of NAs related
cols <- c("Class","na_count")
Soybean_NA <- Soybean_NA[,cols]
Soybean_NA

SB_na <- aggregate(. ~ Class, Soybean_NA, sum)


SB_na


# the following classes have multiple NA values related to their related variables
# 2-4-d injury
# cyst-nematode
# diaporthe-pod-&-stem-blight
# herbicide-injury
# phytophthora-rot

# For the classes above when conducting analysis, I would remove the 10 columns listed blow
# "leaf.mild","germ","lodging","fruiting.bodies","hail","seed.tmt","sever","fruit.spots","seed.discolor","shriveling"
# when trying to make predictions for the classes listed above due to there being too many NA measures
# related to the dataset.

