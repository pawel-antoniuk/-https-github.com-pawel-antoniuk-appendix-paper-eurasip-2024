import dill
import pandas as pd
from unidecode import unidecode
from scipy.stats import pearsonr
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

plt.plot(df.final_pred, df.EnsembleAcutalWidth, 'bo', alpha=0.05, markersize=2)
plt.xlabel('Predicted')
plt.ylabel('Actual')
plt.grid(axis='both', linestyle='--', alpha=0.7)
plt.tight_layout()
plt.show()
