  

library(caret)
library(AppliedPredictiveModeling)
library(pROC)


data(oil)
table(oilType)
table(oilType) / sum(table(oilType))


## chapter 12

## a if data has significant imbalances, should data be split into test and training data sets?

## The data should still be split into testing and training data sets

## b which classification stat would be used to optimize 

## confusion matrix score

## c which model is best?


  
build_PCC_linear_models = function(x, y, seed_value=150){

  set.seed(seed_value)
  lda.classifier = train( X, y, method="lda", preProc=c("center","scale") )
  y_hat = predict( lda.classifier, X )
  cm = confusionMatrix( data=y_hat, reference=y )
  
  lda=list( classifier=lda.classifier, confusionMatrix=cm )
  
  glmnGrid = expand.grid(.alpha=c(0, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0), .lambda=seq( 0.01, 0.2, length=65))
  set.seed(seed_value)
  glmnet.classifier = train( X, y, method="glmnet", tuneGrid=glmnGrid, preProc=c("center","scale") )
  y_hat = predict( glmnet.classifier, X )
  cm = confusionMatrix( data=y_hat, reference=y )
  glmnet=list( Classifier=glmnet.classifier, confusionMatrix=cm )

  nscGrid = expand.grid(.threshold=0:25)
  set.seed(seed_value)
  nsc.classifier = train( X, y, method="pam", tuneGrid=nscGrid, preProc=c("center","scale") )
  y_hat = predict( nsc.classifier, X )
  cm = confusionMatrix( data=y_hat, reference=y )
  nsc=list( classifier=nsc.classifier, confusionMatrix=cm )
  
  return( list( lda=lda, glmnet=glmnet, nsc=nsc ) )
  
}


zv_cols = nearZeroVar(fattyAcids)
print( sprintf("Dropping %d zero variance columns from %d (fraction=%10.6f)", length(zv_cols), dim(fattyAcids)[2], length(zv_cols)/dim(fattyAcids)[2]) );
X = fattyAcids

print( findLinearCombos(X) )

linear_models = build_PCC_linear_models( X, oilType )

# Present the sampled accuracy estimates for each model:
#
df = rbind( data.frame(name="LDA", Accuracy=linear_models$lda$confusionMatrix$overall[1]),
            data.frame(name="GLMNET", Accuracy=linear_models$glmnet$confusionMatrix$overall[1]),
            data.frame(name="NSC", Accuracy=linear_models$nsc$confusionMatrix$overall[1]) )
rownames(df) = NULL

# Order our dataframe by performance:
#
df = df[ with( df, order(Accuracy) ), ]
print( "ACCURACY Performance on the oil dataset" )
print( df )

# For the NSC model ... where is it making its errors:
#


## C- The best model is GLMNET

print( linear_models$nsc$confusionMatrix )

###### CHAPTER 13


build_PCC_nonlinear_models = function(X, y, seed_value=150, build_mda_model=TRUE){

  if( build_mda_model ){
    set.seed(seed_value)
    mda.classifier = train( X, y, method="mda", tuneGrid=expand.grid(.subclasses=1:2) )
    mda.predictions = predict( mda.classifier, X )
    cm = confusionMatrix( data=mda.predictions, reference=y )
    mda=list( classifier=mda.classifier, predictions=mda.predictions, confusionMatrix=cm )
  }
  
  # Neural Networks:
  #
  set.seed(seed_value)
  nnetGrid = expand.grid( .size=1:5, .decay=c(0,0.1,1,2) )
  nnet.classifier = train( X, y, method="nnet", preProc=c("center","scale","spatialSign"), tuneGrid=nnetGrid, trace=FALSE, maxit=2000 )
  nnet.predictions = predict( nnet.classifier, X )
  cm = confusionMatrix( data=nnet.predictions, reference=y )
  nnet=list( classifier=nnet.classifier, predictions=nnet.predictions, confusionMatrix=cm )
  
  # Support Vector Machines:
  #
  library(kernlab)
  sigmaEst = kernlab::sigest( as.matrix(X) )
  svarid = expand.grid(.sigma=sigmaEst[1], .C=2^seq(-4,+4))
  set.seed(seed_value)
  svm.classifier = train( X, y, method="svmRadial", tuneGrid=svarid, preProc=c("center","scale"), fit=FALSE )
  svm.predictions = predict( svm.classifier, X )
  cm = confusionMatrix( data=svm.predictions, reference=y )
  svm=list( classifier=svm.classifier, predictions=svm.predictions, confusionMatrix=cm )
  
  # K-Nearest Neighbors:
  #
  set.seed(seed_value)
  knn.classifier = train( X, y, method="knn", tuneLength=20, preProc=c("center","scale") )
  knn.predictions = predict( knn.classifier, X )
  cm = confusionMatrix( data=knn.predictions, reference=y )
  knn=list( classifier=knn.classifier, predictions=knn.predictions, confusionMatrix=cm )
  
  # Naive Bayes:
  #
  nbGrid = expand.grid(.fL=c(1,2), .usekernel=c(T,F))
  set.seed(seed_value)
  nb.classifier = train( X, y, method="nb", tuneGrid=nbGrid )
  nb.predictions = predict( nb.classifier, X )
  cm = confusionMatrix( data=nb.predictions, reference=y )
  nb=list( classifier=nb.classifier, predictions=nb.predictions, confusionMatrix=cm )
  
  result = list( nnet=nnet, svm=svm, knn=knn, nb=nb )
  if( build_mda_model ){ result = c(result, list(mda=mda)) }
  return( result )
}

data(oil)

# Part (a):
#
zv_cols = nearZeroVar(fattyAcids)
print( sprintf("Dropping %d zero variance columns from %d (fraction=%10.6f)", length(zv_cols), dim(fattyAcids)[2], length(zv_cols)/dim(fattyAcids)[2]) );
X = fattyAcids

# There are no linearly dependent columns remaining (or to start with)
print( findLinearCombos(X) )

  nonlinear_models = build_PCC_nonlinear_models( X, oilType )


# Present the sampled accuracy estimates for each model:
#
df = rbind( data.frame(name="MDA", Accuracy=nonlinear_models$mda$confusionMatrix$overall[1]),
            data.frame(name="NNET", Accuracy=nonlinear_models$nnet$confusionMatrix$overall[1]),
            data.frame(name="SVM", Accuracy=nonlinear_models$svm$confusionMatrix$overall[1]),
            data.frame(name="KNN", Accuracy=nonlinear_models$knn$confusionMatrix$overall[1]),
            data.frame(name="NB", Accuracy=nonlinear_models$nb$confusionMatrix$overall[1]) )
rownames(df) = NULL

# Order our dataframe by performance:
#
df = df[ with( df, order(Accuracy) ), ]
print( "ACCURACY Performance on the oil dataset" )
print( df )

# For the SVM model ... where is it making its errors:
#
print( nonlinear_models$svm$confusionMatrix )


#### 14


## Bagging

A.Cl
DR.1960

##Random Forests

Unsuccess.Cl
Success.Cl
SponsorUnk
Day
Sponsor21A
allPub
Sponsor4D

### GBM

Unsuccess.Cl
Success.Cl
Day










