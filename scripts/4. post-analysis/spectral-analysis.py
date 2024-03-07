import dill
import pandas as pd
from unidecode import unidecode
from scipy.stats import pearsonr
import matplotlib.pyplot as plt

final_result_path = '../train/final_result/6a551904b1_020_final_all.pkl'

result = dill.load(open(final_result_path, 'rb'))
spectral_features = pd.read_csv('../extract/features_spectral.csv')

df = pd.DataFrame()

for i in range(len(result)):
    ri_df = pd.DataFrame({
        'final_pred': result[i].final_pred,
        'EnsembleAcutalWidth': result[i].df_test.EnsembleAcutalWidth,
        'AudioFilenames': result[i].df_test.AudioFilenames.apply(unidecode),
        'y_test': result[i].y_test,
        'err': abs(result[i].final_pred - result[i].y_test)
    })
    df = pd.concat([df, ri_df])

df = df.merge(spectral_features, on='AudioFilenames', how='left', suffixes=('', '_f'))
assert (all(df.EnsembleAcutalWidth == df.EnsembleAcutalWidth_f * 2))

features_names = spectral_features.drop(columns=['AudioFilenames', 'SongNames', 'EnsembleAcutalWidth']).columns

correlations = {}

for feature_name in features_names:
    fname = feature_name.replace("_1", "").replace("Features_", "")
    correlations[fname] = pearsonr(df[feature_name], df.err).statistic

plt.bar(correlations.keys(), correlations.values())
# plt.title('r-pearson')
plt.xlabel('Spectral Feature')
plt.ylabel(r'Pearson Correlation Coefficient $r$')
plt.grid(axis='both', linestyle='--', alpha=0.7)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.show()
