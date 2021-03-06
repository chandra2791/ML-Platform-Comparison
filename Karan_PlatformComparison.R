

# Gradient Boosting, Random Forest, Decision Tree, Neural Nets
rm(list=ls())
setwd('/Users/karannarula/Desktop/R_WorkingDir/ProjectX/SensorData/BioMechFeaturesOrthoPatients')
library(randomForest)
library(rpart)
library(nnet)
library(neuralnet)
library(MASS)
library(gbm)
library(xgboost)

Result <- data.frame()

i=0

j=0


params <- read.csv("/Users/karannarula/Desktop/R_WorkingDir/ProjectX/SensorData/params_AI.csv")
params <- data.frame(params)

for(f in params[,1]){
  
  j=j+1
  RF_ntrees <- params[j,2]
  RF_mtry <- params[j,3]
  GBM_ntrees <- params[j,4]
  GBM_shrinkage <- params[j,5]
  GBM_interaction <- params[j,6]
  GBM_minobs <- params[j,7]
  DT_minsplit <- params[j,8]
  DT_minbucket <- params[j,9]
  DT_maxdepth <- params[j,10]
  NN_size  <- as.numeric(as.list(strsplit(as.character(params[j,11]), ",")[[1]]))
  NN_decay  <- params[j,12]
  
  print("Current File:")
  print(f)
  
  for (s in c("seed1", "seed50", "seed100", "seed150","seed200","seed250","seed300","seed350","seed400","seed450")){
    #for (s in c("seed450")){
    #for (s in c("seed1")){
    
    r1 = 0;r2 = 0;r3 = 0;r4 = 0
    
    i= i+1
    
    train_file <- paste(f,"_Train_",s,".csv",sep="")
    print(train_file)
    train_file_path <- paste("/Users/karannarula/Desktop/R_WorkingDir/ProjectX/SensorData/",f,"/Train/",train_file, sep="")
    print(train_file_path)
    Train <- read.csv(file=train_file_path)
    ncol(Train)
    print(ncol(Train))
    
    Result[i,1] <- train_file
    
    test_file <- paste(f,"_Test_",s,".csv",sep="")
    test_file_path <- paste("/Users/karannarula/Desktop/R_WorkingDir/ProjectX/SensorData/",f,"/Test/",test_file,sep="")
    print(test_file_path)
    Test <- read.csv(file=test_file_path)
    
    Result[i,2] <- test_file
    
    Target_column <- names(Train[ncol(Train)])
    print(Target_column)
    
    
    for ( k in seq(from = 1, to= ncol(Train), by=1)){
      if(is.integer(Train[,k])){
        Train[,k] <- as.numeric(Train[,k])
        
      }
      
    }
    
    for ( k in seq(from = 1, to= ncol(Test), by=1)){
      if(is.integer(Test[,k])){
        Test[,k] <- as.numeric(Test[,k])
        
      }
      
    }
    str(Train)
    #t <- names(Train)
    
    #matrix_fo <- as.formula( paste(" ~ ",Target_column,"+" ,paste(t[!t %in% Target_column], collapse = " + " )) )
    #print(matrix_fo)
    #train_matrix <- model.matrix(matrix_fo, data=Train)
    #print(colnames(train_matrix))
    #Train <- data.frame(train_matrix)
    
    #print(ncol(Train))
    #print(nrow(Train))
    #print("****")
    #test_matrix <- model.matrix(matrix_fo,data=Test)
    #Test <- data.frame(test_matrix)
    
    t <- names(Train)
    print(t)
    fo <- as.formula( paste(Target_column," ~", paste(t[!t %in% Target_column], collapse = " + ") ) )
    print(fo)
    print("2")
    for(column in names(Train)){
      
      if(column %in% colnames(Test)){}
      else{
        Test[column] <- 0
      }
      
    }
    
    
    Y = which( colnames(Train)== Target_column )
    print(Y)
    Target <- Train[,Y]
    print("here")
    Train <- Train[,-Y]
    Train <- cbind(Train, Target)
    names(Train)[ncol(Train)]<- Target_column
    
    Y = which( colnames(Test)== Target_column )
    Target <- Test[,Y]
    Test <- Test[,-Y]
    Test <- cbind(Test,Target)
    names(Test)[ncol(Test)]<- Target_column
    
    
    #################################################################################################################
    #                                                                                                               #
    #                    ############# Random Forest  #############                                                 #
    #                                                                                                               #
    #################################################################################################################
    
    
    print(paste("---- Random Forest Running ----", train_file))
    accuracy <- 0
    precision <- 0
    recall <- 0
    
    start_time <- Sys.time()
    rf.fit <- randomForest(fo, data=Train, ntree=RF_ntrees, mtry=RF_mtry)
    #rf.fit <- randomForest(fo,data=Train,ntree=3)    #For default
    end_time <- Sys.time()
    print("1111111")
    # Decision Tree - Results
    cm <- table(predict(rf.fit,newdata=Test[,c(-ncol(Test))]),Test[,ncol(Test)])
    print("RF cm")
    print(cm)
    accuracy <- sum(diag(cm))/sum(cm)
    
    #precision <- diag(cm) / colSums(cm)
    #recall <- diag(cm) / rowSums(cm)
    #f1 <-  ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))
    
    Result[i,3] <- accuracy
    Result[i,4] <- precision
    Result[i,5] <- recall
    Result[i,6] <- end_time - start_time
    
    #################################################################################################################
    #                                                                                                               #
    #                    ############# Decision Tree  #############                                                 #
    #                                                                                                               #
    #################################################################################################################
    
    print(paste("---- Decision Tree Running ----", train_file))
    accuracy <- 0
    precision <- 0
    recall <- 0
    
    start_time <- Sys.time()
    #dt.fit <- rpart(fo ,data=Train)    # Decision tree
    ctrl = rpart.control(maxdepth=DT_maxdepth,minsplit=DT_minsplit,minbucket=DT_minbucket)
    dt.fit <- rpart(fo, data=Train,control=ctrl)
    
    #dt.fit <- rpart(fo,data=Train)   #For default
    
    end_time <- Sys.time()
    p1 <- predict(dt.fit,Test, type="class")
    print(Test[,ncol(Test)])
    # Decision Tree - Results
    cm <- table(predict(dt.fit,Test, type="class"),Test[,ncol(Test)])
    print("DT cm")
    print(cm)
    accuracy <- sum(diag(cm))/sum(cm)
    
    #precision <- diag(cm) / colSums(cm)
    #recall <- diag(cm) / rowSums(cm)
    #f1 <-  ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))
    
    Result[i,7] <- accuracy
    Result[i,8] <- precision
    Result[i,9] <- recall
    Result[i,10] <- end_time - start_time 
    
    #################################################################################################################
    #                                                                                                               #
    #                    ############# Gradient Boosting #############                                              #
    #                                                                                                               #
    #################################################################################################################
    
    print(paste("---- Gradient Boosting Running ----", train_file))
    accuracy <- 0
    precision <- 0
    recall <- 0
    
    start_time <- Sys.time()
    gb.fit <- gbm(fo,distribution="gaussian",data=Train,n.trees=GBM_ntrees,interaction.depth=GBM_interaction,shrinkage=GBM_shrinkage,n.minobsinnode=GBM_minobs)
    #gb.fit <- gbm(fo,distribution="gaussian",data=Train,n.trees=10,interaction.depth=4,shrinkage=0.01) #For default
    end_time <- Sys.time()
    
    # Gradient boosting - Results
    cm <- table(predict(gb.fit,newdata = Test,n.trees = 400),Test[,ncol(Test)])
    accuracy <- sum(diag(cm))/sum(cm)
    
    #precision <- diag(cm) / colSums(cm)
    #recall <- diag(cm) / rowSums(cm)
    #f1 <-  ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))
    
    Result[i,11] <- accuracy
    Result[i,12] <- precision
    Result[i,13] <- recall
    Result[i,14] <- end_time - start_time 
    
    
    print("Success")
    
  }
  
}

names(Result) <- c("Training Set", "Test Set", "RF.Accuracy" , "RF.Precision","RF.Recall", "RF Time Elapsed",
                   "DT.Accuracy", "DT.Precision","DT.Recall","DT Time Elapsed",
                   "GB.Accuracy","GB.Precision", "GB.Recall","GB Time Elapsed")
#Result <- Result[-1,]
Result
write.csv(Result,"Compiled_Results_AI.csv")
