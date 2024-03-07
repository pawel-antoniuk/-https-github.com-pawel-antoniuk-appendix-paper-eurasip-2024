import dill
import pandas as pd
from unidecode import unidecode
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import numpy as np

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


fig, ax = plt.subplots(figsize=(6, 4))
ax.plot(df.Features_Mean_skewness_1, df.EnsembleAcutalWidth - df.final_pred, 'bo', alpha=0.01, markersize=1)
ax.grid(axis='both', linestyle='--', alpha=0.7)
ax.yaxis.set_major_formatter(FormatStrFormatter(r'$%.0f\degree$'))
ax.set_xlabel('Skewness')
ax.set_ylabel(r'Error')

plt.tight_layout()
plt.show()
