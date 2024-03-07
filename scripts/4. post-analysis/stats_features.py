import os
import dill
import numpy as np
from scipy.stats import ttest_rel

base_result_path = '../train/state/dump'

filenames = {
    'IC': '8b1c5d5600_003_final_5_ic_all.pkl',
    'ILD': '02c4a92928_003_final_5_ild_all.pkl',
    'ITD': 'f8ffcce338_003_final_5_itd_all.pkl',
    'ITD_IC': 'f20ac09bff_003_final_5_itd_ic_all.pkl',
    'ILD_IC': '51a8b7b623_003_final_5_ild_ic_all.pkl',
    'ILD_ITD': '0ec7ba58b6_084_final_5_ild_itd_all.pkl',
    'ILD_ITD_IC': '358597ce82_196_final_5_all.pkl'
}

all_maes = {}
maes = {}
stds = {}

for feature, filename in filenames.items():
    path = os.path.join(base_result_path, filename)
    results = dill.load((open(path, 'rb')))
    maes[feature] = np.mean([r.final_score for r in results])
    stds[feature] = np.std([r.final_score for r in results])
    all_maes[feature] = [r.final_score for r in results]
    
print(maes)
print(stds)
print(all_maes)

stat, p_value = ttest_rel(all_maes['IC'], all_maes['ILD'])
print(f'IC vs ILD: p-value = {p_value}')

stat, p_value = ttest_rel(all_maes['ILD_ITD'], all_maes['ILD_ITD_IC'][0:3])
print(f'ILD+ITD vs ILD+ITD+IC: p-value = {p_value}')


