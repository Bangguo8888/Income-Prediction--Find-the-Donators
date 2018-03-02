evaluation = function(pred_y,true_y){
  # This function is to calculate the precision, recall,f1_score and accuracy
  # Since our task is to determine whether a person makes over 50K a year 
  # so here >50K is positive, and <=50K is negative
  
  confuse = table(pred_y,true_y)
  TP = confuse[4]
  TN = confuse[1]
  FP = confuse[2]
  FN = confuse[3]
  
  accuracy = (TP+TN)/sum(confuse)
  precision = TP/(TP+FP)
  recall = TP/(TP+FN)
  F1_score = 2/(1/precision+1/recall)
  
  result = c(accuracy,precision,recall,F1_score)
  
  return(result)
  

}
