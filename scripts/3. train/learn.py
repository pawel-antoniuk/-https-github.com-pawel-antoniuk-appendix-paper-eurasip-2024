# %%

import itertools
import pprint
import time
import inspect
import sys
import hashlib
import dill
import os
import glob
import re

import lightgbm as lgb
import numpy as np
import pandas as pd
from dotmap import DotMap
from sklearn import metrics
from sklearn.model_selection import GroupKFold
from sklearn.model_selection import train_test_split

# %% Load datasets and create splits

df = pd.read_csv('../extract/features.csv')
# rescale from [0, 45] (from ensemble center) to [0, 90] (absolute width)
df['EnsembleAcutalWidth'] = df['EnsembleAcutalWidth'] * 2
recordings_all = np.unique(df['SongNames'])
features_filter = ('^(Features_.*_ILD_Raw_.*)'
                  '|(Features_.*_ITD_Raw_.*)'
                  '|(Features_.*_IC_Raw_.*)$')
features_num = (64 + 64 + 64) * 2
dev_size = 128
test_size = 64
final_iterations = 20

# %% Save and Load Progress Routines


def __get_source_short():
    src = inspect.getsource(sys.modules[__name__])
    short = hashlib.sha1(src.encode('utf-8')).hexdigest()[:10]
    return short, src


def save_progress(data, label=None, state_dir='state'):
    global ordinal_num
    if 'ordinal_num' in globals():
        ordinal_num = ordinal_num + 1
    else:
        ordinal_num = 0

    dump_dir = f'{state_dir}/dump'
    src_dir = f'{state_dir}/src'

    short, src = __get_source_short()

    if label is None:
        dump_filename = f'{dump_dir}/{short}_{ordinal_num:03}.pkl'
        src_filename = f'{src_dir}/{short}.py'
    else:
        dump_filename = f'{dump_dir}/{short}_{ordinal_num:03}_{label}.pkl'
        src_filename = f'{src_dir}/{short}_{label}.py'

    if not os.path.exists(dump_dir):
        os.makedirs(dump_dir)

    if not os.path.exists(src_dir):
        os.makedirs(src_dir)

    dill.dump(data, open(dump_filename, 'wb'))
    open(src_filename, 'w').write(src)

    return dump_filename, src_filename


def load_progress(match_source=True, label=None, state_dir='state'):
    short, _ = __get_source_short()

    dump_dir = f'{state_dir}/dump'
    filename_pattern = f'{dump_dir}/'

    if match_source:
        filename_pattern += f'{short}_'
    else:
        filename_pattern += f'*_'

    if label is None:
        filename_pattern += f'*.pkl'
    else:
        filename_pattern += f'*_{label}.pkl'

    filenames = glob.glob(filename_pattern)

    if len(filenames) == 0:
        return None, None

    kv = [(int(re.split('_|\.', x)[1]), x) for x in filenames]
    kv.sort(key=lambda x: x[0])
    last_state_filename = kv[-1][1]

    return dill.load(open(last_state_filename, 'rb')), last_state_filename

# %% Grid Search Routine


def grid_search(objective,
                space: dict,
                strategy='min',
                global_params=None,
                verbose=False):

    results = DotMap()
    results.all = []
    results.best = DotMap()
    results.iteration = 0

    loaded_results, results_filename = load_progress()

    if loaded_results:
        results = loaded_results
        print(f'[Grid Search] results loaded from {results_filename}')

    if strategy == 'min':
        results.best.score = float('inf')
    elif strategy == 'max':
        results.best.score = -float('inf')
    else:
        raise ValueError('Incorrect loss value')

    param_product = list(itertools.product(*space.values()))
    it_begin = results.iteration
    n_param_product = np.product([len(x) for x in space.values()])

    for i in range(it_begin, n_param_product):
        results.iteration = i
        param_values = param_product[results.iteration]

        if verbose:
            print(
                f'[Grid Search] iteration: {results.iteration + 1} / {n_param_product}')

        st = time.time()
        result = DotMap()
        result.params = dict(zip(space.keys(), param_values))

        if global_params is None:
            result.score = objective(result.params)
        else:
            result.score = objective(result.params, global_params)

        result.elapsed = time.time() - st
        results.all.append(result)

        if strategy == 'min' and result.score < results.best.score\
                or strategy == 'max' and result.score > results.best.score:
            results.best.score = result.score
            results.best.params = result.params
            result.is_new_best_score = True
        else:
            result.is_new_best_score = False

        results.iteration += 1
        save_progress(results)

        if verbose:
            print(f'[Grid Search] result: {pprint.pformat(result)}')

    return results

# %% Train model


def train_model(model_params, fit_params, X, y):
    lgb_params = {**model_params, **fit_params}
    lgb_params_without_estimators = {
        k: v for k, v in lgb_params.items() if k != 'n_estimators'}
    dataset = lgb.Dataset(X, y)
    model = lgb.train(lgb_params_without_estimators, dataset,
                      num_boost_round=model_params['n_estimators'])
    return model

# %% Objective Function


def objective(model_params, params):
    kfold = GroupKFold(n_splits=params.n_splits)
    splits = kfold.split(params.X_dev, params.y_dev, groups=params.groups)
    scores = np.empty(params.n_splits)

    for i, (train_i, test_i) in enumerate(splits):
        X_train = params.X_dev.iloc[train_i]
        y_train = params.y_dev.iloc[train_i]
        X_test = params.X_dev.iloc[test_i]
        y_test = params.y_dev.iloc[test_i]

        model = train_model(model_params, fit_params, X_train, y_train)
        pred_test = model.predict(X_test)
        scores[i] = metrics.mean_absolute_error(y_test, pred_test)

    return np.mean(scores)

# %% Train and evaluate models


models = []
for i in range(final_iterations):
    models.append(DotMap())

    print(f'[Final] iteration: {i}')

    # Multi-track songs splitting
    models[i].recordings_dev, models[i].recordings_test = train_test_split(
        recordings_all, test_size=test_size, random_state=i)

    # Binaural Datasets
    models[i].df_dev = df[df.SongNames.isin(models[i].recordings_dev)]
    models[i].df_test = df[df.SongNames.isin(models[i].recordings_test)]

    # Input features
    models[i].X_dev = models[i].df_dev.filter(regex=features_filter)
    models[i].X_test = models[i].df_test.filter(regex=features_filter)

    # Output
    models[i].y_dev = models[i].df_dev['EnsembleAcutalWidth']
    models[i].y_test = models[i].df_test['EnsembleAcutalWidth']

    # Check number of samples
    assert dev_size * 30 * 4 \
        == models[i].X_dev.shape[0] \
        == models[i].y_dev.shape[0]
    assert test_size * 30 * 4 \
        == models[i].X_test.shape[0] \
        == models[i].y_test.shape[0]

    # Check number of features
    assert features_num == models[i].X_dev.shape[1]
    assert features_num == models[i].X_test.shape[1]
    assert 1 == len(models[i].y_dev.shape)
    assert 1 == len(models[i].y_test.shape)

    # Fit params
    fit_params = {
        'device_type': 'gpu',
        'objective': 'regression',
        'metric': 'mean_absolute_error',
        'random_state': i,
        'verbose': -1,
    }

    # Tunne the hyperparams
    search_space = {
        'num_leaves': [1000],
        'max_depth': [9],
        'learning_rate': [0.01],
        'n_estimators': [500],

        # 'num_leaves': [500, 1000, 1500],
        # 'max_depth': [6, 9, 12],
        # 'learning_rate': [0.001, 0.01, 0.2],
        # 'n_estimators': [500]
    }

    params = DotMap()
    params.X_dev = models[i].X_dev
    params.y_dev = models[i].y_dev
    params.fit_params = fit_params
    params.groups = models[i].df_dev.SongNames
    params.n_splits = 10

    # results = grid_search(objective, search_space,
    #                       strategy='min',
    #                       global_params=params,
    #                       verbose=True)

    # train the final model using the best params obtained from grid search
    # final_model_params = results.best.params
    final_model_params = {
        'num_leaves': 1000,
        'max_depth': 9,
        'learning_rate': 0.01,
        'n_estimators': 500
    }
    print(f'[Final] model params: {final_model_params}')
    print(f'[Final] fit params: {fit_params}')

    models[i].final_model = train_model(
        final_model_params, fit_params, models[i].X_dev, models[i].y_dev)

    # test final model on the test dataset
    models[i].final_pred = models[i].final_model.predict(models[i].X_test)
    models[i].final_score = metrics.mean_absolute_error(
        models[i].y_test, models[i].final_pred)

    print(f'[Final] score: {models[i].final_score}')

    # save final result
    save_progress(models[i], label=f'final{i}')

# calcuate average stats
all_scores = [model.final_score for model in models]
avg_score = np.mean(all_scores)
std_score = np.std(all_scores)
print(f'avg: {avg_score}, std: {std_score}, count: {len(all_scores)}')

save_progress(models, label=f'final_all')
