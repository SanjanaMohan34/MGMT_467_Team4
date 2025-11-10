MD Summary
Lily Larson

**Insights**
I learned that the airline plays a significant role in possible departure delay of a flight. While it is difficult to quanity or interpret the relationship exactly, the feature was more important in a linear regression model to predict departure deplay than the flight's distance, destination, origin, or day of the week. Distance was negatively attributed in both flights used in ML.EXPLAIN_PREDICT, so I can infer that flights which will cover a longer distance are typically less delayed than flights over shorter distances. 

**Limitations**
The linear regression model's overall performance was very poor, with an R^2 value of 0.047. The logistic regression model trained to predict whether or not a flight was diverted performed much better, with an accuracy of 0.98. However, precision, recall, and f1-scores were all very low, indicating a imbalanced dataset. The model appears accurate but, quite possibly, simply predicits that all flights will not be divereted. 

**Threshold**
I would deploy a threshold of 0.2, because this only slightly decreases the area under the curve while increaesing accuracy, precision, recall, and the f1 score. Furthermore, I am prioritizing recall over precision and accuracy and would rather have a model that correctly predictes all true positives even if additional false positives are also generated. 
