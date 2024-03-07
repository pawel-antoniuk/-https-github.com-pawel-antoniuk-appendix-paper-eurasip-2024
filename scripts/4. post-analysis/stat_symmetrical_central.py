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


base_path = "../train/final-models-symmetrical-central/"
model_paths = {
    "ild": "0c948e7fe5_196_symmetrical_central_ild_all.pkl",
    "itd": "d6283c7b65_196_symmetrical_central_itd_all.pkl",
    "ic": "3e85180050_196_symmetrical_central_ic_all.pkl"
}
epsilon = 0.05
window = 1

stats = {}

for model_name, model_path in model_paths.items():
    full_path = os.path.join(base_path, model_path)
    models = dill.load(open(full_path, "rb"))

    stats[model_name] = DotMap()
    stats[model_name].final_score = np.mean([m.final_score for m in models])
    stats[model_name].final_score_std = np.std([m.final_score for m in models])

    for width in range(91):
        actualWidths = [m.df_test.EnsembleAcutalWidth[
            (m.df_test.EnsembleAcutalWidth > width - window / 2)
            & (m.df_test.EnsembleAcutalWidth < width + window / 2)]
            for m in models]
        predictedWidths = [m.final_pred[
            (m.df_test.EnsembleAcutalWidth > width - window / 2)
            & (m.df_test.EnsembleAcutalWidth < width + window / 2)]
            for m in models]

        assert np.all(
            [m.y_test == m.df_test.EnsembleAcutalWidth for m in models])
        assert np.all([len(actualWidths[i]) == len(predictedWidths[i])
                      for i in range(len(actualWidths))])

        maes_per_model = [np.mean(
            np.abs(actualWidths[i] - predictedWidths[i])) for i in range(len(actualWidths))]

        mae = np.mean(maes_per_model)
        stats[model_name].mae_per_width[width] = mae

output = pd.DataFrame({
    'Width': stats['ild'].mae_per_width.keys(),
    'Mean_ILD': stats['ild'].mae_per_width.values(),
    'Mean_ITD': stats['itd'].mae_per_width.values(),
    'Mean_IC': stats['ic'].mae_per_width.values(),
})
output.to_csv('stats_symmetrical_central.csv')

