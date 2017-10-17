library(AppliedPredictiveModeling)
library(caret)
data(permeability)
library("pls")
#
# (B)
#

## here we are filtering out columns with low frequencies 
ncol(fingerprints)
nzv_cols <- nearZeroVar(fingerprints)
if(length(nzv_cols) > 0) fingerprints <- fingerprints[, -nzv_cols]
ncol(fingerprints) ## 388 predictors remain from the original 1107 predictors (719 removed)

#
# (C)
#


## split the data into a test and training data set
## preprocess the data and tune a PLS model

## 75% of the sample size
## this is to split the training and test sets up from the data set
smp_size <- floor(0.75 * nrow(fingerprints))

## set the seed to make your partition reproductible
set.seed(123)

## breaking up the data into training and test data sets for the fingerprint and
## permeability data set

# getting samples

train_ind <- sample(seq_len(nrow(fingerprints)), size = smp_size)
train_ind_perm <- sample(seq_len(nrow(permeability)), size = smp_size)

## test sets

## permeability test and training data sets
train_perm <- permeability[train_ind_perm,]
test_perm <- permeability[-train_ind_perm,]
## fingerprint test and training data set
train_fp <- fingerprints[train_ind, ]
test_fp <- fingerprints[-train_ind, ]


## PLS model

## 10 folds cross validation

ctrl <- trainControl(method = "cv", number = 10)

## need to turn this into a df for the plsFit 
df_test_fp <- data.frame(test_fp)
df_train_fp <- data.frame(train_fp)
plsFit = plsr(train_perm ~ . , data = df_train_fp, ncomp = 20)

## try on test data (316)
plsPred = predict(plsFit, df_test_fp, ncomp = 20)

plsValue = data.frame(obs = test_perm, pred = plsPred[,,1])

defaultSummary(plsValue) 
## RMSE     Rsquared          MAE 
#3 2.070195e+01 4.289488e-04 1.608290e+01 

plsModel <- train(x=train_fp, y = train_perm,
                  method="pls",
                  tuneLength=20,
                  trControl = ctrl,
                  preProc= c("center", "scale"))
plsModel

## Again, try 10 folds cross validation
set.seed(123)
pls <- train(x = df_train_fp, y = train_perm, method = "pls", tuneGrid = expand.grid(ncomp = 20), trControl = ctrl)
pls

testpls <- data.frame(obs = test_perm, pred = predict(pls, df_test_fp))

defaultSummary(testpls)
## RMSE     Rsquared          MAE 
## 2.070195e+01 4.289488e-04 1.608290e+01 


## Model tuning
## Run PLS and PCR on solubility data and compare results with 10 folds CV

## tuning model on PLS and PCR

set.seed(123)
plsTune <- train(x = df_train_fp, y = train_perm, method = "pls", tuneGrid = expand.grid(ncomp = 1:20), trControl = ctrl)
plsTune

testResultsPLS <- data.frame(obs = test_perm, pred = predict(plsTune, df_test_fp))

### PLS test results

defaultSummary(testResultsPLS)

## RMSE         Rsquared   MAE 
## 18.16830210  0.07153656 15.03183106 


set.seed(123)
pcrTune <- train(x = df_test_fp, y = test_perm, method = "pcr", tuneGrid = expand.grid(ncomp = 1:35), trControl = ctrl)
pcrTune      

testResultsPCR <- data.frame(obs = test_perm, pred = predict(pcrTune, df_test_fp))
defaultSummary(testResultsPCR)

## RMSE      Rsquared  MAE 
## 5.5789024 0.8802798 4.0122384 



plsResamples <- plsTune$results
plsResamples$Model <- "PLS"
pcrResamples <- pcrTune$results
pcrResamples$Model <- "PCR"
plsPlotData <- rbind(plsResamples, pcrResamples)

plsPlotData

xyplot(RMSE ~ ncomp,
       data = plsPlotData, ## note this is both pls and pcr data
       #aspect = 1,
       xlab = "# Components",
       ylab = "RMSE (Cross-Validation)",       
       col = c("blue","red"),
       auto.key = list(columns = 2),
       groups = Model,
       type = c("o", "g"))


# variable importance - PLS  Fig. 6.14
plsImp <- varImp(plsTune, scale = FALSE)
plot(plsImp, top = 25, scales = list(y = list(cex = .95)))

# variable importance - PCR
pcrImp <- varImp(pcrTune, scale = FALSE)
plot(pcrImp, top = 25, scales = list(y = list(cex = .95)))


## do a MARS analysis


###################


# exercise 7.4

# install.packages("AppliedPredictiveModeling")
library(AppliedPredictiveModeling)
library(e1071) # misc library including skewness function
library(corrplot)
library(lattice)
library(caret) 

## training set and test set have been assigned --> solTrainX
## Also transformation has been done  --> solTrainXtrans
data(solubility)
library(mlbench)
library(nnet)
#install.packages("earth")
library(earth)
#install.packages("kernlab")
library(kernlab)
#install.packages("pROC")
library(pROC)


set.seed(100)

# generate training data
trainingData = mlbench.friedman1(200,sd=1)

## trainingData$x contains a 200x10 sample predictor data
## Note that 5 of them are related to the response and the remaining five are unrelated random variables 
dim(trainingData$x)
## trainingData$y contains 200 response/outcome data
trainingData$y


## We convert the 'x' data from a matrix to a data frame
## One reason we do this is that this will give the columns names
trainingData$x = data.frame(trainingData$x)
## Look at the data using
featurePlot(trainingData$x, trainingData$y)

## Now generate a large test data set to estimate the error rate
testData = mlbench.friedman1(5000,sd=1)
testData$x = data.frame(testData$x)     ## 5,000 x 10 data samples



set.seed(100)
# Without specifying train control, the default is bootstrap 
knnModel = train(x=trainingData$x, y=trainingData$y, method="knn",
                 preProc=c("center","scale"),
                 tuneLength=10)
knnModel

# plot the RMSE performance against the k
plot(knnModel$results$k, knnModel$results$RMSE, type="o",xlab="# neighbors",ylab="RMSE", main="KNNs for Friedman Benchmark")
