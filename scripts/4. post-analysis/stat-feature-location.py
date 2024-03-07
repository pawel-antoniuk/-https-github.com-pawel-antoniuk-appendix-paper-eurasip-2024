import dill
import numpy as np
import pandas as pd
import glob
from dotmap import DotMap
import os


def flatten(matrix):
    flat_list = []
    for row in matrix:
        flat_list.extend(row)
    return flat_list


base_path = "../train/final-models-feature-location"
model_paths = {
    "ild_itd_ic_center": "0ca950c124_196_final_feature_location_1_all.pkl",
    "ild_itd_ic_off-center": "15843fd19d_196_final_feature_location_2_off-center_all.pkl",
    "ild_itd_center": "b25512d7ef_189_final_feature_location_ild_itd_center_all.pkl",
    "ild_itd_off-center": "f3d381c1dd_189_final_feature_location_ild_itd_off-center_all.pkl",
    "ild_ic_center": "b25512d7ef_569_final_feature_location_ild_ic_center_all.pkl",
    "ild_ic_off-center": "f3d381c1dd_569_final_feature_location_ild_ic_off-center_all.pkl",
    "itd_ic_center": "b25512d7ef_379_final_feature_location_itd_ic_center_all.pkl",
    "itd_ic_off-center": "f3d381c1dd_379_final_feature_location_itd_ic_off-center_all.pkl",
    "ild_center": "d6439653cc_189_final_feature_location_ild_center_all.pkl",
    "ild_off-center": "ed3f9809f5_189_final_feature_location_ild_off-center_all.pkl",
    "itd_center": "d6439653cc_379_final_feature_location_itd_center_all.pkl",
    "itd_off-center": "ed3f9809f5_379_final_feature_location_itd_off-center_all.pkl",
    "ic_center": "471ee8e1f3_189_final_feature_location_ic_center_all.pkl",
    "ic_off-center": "ed3f9809f5_569_final_feature_location_ic_off-center_all.pkl",
}
epsilon = 0.05

stats = {}

for model_name, model_path in model_paths.items():
    full_path = os.path.join(base_path, model_path)
    models = dill.load(open(full_path, "rb"))

    center = model_name.split("_")[-1]
    if center == "center":
        is_center = True
    elif center == "off-center":
        is_center = False
    else:
        raise Exception("Not recognized center/off-center type")

    locations_all = flatten([m.df_test.Location for m in models])

    if is_center:
        assert 10 - epsilon <= max(locations_all) <= 10 + epsilon
        assert -10 - epsilon <= min(locations_all) <= -10 + epsilon
        assert 0 - epsilon <= min(np.abs(locations_all)) <= 0 + epsilon
    else:
        assert 45 - epsilon <= max(locations_all) <= 45 + epsilon
        assert -45 - epsilon <= min(locations_all) <= -45 + epsilon
        assert 35 - epsilon <= min(np.abs(locations_all)) <= 35 + epsilon

    stats[model_name] = DotMap()
    stats[model_name].final_score = np.mean([m.final_score for m in models])
    stats[model_name].final_score_std = np.std([m.final_score for m in models])

flat_stats = [['_'.join(k.split('_')[:-1]), k.split('_')[-1], s.final_score, s.final_score_std]
              for k, s in stats.items()]
pd.DataFrame(flat_stats, columns=['features', 'center', 'mae', 'std']) \
    .to_csv('stats-feature-location.csv')
