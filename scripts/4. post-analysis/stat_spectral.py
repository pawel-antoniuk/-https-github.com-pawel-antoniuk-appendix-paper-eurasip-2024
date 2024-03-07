import dill
import pandas as pd
from unidecode import unidecode
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import numpy as np
from scipy.stats import pearsonr
from sklearn.metrics import r2_score

final_result_path = '../train/final_result/358597ce82_196_final_5_all.pkl'

results = dill.load(open(final_result_path, 'rb'))
spectral_features = pd.read_csv('../extract/features_spectral.csv')
feature_names = ['Features_Mean_centroid_1', 'Features_Std_centroid_1',
       'Features_Mean_crest_1', 'Features_Std_crest_1',
       'Features_Mean_spread_1', 'Features_Std_spread_1',
       'Features_Mean_entropy_1', 'Features_Std_entropy_1',
       'Features_Mean_brightness_1', 'Features_Std_brightness_1',
       'Features_Mean_hfc_1', 'Features_Std_hfc_1', 'Features_Mean_decrease_1',
       'Features_Std_decrease_1', 'Features_Mean_flatness_1',
       'Features_Std_flatness_1', 'Features_Mean_flux_1',
       'Features_Std_flux_1', 'Features_Mean_kurtosis_1',
       'Features_Std_kurtosis_1', 'Features_Mean_skewness_1',
       'Features_Std_skewness_1', 'Features_Mean_irregularity_1',
       'Features_Std_irregularity_1', 'Features_Mean_rolloff_1',
       'Features_Std_rolloff_1', 'Features_Mean_variation_1',
       'Features_Std_variation_1']
dfs = []

for r in results:
    df = pd.DataFrame({
        'final_pred': r.final_pred,
        'EnsembleAcutalWidth': r.df_test.EnsembleAcutalWidth,
        'AudioFilenames': r.df_test.AudioFilenames.apply(unidecode),
        'y_test': r.y_test,
        'err': r.final_pred - r.y_test
    })
    df = df.merge(spectral_features, on='AudioFilenames', how='left', suffixes=('', '_f'))
    assert (all(df.EnsembleAcutalWidth == df.EnsembleAcutalWidth_f * 2))
    dfs.append(df)

results = {}
for df in dfs:
    results_per_feature = {}
    for feature in feature_names:
        result = pearsonr(df.err, df[feature])
        results.setdefault(feature, []).append(result.correlation)

summary = [(feature, np.mean(values), np.std(values)) for feature, values in results.items()]
top = sorted(summary, key=lambda x: x[1])

# print(f"mean r pearson: {np.mean(r)} (std: {np.std(r)})")