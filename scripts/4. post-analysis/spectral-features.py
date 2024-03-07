import dill
import numpy as np
import pandas as pd
from unidecode import unidecode
import matplotlib.pyplot as plt

final_result_path = '../train/final_result/6a551904b1_020_final_all.pkl'

results = dill.load(open(final_result_path, 'rb'))
spectral_features = pd.read_csv('../extract/features_spectral.csv')

df = pd.concat([pd.DataFrame({
    'final_pred': r.final_pred,
    'EnsembleAcutalWidth': r.df_test.EnsembleAcutalWidth,
    'AudioFilenames': r.df_test.AudioFilenames.apply(unidecode),
    'y_test': r.y_test,
    'err': abs(r.final_pred - r.y_test)
}) for r in results], ignore_index=True)

df = df.merge(spectral_features, on='AudioFilenames', how='left', suffixes=('', '_f'))
assert (all(df.EnsembleAcutalWidth == df.EnsembleAcutalWidth_f * 2))

features_names = spectral_features.drop(columns=['AudioFilenames', 'SongNames', 'EnsembleAcutalWidth']).columns

df = df.sample(1000)

features = [
    ('Centroid', df.Features_Mean_centroid_1),
    ('Spread', df.Features_Mean_spread_1),
    ('Brightness', df.Features_Mean_brightness_1),
    ('High-freq Cont.', df.Features_Mean_hfc_1),
    ('Crest', df.Features_Mean_crest_1),
    ('Decrease', df.Features_Mean_decrease_1),
    ('Entropy', df.Features_Mean_entropy_1),
    ('Flatness', df.Features_Mean_flatness_1),
    ('Irregularity', df.Features_Mean_irregularity_1),
    ('Kurtosis', df.Features_Mean_kurtosis_1),
    ('Skewness', df.Features_Mean_skewness_1),
    ('Roll-off', df.Features_Mean_rolloff_1),
    ('Flux', df.Features_Mean_flux_1),
    ('Variation', df.Features_Mean_variation_1),
]

fig, axes = plt.subplots(5, 3, figsize=(12, 15))

for i, (feature_name, feature_data) in enumerate(features):
    row = i // 3
    col = i % 3
    ax = axes[row, col]
    err = abs(df.EnsembleAcutalWidth - df.final_pred)

    z = np.polyfit(feature_data, err, 1)
    p = np.poly1d(z)

    ax.plot(feature_data, err, 'bo', alpha=0.1, markersize=1)
    ax.plot(feature_data, p(feature_data))
    ax.set_xlabel(feature_name)
    ax.grid(axis='both', linestyle='--', alpha=0.7)

    if col == 0:
        ax.set_ylabel(r'Error')

axes[-1, -1].axis('off')
plt.tight_layout()
plt.show()
