library(AppliedPredictiveModeling)
library(caret)
data(permeability)
library("pls")
#
# (B)
#

ncol(fingerprints)

nzv_cols <- nearZeroVar(fingerprints)
if(length(nzv_cols) > 0) fingerprints <- fingerprints[, -nzv_cols]
ncol(fingerprints) ## 388 predictors remain from the original 1107 predictors (719 removed)

#
# (C)
#


## 75% of the sample size
smp_size <- floor(0.75 * nrow(fingerprints))

## set the seed to make your partition reproductible
set.seed(123)
train_ind <- sample(seq_len(nrow(fingerprints)), size = smp_size)
##permeability <- data.frame(permeability)
train_ind_perm <- sample(seq_len(nrow(fingerprints)), size = smp_size)

train_perm <- permeability[train_ind_perm,]
test_perm <- permeability[-train_ind_perm,]

train_fp <- fingerprints[train_ind, ]
test_fp <- fingerprints[-train_ind, ]


## PLS model

ctrl <- trainControl(method = "cv", number = 10)

df_train_fp <- data.frame(train_fp)

#####

plsFit = plsr(train_perm ~ . , data = df_train_fp, ncomp = 20)

## try on test data (316)
plsPred = predict(plsFit, df_train_fp, ncomp = 20)

plsValue = data.frame(obs = train_perm, pred = plsPred[,,1])

defaultSummary(plsValue) 


plsModel <- train(x=train_fp, y = train_perm,
                  method="pls",
                  tuneLength=20,
                  trControl = ctrl,
                  preProc= c("center", "scale"))


## Again, try 10 folds cross validation
set.seed(123)
pls <- train(x = df_train_fp, y = train_perm, method = "pls", tuneGrid = expand.grid(ncomp = 20), trControl = ctrl)
pls

testpls <- data.frame(obs = train_perm, pred = predict(pls, df_train_fp))

defaultSummary(testpls)



## Model tuning
## Run PLS and PCR on solubility data and compare results with 10 folds CV

set.seed(123)
plsTune <- train(x = df_train_fp, y = train_perm, method = "pls", tuneGrid = expand.grid(ncomp = 1:20), trControl = ctrl)
plsTune

testResultsPLS <- data.frame(obs = train_perm, pred = predict(plsTune, df_train_fp))

defaultSummary(testResultsPLS)

set.seed(123)
pcrTune <- train(x = df_train_fp, y = train_perm, method = "pcr", tuneGrid = expand.grid(ncomp = 1:35), trControl = ctrl)
pcrTune                  

plsResamples <- plsTune$results
plsResamples$Model <- "PLS"
pcrResamples <- pcrTune$results
pcrResamples$Model <- "PCR"
plsPlotData <- rbind(plsResamples, pcrResamples)

xyplot(RMSE ~ ncomp,
       data = plsPlotData,
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

###################


# exercise 7.4





