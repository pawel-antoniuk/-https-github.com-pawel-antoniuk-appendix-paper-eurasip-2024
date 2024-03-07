import dill
import numpy as np
import pandas as pd
import glob
from scipy.stats import pearsonr
from sklearn.metrics import r2_score

results = dill.load((open('../train/final_result/358597ce82_196_final_5_all.pkl', 'rb')))

r_coeff = []
r_p = []
R2_scores = []

for r in results:
    pred = r.final_pred
    actual = r.y_test
    correlation_coefficient, p_value = pearsonr(actual, pred)
    R2_score = r2_score(actual, pred)
    r_coeff.append(correlation_coefficient)
    r_p.append(p_value)
    R2_scores.append(R2_score)

print(f'r={np.mean(r_coeff)} (SD={np.std(r_coeff)})')
print(f'R2={np.mean(R2_scores)} (SD={np.std(R2_scores)})')
