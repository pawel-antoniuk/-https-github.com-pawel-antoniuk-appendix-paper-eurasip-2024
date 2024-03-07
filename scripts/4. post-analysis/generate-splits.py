import dill
import numpy as np
import pandas as pd
import glob

results = dill.load((open('../train/final_result/358597ce82_196_final_5_all.pkl', 'rb')))
pd.DataFrame({f'split{i}': r.recordings_dev for i, r in enumerate(results)})\
    .to_csv("recordings-192-dev.csv", index=False)
pd.DataFrame({f'split{i}': r.recordings_test for i, r in enumerate(results)})\
    .to_csv("recordings-192-test.csv", index=False)
