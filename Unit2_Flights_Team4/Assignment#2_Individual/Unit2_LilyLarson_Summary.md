MD Summary

Lily Larson

**Insights**

I learned that the origin airport and reporting airline play a significant role in influencing the possible arrival delay of a flight. While it is difficult to quantify or interpret the relationship exactly, the feature was significantly more important in a linear regression model to predict arrival delay than the flight's distance, destination, origin, or day of the week.

**Limitations**

The linear regression model's overall performance was very poor, with an R^2 value of 0.047. The logistic regression model trained to predict whether or not a flight was diverted performed much better, with an accuracy of 0.98. However, precision, recall, and f1-scores were all very low, indicating an imbalanced dataset. The model appears accurate but, quite possibly, simply predicts that all flights will not be diverted. This was confirmed in the confusion matrix. Only 187 of the 10,058 cases resulted in a diverted flight (1.86%).

**Threshold**

I would deploy a threshold of 0.2, because this only slightly decreases the area under the curve while increasing accuracy, precision, recall, and the f1 score. Furthermore, I am prioritizing recall over precision and accuracy and would rather have a model that correctly predicts all true positives even if additional false positives are also generated. 
