import dill
import numpy as np
import pandas as pd
import glob
from scipy.stats import ttest_rel

hrtfs_human = [1, 3, 5, 6, 7, 8, 9, 13, 14, 15, 16, 19, 20, 23, 24]
hrtfs_artificial = [2, 4, 10, 11, 12, 17, 18, 21, 22, 25, 26, 27, 28, 29, 30]

results_ha = dill.load((open('../train/state_ha/dump/8e9fc234f9_000_final_2_ha_all.pkl', 'rb')))
results_ah = dill.load((open('../train/state_ha/dump/b324404764_000_final_2_ah_all.pkl', 'rb')))

# check if there are no human hrtfs in development set in the artificial-human scenario
assert len(np.array([[h for h in hrtfs_human if f'hrtf{h}' in r.dev_hrtfs] for r in results_ah]).flatten()) == 0
# check if there are no artificial hrtfs in test set in the artificial-human scenario
assert len(np.array([[h for h in hrtfs_artificial if f'hrtf{h}' in r.test_hrtfs] for r in results_ah]).flatten()) == 0

# check if there are no artificial hrtfs in development set in the human-artificial scenario
assert len(np.array([[h for h in hrtfs_artificial if f'hrtf{h}' in r.dev_hrtfs] for r in results_ha]).flatten()) == 0
# check if there are no human hrtfs in test set in the human-artificial scenario
assert len(np.array([[h for h in hrtfs_human if f'hrtf{h}' in r.test_hrtfs] for r in results_ha]).flatten()) == 0

scores_ah = [r.final_score for r in results_ah]
scores_ha = [r.final_score for r in results_ha]

t_stat, p_value = ttest_rel(scores_ah, scores_ha)


