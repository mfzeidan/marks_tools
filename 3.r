


library(caret)
library(mlbench)
library(randomForest)

set.seed(200)
simulated <- mlbench.friedman1(200,sd=1)
simulated <- cbind(simulated$x,simulated$y)
simulated <- as.data.frame(simulated)
colnames(simulated)[ncol(simulated)] <- "y"

model1 = randomForest(y ~ .,data=simulated, importance=TRUE,ntree = 1000)
rfImp1 = varImp(model1,scale = FALSE)
rfImp1 = rfImp1[ order(-rfImp1), ,drop = FALSE]
print("random forest ( no correlatedpredictors")
print(rfImp1)

## part b now add an additional predictor that is highly correlated with one of the informative predctors

simulated$duplicate1 = simulated$V1 + rnorm(200) * 0.1
cor(simulated$duplicate1, simulated$V1)

model2 = randomForest( y ~ ., data = simulated, importance = TRUE, ntree = 1000)
rfImp2 = varImp(model2, scale = FALSE)
rfImp2 = rfImp2[order(-rfImp2), , drop = FALSE]
print("random forest - one correlated predictor")
print(rfImp2)


simulated$duplicate2 = simulated$V1 + rnorm(200) * 0.1
cor(simulated$duplicate2, simulated$V1)

model3 = randomForest( y ~ ., data = simulated, importance = TRUE, ntree = 1000)
rfImp3 = varImp(model3, scale = FALSE)
rfImp3 = rfImp3[order(-rfImp3), , drop = FALSE]
print("random forest - two correlated predictor")
print(rfImp3)


##--------------  QUESTION 8.4 (A-B) ----------------

library(caret)
library(AppliedPredictiveModeling)
library(rpart)
library(randomForest)

set.seed(0)

data(solubility)

## solTrainX - training set predictors in natural units

## solTrainXTrans - training set predictors after transformation for skewness and centering/scaling

## solTrainY - vector of a log10 solubility values for the training set

## solTestX - test set predictors in their natural units

## solTestXtrans - test set predictors after the same transofrmations used on the training 
                  ## set are applied

## solTestY - a vector of log10 solubiliy values for the training set

## we dont want to use the unscaled variables by accident so let's just remove them at the beginning

rm(solTrainx)
rm(solTestx)

trainData = data.frame( x = solTrainXtrans$MolWeight, y = solTrainY)

plot( trainData$x, trainData$y, xlab = 'MolWeight', ylab = 'log10(solubility')

lmModel = lm(y ~ ., data = trainData)
lm_yhat = predict(lmModel, newdata = data.frame(x = solTestXtrans$MolWeight) )
plot ( solTestY, lm_yhat)


### PART A - fit a simple regression tree

rPartModel = rpart( y ~ ., data=trainData,
                    method = "anova", 
                    control = rpart.control(cp=0.01,maxdepth = 30))
            ### decreasing cp makes deeper trees, increasing maxdepth

plotcp(rPartModel)

## plot the regression tree

plot(rPartModel); text(rPartModel)


rPart_yHat = predict(rPartModel, newdata = data.frame(x = solTestXtrans$MolWeight))
plot(solTestXtrans$MolWeight, rPart_yHat, col = 'red', xlab = 'MolWeight',
     ylab = 'log10(solubility)', main = 'rpart test set predict')
lines(solTestXtrans$MolWeight, solTestY, type = 'p')

## part B - fit a random forest

rfModel = randomForest( y ~ ., data=trainData, ntree = 500) 

# predict solubility

rf_yHat = predict(rfModel, newdata = data.frame(x=solTestXtrans$MolWeight))

plot( solTestXtrans$MolWeight, rf_yHat, col = 'red', xlab = 'MolWeight',
      ylab = 'log10(solubility)', main = 'randomForest test set predictions')
lines (solTestXtrans$MolWeight, solTestY, type = 'p')



