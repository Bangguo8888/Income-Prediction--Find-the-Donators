find_best_p = function(p, y){
  # this function can help me to find the best threshold
  # p is the probability of positive class
  # y is the true label
  library(ROCR)
  label = rep(0, length(y))
  label[y == '>50K'] = 1
  
  # apply the function from ROCR package
  pred = prediction(p, label)
  f.perf = performance(pred, "f")
  # draw the picture
  plot(f.perf)
  
  # find the best threshold that can maximize the f1-score
  max_f1 = max(f.perf@y.values[[1]][-1])
  p_threshold = f.perf@x.values[[1]][f.perf@y.values[[1]][-1] == max_f1][[1]][1]
  
  return(p_threshold)
  
}
