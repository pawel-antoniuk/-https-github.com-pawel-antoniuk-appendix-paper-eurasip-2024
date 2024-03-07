import dill
import numpy as np
import pandas as pd
import glob
from dotmap import DotMap
import os

pd.options.mode.copy_on_write = False

def flatten(matrix):
    flat_list = []
    for row in matrix:
        flat_list.extend(row)
    return flat_list


base_path = "../train/final-models-symmetrical-central/"
model_paths = {
    "ILD": "0c948e7fe5_196_symmetrical_central_ild_all.pkl",
    "ITD": "d6283c7b65_196_symmetrical_central_itd_all.pkl",
    "IC": "3e85180050_196_symmetrical_central_ic_all.pkl"
}
epsilon = 0.05
window = 5
target_song = 'MuchTooMuch'


models = dill.load(
    open('../train/final_result/358597ce82_196_final_5_all.pkl', "rb"))
model = models[0]
stats = DotMap()
widths = range(91)

output = pd.DataFrame({'Width': widths})

for feature in ['ILD', 'ITD', 'IC']:
    for band in range(1, 65):
        output[f'{feature}_{band}'] = np.zeros(len(widths))
        means = []
        for width in widths:
            df_filtered = model.df_test[
                (model.df_test.EnsembleAcutalWidth > width - window / 2)
                & (model.df_test.EnsembleAcutalWidth < width + window / 2)
                & (model.df_test.SongNames == target_song)]
            mean_feature_value = np.mean(
                df_filtered[f'Features_Mean_{feature}_Raw_{band}'])
            means.append(mean_feature_value)
        output[f'{feature}_{band}'] = means


output.to_csv(
    'data/stats_symmetrical_central_const_song_TheRoadAhead_feature_value.csv')
