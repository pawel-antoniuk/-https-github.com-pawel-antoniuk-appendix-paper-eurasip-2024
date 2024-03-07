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

dfg = df.groupby('SongNames')
mae_per_song = dfg['err'].mean()
skewness_per_song = dfg['Features_Mean_skewness_1'].mean()

final_df = pd.DataFrame({
    'mae': mae_per_song,
    'skewness': skewness_per_song,
})

final_df.to_csv('mae_per_skewness_and_song.csv')
