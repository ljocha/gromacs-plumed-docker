#!/usr/bin/env python3

from ray import tune, train, data
from ray import init as ray_init
import numpy as np
import os
import re

# 100 ps
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

space = {
	'ntmpi' : tune.choice([1,2,4]),
  'ntomp' : tune.choice([1,2]),
}

def bonz(x):
	print(x)
	return { 'cpu': x.ntmpi * x.ntomp }

tuner = tune.Tuner(
	tune.with_resources(
		tune_func,
#		resources=bonz
		resources=lambda x: { 'cpu': x['ntmpi'] * x['ntomp'], 'gpu': 0.5 }
  ),
	param_space=space,
  tune_config = tune.TuneConfig(
		num_samples=4
  ),
)

results = tuner.fit()
print(results.get_best_result(metric='nsday',mode='min'))
