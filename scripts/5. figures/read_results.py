import dill
import numpy as np
import pandas as pd
import glob
from unidecode import unidecode

def sanitize_filename(filename):
    return unidecode(filename)

# results = dill.load((open('../train/final_result/6a551904b1_020_final_all.pkl', 'rb')))
results = dill.load((open('../train/final_result/358597ce82_196_final_5_all.pkl', 'rb')))

# avg test mae
mae = np.mean([r.final_score for r in results])
std = np.std([r.final_score for r in results])

mae2 = np.mean([np.mean(np.abs(r.df_test['EnsembleAcutalWidth'] - r.final_pred)) for r in results])
std2 = np.std([np.mean(np.abs(r.df_test['EnsembleAcutalWidth'] - r.final_pred)) for r in results])

assert(mae == mae2)
assert(std == std2)

# actual vs predicted train
actual = results[1].y_dev * 2 # <- rescale from +-90 domain to 0-180
predicted = results[1].final_model.predict(results[1].X_dev) * 2
pd.DataFrame({'actual': list(actual), 'predicted': predicted}).to_csv('actual_vs_predicted_train.csv')

# actual vs predicted test
actual = results[1].df_test['EnsembleAcutalWidth']
predicted = results[1].final_pred
pd.DataFrame({'actual': list(actual), 'predicted': predicted}).to_csv('actual_vs_predicted.csv')

# moving MAE
moving_mae = []
moving_mae_vals = []
for start in np.linspace(0, 90, 200):
    stop = start + 1
    frame_actual = actual[(actual >= start) & (actual < stop)]
    frame_pred = predicted[(actual >= start) & (actual < stop)]
    frame_mae = np.mean(np.abs(frame_actual - frame_pred))
    moving_mae.append(frame_mae)
    moving_mae_vals.append((start + stop) / 2)

pd.DataFrame({
    'val': moving_mae_vals,
    'mae': moving_mae,
}).to_csv('mae_moving.csv')

# error distribution
errors = actual - predicted
mae_vals = []
mae_dist = []
for start in range(-90, 91):
    stop = start + 1
    frame_err = errors[(errors >= start) & (errors < stop)]
    frame_count = len(frame_err)
    mae_vals.append((start + stop) / 2)
    mae_dist.append(frame_count)

pd.DataFrame({
    'val': mae_vals,
    'err': mae_dist,
}).to_csv('mae_error_distribution.csv')

# mae distribution
pred_dist = []
pred_dist_vals = []
for start in range(90):
    stop = start + 1
    frame_err = predicted[(predicted >= start) & (predicted < stop)]
    frame_count = len(frame_err)
    pred_dist.append(frame_count)
    pred_dist_vals.append((start + stop) / 2)

pd.DataFrame({
    'vals': pred_dist_vals,
    'mae': pred_dist,
}).to_csv('mae_pred_distribution.csv')

# mae per song
err_per_song = {}
for result in results:
    r_actual = list(result.df_test['EnsembleAcutalWidth'])
    r_pred = result.final_pred
    r_rec = list(result.df_test['SongNames'])

    for i in range(len(r_actual)):
        err = np.abs(r_actual[i] - r_pred[i])
        err_per_song.setdefault(sanitize_filename(r_rec[i]), []).append(err)

recordings = glob.glob('../recordings-all/*')
recording_count = {r.split('/')[-1]: len(glob.glob(f'{r}/*.wav')) for r in recordings}

mae_per_song = {song: np.mean(errs) for song, errs in err_per_song.items()}
std_per_song = {song: np.std(errs) for song, errs in err_per_song.items()}
count_per_song = {song: recording_count[song] for song, _ in err_per_song.items()}

pd.DataFrame({
    'song': mae_per_song.keys(), 
    'count': count_per_song.values(),
    'mae': mae_per_song.values(), 
    'std': std_per_song.values()
}).to_csv('mae_per_song.csv')

# mae vs width vs location
locs = [float(s.split('_')[5].replace('azoffset', '')) for r in results for s in r.df_test['AudioFilenames']]
widths = [w for r in results for w in r.df_test['EnsembleAcutalWidth']]
errors = [e for r in results for e in np.abs(list(r.df_test['EnsembleAcutalWidth'] - r.final_pred))]

pd.DataFrame({
    'location': locs, 
    'width': widths,
    'error': errors
}).to_csv('mae_loc_width.csv')

# # mae per nHRTF
# nhrtf_maes = []
# nhrtf_stds = []
# nhtfs = []

# for r_nhrtf_dir in glob.glob('results/nhrtf/*'):
#     nhrtf = int(r_nhrtf_dir.split('/')[-1])
#     nhrtf_results = []

#     for file in glob.glob(f'{r_nhrtf_dir}/*.pkl'):
#         it = int(file.split('.')[0].split('_')[-2])
#         f_nhrtf = int(file.split('.')[0].split('_')[-1])
#         assert nhrtf == f_nhrtf

#         print(f'loading {file} (nhrtf {f_nhrtf}, it {it})')

#         with open(file, 'rb') as f:
#             result = dill.load(f)
#             rescale_result(result)
#             nhrtf_results.append(result)

#     nhtfs.append(nhrtf)
#     nhrtf_maes.append(np.mean([r.final_score for r in nhrtf_results]))
#     nhrtf_stds.append(np.std([r.final_score for r in nhrtf_results]))

# pd.DataFrame({
#     'nhrtf': nhtfs, 
#     'mae': nhrtf_maes,
#     'std': nhrtf_stds
# }).to_csv('mae_per_nhrtf.csv')
