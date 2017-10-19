library(AppliedPredictiveModeling)
library(caret)
data(permeability)
library(elasticnet)
library("pls")


## B
set.seed(123)

data(permeability)
zeroColumns = nearZeroVar(fingerprints)
print( sprintf("Found %d zero variance columns from %d",length(zeroColumns), dim(fingerprints)[2] ) )
fingerprints = fingerprints[,-zeroColumns] # drop these zero variance columns 

## 388 predictors remain from the original 1107 predictors (719 removed)

## C

smp_size <- floor(0.75 * nrow(fingerprints))

## set the seed to make your partition reproductible
set.seed(123)


train_ind <- sample(seq_len(nrow(fingerprints)), size = smp_size)
train_ind_perm <- sample(seq_len(nrow(permeability)), size = smp_size)
train_fp <- fingerprints[train_ind, ]
test_fp <- fingerprints[-train_ind, ]
train_perm <- permeability[train_ind,]
test_perm <- permeability[-train_ind,]

set.seed(123)

control <- trainControl(method="cv")

plsModel_training = train( train_fp, train_perm, method="pls",
                   tuneLength=40, 
                   preProcess=c("center","scale"), 
                   trControl=control )

plsModel_training

y_hat_train = predict(plsModel_training, newdata = train_fp)
r2_pls_train = cor(y_hat_train, train_perm, method="pearson")^2
rmse_pls_train=sqrt( mean( y_hat_train-train_perm)^2)
plsPR_train <- postResample(y_hat_train, obs=train_perm)
plsPR_train


plot(x=plsModel_training$results$ncomp, y= plsModel_training$results$Rsquared)

##How many latent variables are optimal - 7
# what is the corresponding resampled estimate of R2 - 0.79

##  (D)

y_hat = predict(plsModel, newdata = test_fp)
r2_pls = cor(y_hat, test_perm, method="pearson")^2
rmse_pls=sqrt( mean( y_hat-test_perm)^2)
plsPR <- postResample(y_hat, obs=test_perm)
plsPR

# Test set estimate of R2 is 0.465


###################


# exercise 7.4

#II. (2.5 point) Chapter 7, Exercise 7.4 (p.170). For this problem, 
#please try at least 3 out of the 4 methods we have discussed: neurnal networks, SVM, MARS, and kNN.


library(caret)
library(AppliedPredictiveModeling)

set.seed(123)
## KNN Model

knnModel = train(x = train_fp, 
                 y = train_perm, 
                 method = "knn",
                 preProc = c("center","scale"),
                 tuneLength = 10)
knnPred = predict(knnModel, newdata = train_fp)
knnPR = postResample(pred=knnPred, obs = train_perm)
rmses_training = c(knnPR[1])
r2s_training = c(knnPR[2])
methods = c("KNN")

knnPred = predict(knnModel, newdata=test_fp)
knnPR = postResample(pred = knnPred, obs = test_perm)
knnPR
#RMSE  Rsquared       MAE 
#14.117169  0.403577  9.516708 


### neural network

  nnGrid = expand.grid( .decay = c(0,0.01,0.1), .size=1:10, .bag=FALSE)
  set.seed(123)
  nnetModel = train(x = train_fp, y = train_perm, method = "nnet", preProc = c("center","scale"),
                    linout = TRUE, trace=FALSE, 
                    MaxNWts = 10*(ncol(train_fp)+1) + 10 + 1, maxit = 500)
  
  nnetPred = predict(nnetModel, newdata = train_fp)
  nnetPR = postResample(pred = nnetPred, obs = train_perm)
  nnetPR ## get the r2 from this
  
  #RMSE   Rsquared        MAE 
  #10.1196546  0.5232648  6.8136310 

  nnetPred_test = predict(nnetModel, newdata = test_fp)
  nnetPR_test = postResample(pred = nnetPred_test, obs = test_perm)
  nnetPR_test # get the r2 from this
  
 # RMSE   Rsquared        MAE 
 #16.3563674  0.2074993 11.3851790 



## support vector machine

set.seed(123)
svmModel = train(x=train_fp, y = train_perm, 
                 method = "svmRadial", 
                 preProc = c("center","scale"),
                 tuneLength = 20)
svmPred_train = predict(svmModel, newdata = train_fp)
svmPR_train = postResample(pred=svmPred_train, obs = train_perm)
svmPR_train

#RMSE  Rsquared       MAE 
#1.5029363 0.9963344 1.4564040 

svmPred = predict(svmModel, newdata=test_fp)
svmPR = postResample(pred = svmPred, obs = test_perm)
svmPR

#RMSE    Rsquared         MAE 
#17.90744398  0.06586038 13.95337609 

