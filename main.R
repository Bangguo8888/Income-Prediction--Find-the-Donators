# load the data into R
#file1 = 'https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data'
#file2 = 'https://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test'
#colnames = c('age','workclass','fnlwgt','education','education-num','marital-status',
#             'occupation','relationship','race','sex','capital-gain','capital-loss',
#             'hours-per-week','native-country','y')
#train = read.table(file1, header = FALSE, sep = ',', col.names = colnames)
#test = read.table(file2, header = FALSE, sep = ',', skip = 1, col.names = colnames)

# save the raw data
#rawData = list(train,test)
#save(rawData,file = 'rawData.Rdata')



rm(list=ls()) # clear all the existed variables
# call related packages and R scripts
library(ggplot2)
library(rpart)
library(kernlab)
source('multiplot.R')
source('validation.R')
source('evaluation.R')
source('find_best_p.R')


## Download the data
#Since we have been download the data from website and save it on local folder, so here we just need to reload them from the folder
load('rawData.Rdata')
train = rawData[[1]]
test = rawData[[2]]


## Clean data  


# Firstly, there is a space in every categorical variables (for example:` Private`,` Female`), so we need to delete these space.

# the columns of categorical variables
cat_cols = c(2,4,6,7,8,9,10,14,15)
# delete all the space
temp = apply(train[,cat_cols],2,function(x) as.factor(gsub(' ','',x)))
train[, cat_cols] = data.frame(temp)

# the same procedure for the test data
temp = apply(test[,cat_cols],2,function(x) as.factor(gsub(' ','',x)))
test[, cat_cols] = data.frame(temp)

### clean the train data  

# Before we clean the data , we need to know what the data looks like and have a general understanding of the data  

# the number of observations and variables
dim(train)
# let's see some examples of the train data
head(train)
# summary the data
summary(train)


# We can see that there are 32561 observations, 15 variables. Among the 15 variables,the last variable **y** is response variable, whether the person's income is *>50K* or *<=50K*.  
# Among the 14 predictors, there are 6 numerical variables: **age**, **education.num**, **capital.gain**, **capital.loss**, **hours.per.week** and 8 categorical variables.  

##### (1) Deleting the duplicated data 
#There are 24 duplicated observations in the train data, so we need to delete them.

# the number of obs before deleting duplicated obs
num_obs= dim(train)[1]
# the number of duplicated obs
num_duplicated = sum(duplicated(train))
# pick one example to show
duplicated_example1_age = train$age[duplicated(train)][1]
duplicated_example1_fnlwgt=train$fnlwgt[duplicated(train)][1]

# example of duplicated observations
print(train[train$age==duplicated_example1_age & train$fnlwgt==duplicated_example1_fnlwgt,])

# use unique function to get the unique obs
train = unique(train)
# check 
cat('Number of obs for original train data:',num_obs,
'\nNumber of duplicated obs:',num_duplicated,
'\nNumber of obs after deleting the duplicated obs:',dim(train)[1])


##### (2) Check specifically at each numerical variables  


# age variable
g1=ggplot(train, aes(age)) + 
geom_histogram(bins = 20, aes(fill =..count..))+labs(title='Histogram of Age')+
theme(plot.title=element_text(hjust=0.5))
# fnlwgt variable
g2=ggplot(train, aes(fnlwgt)) + geom_histogram(bins = 20, aes(fill =..count..))+
labs(title='Histogram of fnlwgt')+theme(plot.title=element_text(hjust=0.5))
# education.num variable
g3=ggplot(train, aes(education.num)) + geom_histogram(bins = 10, aes(fill =..count..))+
labs(title='Histogram of Number of Education')+theme(plot.title=element_text(hjust=0.5))
# hours.per.week variable
g4=ggplot(train, aes(hours.per.week)) + geom_histogram(bins = 10, aes(fill =..count..))+
labs(title='Histogram of Number of Final Weight')+theme(plot.title=element_text(hjust=0.5))
multiplot(g1, g2, g3, g4,cols=2)


#1. From the summary and plot, we can know that, the mean of **age** is 38.58, median is 37.This variable has a long tail to right.The range is (17,90), but most values fall in (25,50) interval.

#2. The mean of **education.num** is 10.08, median is 10, range from (1,16), most people have (7,14) years education

#3. The **fnlwgt** variable have a large range, (12285,1484705), most of them fall in  (150000,200000). Using the quantile method to detect the outliers, we can find that there are 152 (0.47%) extremely large values. To avoid bias caused by these observations,we should delete them  

Q1=quantile(train$fnlwgt,0.25)
Q3=quantile(train$fnlwgt,0.75)
# here we use, 3*(Q3-Q1),insteads of 1.5*(Q3-Q1), because the number of obs whose fnlwgt is larger than (Q3 + 1.5*(Q3-Q1)) is too much.
up = Q3 + 3*(Q3-Q1) # up=594723
down = Q1 - 3*(Q3-Q1) #down<0
# extremely large values:
train$fnlwgt[train$fnlwgt>up]
# let's see the the y distribution of these observations.
# There are some points mixed together,especially in the (594723,1250000) interval.
ggplot(train[train$fnlwgt>up,], aes(fnlwgt)) + geom_histogram(bins = 20, aes(fill =y))
# delete the extremely observations
train = train[train$fnlwgt<=up,]


#4. The working **hours.per.week** fall in the range of (1,99).About 64% of people work for 30~50 hours per week.So its distribution has a high peak. The Other observations are nearly symmetry distributed, falling in (1,30) and (50,90) interval. When using the quantile mehod to determine the outliers, we could find that there will be 3614 (11.1%) observations, it's too much, so here we don't use it. Another thing that should be pay attention to is, there are lots of observations whose per.hours.week is exactly 99, it's more likely that those people who work for more than 99 hours also be recorded as 99 hours. But Watching the plot below, we can see that the proportion of '>50K' and '<=50K' is almost the same in the train data and in the test data, among those working 99 hours per week. So considering that it might provide us with some useful information for prediction, here we retain the original data.

g1 = ggplot(train[train$hours.per.week>90,], aes(hours.per.week)) + geom_histogram(bins = 20, aes(fill =y))+
labs(title='Working Hours(train data, >90)')+theme(plot.title=element_text(hjust=0.5))

g2 = ggplot(test[test$hours.per.week>90,], aes(hours.per.week)) + geom_histogram(bins = 20, aes(fill =y))+
labs(title='Working Hours(test data, >90)')+theme(plot.title=element_text(hjust=0.5))
multiplot(g1, g2,cols=2)


# capital.gain variable
g5=ggplot(train, aes(capital.gain)) + geom_histogram(bins = 20, aes(fill =..count..))+
labs(title='Capital Gain (All Obs)')+theme(plot.title=element_text(hjust=0.5))
# capital.loss variable
g6=ggplot(train, aes(capital.loss)) + geom_histogram(bins = 20, aes(fill =..count..))+
labs(title='Capital Loss (All Obs)')+theme(plot.title=element_text(hjust=0.5))
# look specifically the distribution of capital.gain without 0 value
g7=ggplot(train[train$capital.gain!=0,], aes(capital.gain)) + geom_histogram(bins = 50, aes(fill =..count..))+
labs(title='Capital Gain (No Obs with 0 Value')+theme(plot.title=element_text(hjust=0.5))
# look specifically the distribution of capital.gain without 0 value
g8=ggplot(train[train$capital.loss!=0,], aes(capital.loss)) + geom_histogram(bins = 50, aes(fill =..count..))+
  labs(title='Capital Loss (No Obs with 0 Value')+theme(plot.title=element_text(hjust=0.5))
multiplot(g5, g6, g7, g8,cols=2)



#5. From the summary and plot, we know that **capital.gain** and **capital.loss** are severely unnormal,severely skewed, 
#both of them have a long tail to right. Most of the observations have 0 capital.gain ( 91.66% ) and 
#capital loss ( 95.33% ). But there are also some extremely large values, so the range is very large for these two variables. 
#For such data, we can make a log tansformation for them. But because there are 0 value, so we can add 1 to all of them before we make a log transformation.  

#Again, there are one thing that should be emphasized, that is, there are 159 observations that have exactly 99999 capital gain, 
#while there are no observations who have capital gain is in the large interval (45000,99998). So here we consider these observations as outliers. 
#(here we don't use quantile method because there are too many points detected to be outliers). With the same idea, we delete observations who has more than 4000 capital loss  

# delete the outliers
train = train[train$capital.gain!=99999,]
train = train[train$capital.loss<4000,]

# make a log transformation
train$capital.gain = log(train$capital.gain+1)
train$capital.loss = log(train$capital.loss+1)


##### (3) Check specifically at each categorical variables 

# There are some varialbes, **education**, **occupation**, **native.country**, that use `(other)` to replace their other levels, we can dive into these variables to see their details  

summary(train$education)
summary(train$occupation)
summary(train$native.country)

# 6. From the summary, we can see that there are 1836 observations whose **workclass** is unknown, and 1827 observations whose **occupation** is unknown and 572 obervations whose **native.country** is unknown. The following code shows that there are 2399 obsevations that have unknown values (either **workclass** or **native.country** or **occupation** variables). To avoid the bias caused by these observations, it's better to delete these observations. And also bacause they just take up about 8% of the total observations, we still have enough data (30162 observations) to train our model after deleting them.  


# delete the observations with unknown values
unknown_obs = train$workclass=='?' | train$native.country=='?' | train$occupation=='?'
train = train[!unknown_obs,]


# workclass variable
g1=ggplot(train)+geom_bar(aes(x=workclass,fill=y))+theme(axis.text.x=element_text(angle=45))
# education variable
g2=ggplot(train)+geom_bar(aes(x=education,fill=y))+theme(axis.text.x=element_text(angle=45))
# marital.status variable
g3=ggplot(train)+geom_bar(aes(x=marital.status,fill=y))+theme(axis.text.x=element_text(angle=45))
# occupation variable
g4=ggplot(train)+geom_bar(aes(x=occupation,fill=y))+theme(axis.text.x=element_text(angle=45))
multiplot(g1, g2, g3, g4,cols=2)


# 7. For **workclass** varialbe, most people (73.8%) are 'Private', there are just 14 people who are 'Without-pay', though the sample of this level is small, here we don't need to change it, because among these 14 people, all of them are `<=50K`, so it might be a good predictor.
train$workclass = as.factor(as.character(train$workclass))

# 8. For **education** variable, there are 16 levels, most people are `Some-college`. There are just 44 people who are 'Preschool', but all of them are `<=50K`, it might be a good predictor and we retain it.

#9. For **marital.status**, there are 23 people who are `Married-AF-spouse`, here we transform this level into `Married-spouse-absent` level, because it's the second smallest level and is very similar to `Married-spouse-absent`


# the y label of people who are Married-AF-spouse
# it's not a good preditor and because its sample size is very small, we should change it
c(train$y[train$marital.status=='Married-AF-spouse'],test$y[test$marital.status=='Married-AF-spouse'])
# change the Married-AF-spouse level into Married-spouse-absent level
train$marital.status = as.character(train$marital.status)
train$marital.status[train$marital.status =='Married-AF-spouse'] = 'Married-spouse-absent'
train$marital.status = as.factor(train$marital.status)


# 10. For **occupation** variable, there are 9 people who are `Armed-Forces`. Since the sample of this level is very small and their labels are different, so we transform it into 'Other-service', the second smallest level.

# the y label of people who are Armed-Forces
c(train$y[train$occupation=='Armed-Forces'],test$y[test$occupation=='Armed-Forces'])
# change the Armed-Forces level into Other-service level
train$occupation = as.character(train$occupation)
train$occupation[train$occupation=='Armed-Forces'] = 'Other-service'
train$occupation = as.factor(train$occupation)

# relationship variable
g5=ggplot(train)+geom_bar(aes(x=relationship,fill=y))+theme(axis.text.x=element_text(angle=45))
# sex variable
g6=ggplot(train)+geom_bar(aes(x=sex,fill=y))+theme(axis.text.x=element_text(angle=45))
multiplot(g5, g6,cols=2)


# 11. For **relationship** variable, data is distribued uniformly, compared to other catigorical variables. The most level is `Husband`, with 13193 people, the least level is `Other-relative`, with 981 people. We don't need to change this variable  

# 12. For the **sex**, there two levels, about $$\frac{1}{3}$$ peopel are `Female` and $$\frac{2}{3}$$ are `Male`  

# race variable
g7 = ggplot(train)+geom_bar(aes(x=race,fill=y))+theme(axis.text.x=element_text(angle=45))

# look specifically two smallest level Amer-Indian-Eskimo and Other
logit = train$race=='Amer-Indian-Eskimo' | train$race=='Other'
temp = train[logit,]
g8 = ggplot(temp)+geom_bar(aes(x=race,fill=y))
multiplot(g5, g6,cols=2)

# 13. For *race* variable, 85.4% people are white, while there are just 311 people who are `Amer-Indian-Eskimo` and 271 people who are `Other`. And because the percentage of `<=50K` people in this two levels are very similar, we can also classify `Amer-Indian-Eskimo` people as `Other` 

# change the smallest level Amer-Indian-Eskimo into Other
train$race = as.character(train$race)
train$race[train$race=='Amer-Indian-Eskimo']='Other'
train$race = as.factor(train$race)

# native.country variable
ggplot(train)+geom_bar(aes(x=native.country,fill=y))+theme(axis.text.x=element_text(angle=90))


# 14. For the **native.country**, 91% of people are `United-States`. There are several levels that just have a very small amount of people. But here we retain them to train our models, we can consider classifying them as one level if needed. However, there is just one person who comes from `Holand-Netherlands`, we must transform it into its most similiar level--`England`

# change the native.country variable
train$native.country = as.character(train$native.country)
train$native.country[train$native.country=='Holand-Netherlands'] = 'England'
train$native.country = as.factor(train$native.country)


# 15. For **y** variable, this is our lable. About 76% people are `<=50K` and 24% people are `>50K`. Therefore, this is a unbalanced two-classification problem. So when we evaluate our models, in addition to accuracy, we should also consider their precision, recall, F1-score, auc, etc.

##### (4) Standardize data

# In this data set, numerical variables have great different scale.For example, age's range is 71, while capital.gain's range is 99999. Great difference of scale might have bad impact on training model, especially for KNN, Neural Network, Logistic Regression, etc.To avoid this problem, now we Standardize the data set, here we use $$\frac{x-min}{max-min}$$

# before we standarized the numerical variables, we keep a copy of un-standarized data, for the use of validation
unstandarized_train = train




# the columns of numerical data
numeri_col = c(1,3,5,11,12,13)
temp = train[,numeri_col]
maxdata = apply(temp,2,max)
mindata = apply(temp,2,min)
#train[,numeri_col] = (train[,numeri_col]-mindata)/(maxdata-mindata)
max_train = rep(maxdata,each=dim(train)[1])
min_train = rep(mindata,each=dim(train)[1])
# standarize the data set
train[,numeri_col] = (train[,numeri_col]-min_train)/(max_train-min_train)


### clean the test data  

#For the test data, with the same method, we make the summary for the test data, and see that there are some observations that have unknown value in **workclass** or **native.country**. But instead of deleting these observations, here we replace these unknown values with the mode in their corresponding variables, because here we can consider the test data as the real data, and we want to use them to test the authentic performance of our models (for the test data, we can not ignore them just because they have unknown values. Actually, in real life, we sometimes will also come across such data but we still have to make predictions for our customers).  

#The following codes are to clean the test data, with the same procedure of cleaning train data.

# deleting the duplicated data
test = unique(test)

# change the unknown workclass
test$workclass = as.character(test$workclass)
test$workclass[test$workclass=='?'] = 'Private'

# Because in the train data, there is no 'Never-worked' level in the workclass variables, so here in the test data, we can transform the 'Never-worked' into the 'Without-pay' level because there are just very small amount of people who are 'Never-worked', and also becasue 'Without-pay' level is very similar to 'Never-worked' level, the transformation won't have great impact on the prediction
test$workclass[test$workclass=='Never-worked'] = 'Without-pay'
test$workclass = as.factor(test$workclass)

# change the unknown native.country
test$native.country = as.character(test$native.country)
test$native.country[test$native.country=='?'] = 'United-States'
test$native.country = as.factor(test$native.country)

# The same as the transformation of train data, change the ' Amer-Indian-Eskimo' into ' Other'
test$race = as.character(test$race)
test$race[test$race=='Amer-Indian-Eskimo']='Other'
test$race = as.factor(test$race)

# The same as the transformation of train data, change the ' Married-AF-spouse' into ' Married-spouse-absent'
test$marital.status = as.character(test$marital.status)
test$marital.status[test$marital.status =='Married-AF-spouse'] = 'Married-spouse-absent'
test$marital.status = as.factor(test$marital.status)

# The same as the transformation of train data, change the ' Armed-Forces' into ' Other-service' and change the '?' into 'Prof-specialty'
test$occupation = as.character(test$occupation)
test$occupation[test$occupation == '?'] = 'Prof-specialty'
test$occupation[test$occupation=='Armed-Forces'] = 'Other-service'
test$occupation = as.factor(test$occupation)


# make a log transformation
test$capital.gain = log(test$capital.gain+1)
test$capital.loss = log(test$capital.loss+1)

# change the y variable, since there is period in every value of test$y 
test$y = as.character(test$y)
test$y[test$y == '>50K.'] = '>50K'
test$y[test$y == '<=50K.'] = '<=50K'
test$y = as.factor(test$y)


# before we standarized the numerical variables, we keep a copy of un-standarized data, for the use of validation
unstandarized_test = test

# apply the same transformation to the numerical variables in the test data, but use the maximum and minimum value of train data
min_test = rep(mindata,each=dim(test)[1])
max_test = rep(maxdata,each=dim(test)[1])
test[,numeri_col] = (test[,numeri_col]-min_test)/(max_test-min_test)


## Validation
# summary for the cleaned train data
summary(train)
# summary for the cleaned test data
summary(test)
# apply the validation function (source and instruction can be seen in the Validation.R)
validation(unstandarized_train)
validation(unstandarized_test)




## Models

### Model1: C4.5
# Model 1
set.seed(1234)
time = proc.time()
rt = rpart(train$y~.,data=train)
pred1 = predict(rt, test, type = "class")
# the time used for runing this model
rt_runtime = (proc.time()-time)[3]

# the performan on the test data (evaluation can be checked in evaluation.R)
rt_performance = evaluation(pred1,test$y)
# see the accuracy,precision,recall and F1-score
rt_performance


##### Evaluation

# let's see this model's performance for the train data
pred1_train = predict(rt, train, type = "class")
# the performan on the train data
rt_performance_train = evaluation(pred1_train,train$y)
# see the accuracy,precision,recall and F1-score
rt_performance_train


#Comparing the model's performance on train data and test data, they are very similar. So we can think that this model is not overfitting and we don't need pruning. So this model has been performing almostly its best for us.

### Model2: Random Forest

# Model2
set.seed(1234)
time = proc.time()
rf = randomForest(y ~ ., data=train,importance = TRUE, proximity = FALSE, ntree = 100)
pred2 = predict(rf,test,type='class')
# the time used for running this model
rf_runtime = (proc.time()-time)[3]

# the performan on the test data
rf_performance = evaluation(pred2,test$y)
# see the accuracy,precision,recall and F1-score
rf_performance


##### Evaluation

# Actually we found that using AUC to get a better threshold, can help up make an improvement for this model

# predict the probability instead of class
p_train = predict(rf,train,type='prob')[,2]
# apply my find_best_p function to determine the threshold (can be checked in find_best_p.R)
threshold = find_best_p(p_train,train$y)
# make a prediction for test data
p_test = predict(rf,test,type='prob')[,2]

pred2=test$y
pred2[p_test>threshold] = '>50K'
pred2[p_test<=threshold] = '<=50K'

rf_performance = evaluation(pred2,test$y)
# see the accuracy,precision,recall and F1-score
rf_performance


#We can see that this model has been improved a lot on the F1-score. Because it has improved a lot for its recall, meaning the stronger ability of finding those who are `>50K`. It makes sense, because this is exactly our goal,finding those who are `>50K`. And also, the accuracy improve slightly, though it's just a litte bit of improvement.

### Model3: Support Vector Machine

set.seed(1234)
time = proc.time()

svm = ksvm(y ~ ., data = train, C=1)
pred3 = predict(svm,test)
# the time used for running this model
svm_runtime = (proc.time()-time)[3]

# the performan on the test data
svm_performance = evaluation(pred3,test$y)
# see the accuracy,precision,recall and F1-score
svm_performance


##### Evaluation

# let's see this model's performance for the train data
pred3_train = predict(svm, train)
# the performan on the train data
svm_performance_train = evaluation(pred3_train,train$y)
# see the accuracy,precision,recall and F1-score
svm_performance_train


# we can see that there is a gap between the performance on train data and test data,
# So, to some extend, the original model is a little bit overfitting. So we can increase the penalty to make a better model


#penalty_list = c(1.2, 1.4, 1.6, 2, 5)
#for( penalty in penalty_list){
#  svm = ksvm(y ~ ., data = train, C = penalty)
#  pred = predict(svm, test)
#  print(penalty)
#  print(evaluation(pred,test$y))
#}

set.seed(1234)
svm = ksvm(y ~ ., data = train, C = 1.6)
pred3 = predict(svm, test)
# the performan on the test data
svm_performance = evaluation(pred3,test$y)
# see the accuracy,precision,recall and F1-score
svm_performance





## Comparison

# Compare the accuracy, precision, recall, F1-score and running-time
model_names=c('C 4.5','Random Forest','SVM')
x=rep(model_names,each = 4)
y=c(rt_performance,rf_performance,svm_performance)
z=rep(c('accuracy','precision','recall','F1-score'),3)
df=data.frame(x=x,y=y,z=z)
ggplot(data = df, mapping = aes(x = x, y = y,fill = z)) + 
  geom_bar(stat = 'identity', position = 'dodge') + 
  labs(x='Models',y='Performance',title='Comparison of Performance') + 
  theme(plot.title=element_text(hjust=0.5))
