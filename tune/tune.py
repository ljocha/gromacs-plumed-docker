#!/usr/bin/env python3

from ray import tune, train
from ray import init as ray_init
import numpy as np

ray_init()

def tune_func(config):
	return {'nsday':np.random.rand()}

tuner = tune.Tuner(
	tune.with_resources(
		tune_func,
		resources={'cpu':1} # XXX
  ),
  tune_config = tune.TuneConfig(
		num_samples=5
  ),
)

results = tuner.fit()
print(results.get_best_result(metric='nsday',mode='min'))
