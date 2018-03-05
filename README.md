# Income Prediction -- Find the Donators
Actually, this is a binary classification problem. Models are developed to classify people who earn >50K per year and those who earn <=50K per year, in order to find the potential donators. 

The data is in rawData.Rdata file, or it can be downloaded from [here](https://archive.ics.uci.edu/ml/datasets/Adult)

**Procedures:**
* Data description 
*	Data cleaning and validation
*	Outlier and missing value detection
* Feature transformation and feature selection
*	Model fitting : **C4.5**, **Random Forest**, **SVM**
* Classification prediction
* Results comparisons and visualization

**R files:**
* main.R        ---  the main file
* validation.R  ---  for data validation
* evaluation.R  ---  for modle evaluation
* find_best_p.R ---  for optimazation
* multiplot.R   ---  for visualization

Demo: https://bangguo8888.github.io/Income_Prediction_Find_the_Donators/IncomePredictionFindTheDonators.html
