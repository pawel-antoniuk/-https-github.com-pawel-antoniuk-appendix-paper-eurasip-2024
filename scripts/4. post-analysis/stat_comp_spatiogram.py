import dill
import numpy as np
import pandas as pd
from scipy.stats import ttest_rel

results = dill.load((open('../train/final_result/358597ce82_196_final_5_all.pkl', 'rb')))

tree_maes = [r.final_score for r in results]
# from ws-dep-comp-16-Feb-2024 09:38:51.mat
spatiogram_maes = [15.8988, 15.9916, 16.2569, 16.5922, 17.0601, 15.7612, 17.6604] 

result = ttest_rel(tree_maes, spatiogram_maes)

print(f'p-value: {result.pvalue}')

