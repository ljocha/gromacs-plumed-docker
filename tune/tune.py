#!/usr/bin/env python3

from ray import tune, train, data
from ray import init as ray_init
import numpy as np
import os
import re

# tuning space, parameters to sweep

space = {
	'ntmpi' : tune.grid_search([1,2]),	# grid_search is exhaustive, replace with choice() for sampling
  'ntomp' : tune.grid_search([1,2,4]),
}

# how many tuning trials (i.e. different parameters configurations)
# no reason for more than size of a small tuning space, reasonable number for bigger ones
# (one trial takes up to few minutes)

# however, whole grid_search above counts for 1

ntrials=1


# part of GPU a single trial uses (1 is safe, sharing GPUs feasible for smaller simulations which don't saturate whole GPU)
gpu_fraction=.5

# usually a` 2 fs, i.e. 50k steps ~ 100 ns; good for small proteins (20 resudua)
nsteps=50000

ray_init()


def tune_func(config):
	if 'OMP_NUM_THREADS' in os.environ:
		del os.environ['OMP_NUM_THREADS']

	files = 'md.tpr npt.cpt npt.gro'.split()

	for f in files:
		ds = data.read_binary_files(f)
		r = ds.take(1)[0]
		with open(f,"wb") as w:
			w.write(r['bytes'])

	if os.system(f"gmx convert-tpr -s md.tpr -o md-new.tpr -nsteps {nsteps} && mv md-new.tpr md.tpr") & 0xf0:
		return None

	if os.system(f"mpirun -np {config['ntmpi']} gmx mdrun -pin on -ntomp {config['ntomp']} -deffnm md") & 0xf0:
		return None

	nsday = None
	with open('md.log') as l:
		for ll in l:
			if re.match('Performance:',ll):
				nsday = float(ll.split()[1])

	return {'nsday': nsday}


tuner = tune.Tuner(
	tune.with_resources(
		tune_func,
		resources=lambda x: { 'cpu': x['ntmpi'] * x['ntomp'], 'gpu': gpu_fraction }
  ),
	param_space=space,
  tune_config = tune.TuneConfig(
		num_samples=ntrials
  ),
)

results = tuner.fit()
print(results.get_best_result(metric='nsday',mode='max'))
