validation = function(data){
  
  # Based on the instruction from the 'data.name' file , we can implement the following data validation
  
  #####################
  
  # age: continuous.
  # workclass: Private, Self-emp-not-inc, Self-emp-inc, Federal-gov, Local-gov, State-gov, Without-pay, Never-worked.
  # fnlwgt: continuous.
  # education: Bachelors, Some-college, 11th, HS-grad, Prof-school, Assoc-acdm, Assoc-voc, 9th, 7th-8th, 12th, Masters, 1st-4th, 10th, Doctorate, 5th-6th, Preschool.
  # education-num: continuous.
  # marital-status: Married-civ-spouse, Divorced, Never-married, Separated, Widowed, Married-spouse-absent, Married-AF-spouse.
  # occupation: Tech-support, Craft-repair, Other-service, Sales, Exec-managerial, Prof-specialty, Handlers-cleaners, Machine-op-inspct, Adm-clerical, Farming-fishing, Transport-moving, Priv-house-serv, Protective-serv, Armed-Forces.
  # relationship: Wife, Own-child, Husband, Not-in-family, Other-relative, Unmarried.
  # race: White, Asian-Pac-Islander, Amer-Indian-Eskimo, Other, Black.
  # sex: Female, Male.
  # capital-gain: continuous.
  # capital-loss: continuous.
  # hours-per-week: continuous.
  # native-country: United-States, Cambodia, England, Puerto-Rico, Canada, Germany, Outlying-US(Guam-USVI-etc), India, Japan, Greece, South, China, Cuba, Iran, Honduras, Philippines, Italy, Poland, Jamaica, Vietnam, Mexico, Portugal, Ireland, France, Dominican-Republic, Laos, Ecuador, Taiwan, Haiti, Columbia, Hungary, Guatemala, Nicaragua, Scotland, Thailand, Yugoslavia, El-Salvador, Trinadad&Tobago, Peru, Hong, Holand-Netherlands.
  
  #####################
  # flag
  valid = TRUE
  
  # check whether or not all the values in 'age' variable are in the range of (17,90)
  age = data$age<17 | data$age>90
  if(any(age)){
    valid = FALSE
    print("Pay attention to the 'age' variable in the following observations:")
    print(data[age,])
  }
  
  
  # check whether or not all the values in 'workclass' variable are expected
  workclass_validList = strsplit('Private, Self-emp-not-inc, Self-emp-inc, Federal-gov, Local-gov, State-gov, Without-pay, Never-worked', ', ')[[1]]
  workclass = !data$workclass %in% workclass_validList
  if(any(workclass)){
    valid = FALSE
    print("Pay attention to the 'workclass' variable in the following observations:")
    print(data[workclass,])
  }
  
  
  # check whether or not all the values in 'fnlwgt' variable are in the range of (13000,1500000)
  fnlwgt = data$fnlwgt<13000 | data$fnlwgt>1500000
  if(any(fnlwgt)){
    valid = FALSE
    print("Pay attention to the 'fnlwgt' variable in the following observations:")
    print(data[fnlwgt,])
  }
  
  # check whether or not all the values in 'education' variable are expected
  education_validList = strsplit('Bachelors, Some-college, 11th, HS-grad, Prof-school, Assoc-acdm, Assoc-voc, 9th, 7th-8th, 12th, Masters, 1st-4th, 10th, Doctorate, 5th-6th, Preschool',', ')[[1]]
  education = !data$education %in% education_validList
  if(any(education)){
    valid = FALSE
    print("Pay attention to the 'education' variable in the following observations:")
    print(data[education,])
  }
  
  # check whether or not all the values in 'education.num' variable are in the range of (1,16)
  eduNum = data$education.num<1 | data$education.num>16
  if(any(eduNum)){
    valid = FALSE
    print("Pay attention to the 'education.num' variable in the following observations:")
    print(data[eduNum,])
  }
  
  
  # check whether or not all the values in 'marital.status' variable are expected
  marital.status_validList = strsplit('Married-civ-spouse, Divorced, Never-married, Separated, Widowed, Married-spouse-absent, Married-AF-spouse',', ')[[1]]
  marital.status = !data$marital.status %in% marital.status_validList
  if(any(marital.status)){
    valid = FALSE
    print("Pay attention to the 'marital.status' variable in the following observations:")
    print(data[marital.status,])
  }
  
  # check whether or not all the values in 'occupation' variable are expected
  occupation_validList = strsplit('Tech-support, Craft-repair, Other-service, Sales, Exec-managerial, Prof-specialty, Handlers-cleaners, Machine-op-inspct, Adm-clerical, Farming-fishing, Transport-moving, Priv-house-serv, Protective-serv, Armed-Forces',', ')[[1]]
  occupation = !data$occupation %in% occupation_validList
  if(any(occupation)){
    valid = FALSE
    print("Pay attention to the 'occupation' variable in the following observations:")
    print(data[occupation,])
  }
  
  
  # check whether or not all the values in 'relationship' variable are expected
  relationship_validList = strsplit('Wife, Own-child, Husband, Not-in-family, Other-relative, Unmarried',', ')[[1]]
  relationship = !data$relationship %in% relationship_validList
  if(any(relationship)){
    valid = FALSE
    print("Pay attention to the 'relationship' variable in the following observations:")
    print(data[relationship,])
  }
  
  # check whether or not all the values in 'race' variable are expected
  race_validList = strsplit('White, Asian-Pac-Islander, Amer-Indian-Eskimo, Other, Black',', ')[[1]]
  race = !data$race %in% race_validList  
  if(any(race)){
    valid = FALSE
    print("Pay attention to the 'race' variable in the following observations:")
    print(data[race,])
  }
  
  
  # check whether or not all the values in 'sex' variable are expected
  sex_validList = c('Female','Male')
  sex = !data$sex %in% sex_validList 
  if(any(sex)){
    valid = FALSE
    print("Pay attention to the 'sex' variable in the following observations:")
    print(data[sex,])
  }
  
  
  # check whether or not all the values in 'capital.gain' variable are in the range of (0,100000)
  capital.gain = data$capital.gain<0 | data$capital.gain>log(100000)
  if(any(capital.gain)){
    valid = FALSE
    print("Pay attention to the 'capital.gain' variable in the following observations:")
    print(data[capital.gain,])
  }
  
  # check whether or not all the values in 'capital.loss' variable are in the range of (0,5000)
  capital.loss = data$capital.loss<0 | data$capital.loss>log(5000)
  if(any(capital.loss)){
    valid = FALSE
    print("Pay attention to the 'capital.loss' variable in the following observations:")
    print(data[capital.loss,])
  }
  
  
  # check whether or not all the values in 'hours.per.week' variable are in the range of (0,99)
  hours.per.week = data$hours.per.week < 1 | data$hours.per.week > 99
  if(any(hours.per.week)){
    valid = FALSE
    print("Pay attention to the 'hours.per.week' variable in the following observations:")
    print(data[hours.per.week,])
  }
  
  # check whether or not all the values in 'native.country' variable are expected
  native.country_validList = strsplit('United-States, Cambodia, England, Puerto-Rico, Canada, Germany, Outlying-US(Guam-USVI-etc), India, Japan, Greece, South, China, Cuba, Iran, Honduras, Philippines, Italy, Poland, Jamaica, Vietnam, Mexico, Portugal, Ireland, France, Dominican-Republic, Laos, Ecuador, Taiwan, Haiti, Columbia, Hungary, Guatemala, Nicaragua, Scotland, Thailand, Yugoslavia, El-Salvador, Trinadad&Tobago, Peru, Hong, Holand-Netherlands',', ')[[1]]
  native.country = !data$native.country %in% native.country_validList
  if(any(native.country)){
    valid = FALSE
    print("Pay attention to the 'native.country' variable in the following observations:")
    print(data[native.country,])
  }
  
  # check whether or not all the values in 'y' variable are expected
  y = !data$y %in% c('<=50K','>50K')
  if(any(y)){
    valid = FALSE
    print("Pay attention to the 'y' variable in the following observations:")
    print(data[y,])
  }
  
  
  
  if(valid){
    print('The data set is valid !')
  }
  
  
  
  
  
}