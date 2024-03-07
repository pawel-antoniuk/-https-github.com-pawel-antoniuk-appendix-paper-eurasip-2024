import dill
import numpy as np
import pandas as pd
import glob

results = dill.load((open('../train/final_result/358597ce82_196_final_5_all.pkl', 'rb')))

# avg test mae
mae = np.mean([r.final_score for r in results])
std = np.std([r.final_score for r in results])
