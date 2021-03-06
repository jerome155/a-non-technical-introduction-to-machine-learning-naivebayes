#Trains a Gaussian Naive Bays Model that can be used with 
#function NaiveBayes_Predict.
NaiveBayes_TrainModel <- function(train_data, train_data_dependent_column, 
                                  train_data_feature_columns) {
  
  #Data juggling to get the data into the right format.
  y = train_data[,train_data_dependent_column]
  trainSet = train_data[,train_data_feature_columns]
  #Create dummy feature for Y.
  dummy1 <- as.numeric(train_data$Y == 1)
  dummy0 <- as.numeric(train_data$Y == 0)
  
  train_data <- cbind(train_data, dummy0, dummy1)
  colnames(train_data)[5:6] <- c("0", "1")
  
  #Step 1 (Slide 7): Define P(A), calculate the probability.
  class.probability <- aggregate(train_data[, train_data_dependent_column], 
                                 by=list(train_data[,train_data_dependent_column]),
                                 FUN="length")
  class.probability[,'x'] <- class.probability[,'x'] / 
    sum(class.probability[,'x'])
  
  #Step 2 (Slide 8): Define P(B|A), separate the data and calculate mean / 
  #standard deviation (sd).
  likelihood.mean <- aggregate(train_data[, train_data_feature_columns], 
                               by=list(train_data[,train_data_dependent_column]), 
                               FUN="mean")
  likelihood.sd <- aggregate(train_data[, train_data_feature_columns], 
                             by=list(train_data[,train_data_dependent_column]), 
                             FUN="sd")
  
  #Pack all generated information / data into a container and return it (=model).
  model = list("class.probability" = class.probability,
               "likelihood.mean" = likelihood.mean, 
               "likelihood.sd" = likelihood.sd,
               "train_data_feature_columns" = train_data_feature_columns,
               "train_data_dependent_column" = train_data_dependent_column
  )
  
  return(model)
}

#Step 4 (Slide 16ff): Predicts a new data point based on a model generated in 
#NaiveBayes_TrainModel
NaiveBayes_Predict <- function(model, prediction_data) {
  
  pOfBgivenA <- data.frame()
  
  i=1
  #Calculate probability under assumption of normal distribution for the 
  #two features.
  for (i in 1:length(model$train_data_feature_columns)) {
    pOfBgivenAYnX1 <- ProbabilityUnderNormalDistribution(prediction_data['X1'],  
                                                         model$likelihood.mean[i,'X1'], 
                                                         model$likelihood.sd[i, 'X1'])
    pOfBgivenAYnX2 <- ProbabilityUnderNormalDistribution(prediction_data['X2'],  
                                                         model$likelihood.mean[i,'X2'], 
                                                         model$likelihood.sd[i, 'X2'])
    pOfBgivenAYn <- pOfBgivenAYnX1*pOfBgivenAYnX2*model$class.probability[i, 'x']
    #Use a data.frame to store the results
    pOfBgivenA[i,'res'] <- pOfBgivenAYn
    i=i+1
  }
  
  i=1
  #Normalization of the result.
  for (i in 1:nrow(pOfBgivenA)) {
    pOfBgivenA[i, 'normalizedOut'] <- pOfBgivenA[i,'res'] / sum(pOfBgivenA[,'res'])
    i=i+1
  }
  
  return(pOfBgivenA)
}

#Calculates the probability under assumption of normal distribution. mu = mean, 
#sd = standard deviation.
ProbabilityUnderNormalDistribution <- function(x, mu, sd) {
  (1/(sqrt(2*pi)*sd))*(exp(1)^(-1*(((x-mu)^2)/(2*(sd^2)))))
}

#Input data from the slides
train_data <- data.frame(index = c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10"),
                         Y = c(0L, 0L, 0L, 0L, 1L, 1L, 1L, 1L, 1L, 0L),
                         X1 = c(2, 2.8, 1.5, 2.1, 5.5, 8, 6.9, 8.5, 2.5, 7.7),
                         X2 = c(1.5, 1.2, 1, 1, 4, 4.8, 4.5, 5.5, 2, 3.5))

#Define where the columns reside in the data frame by creating name vectors:
train_data_dependent_column = "Y"
train_data_feature_columns = colnames(train_data)[c(-1,-2)]

model <- NaiveBayes_TrainModel(train_data, train_data_dependent_column, train_data_feature_columns)

prediction_data = data.frame(X1 = c(3.19), X2 = c(1.5))

result <- NaiveBayes_Predict(model, prediction_data)
result

```