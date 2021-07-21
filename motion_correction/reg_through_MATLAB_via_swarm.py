# import a bunch of necessary modules/functions -------------->
import numpy as np
import sys
import re
import h5py
from scipy.io import loadmat
import os

# option to import from github folder
sys.path.insert(0, '/vf/users/guptaa12/conda/envs/suite2p/lib/python3.7/site-packages')
print('SUITE2P FOLDER BEING USED IS: ' + sys.path[0])
import suite2p
from suite2p import run_s2p, default_ops

# load in the arguments from swarmscript
expdir = str(sys.argv[1])
tau = float(sys.argv[2])
fs = float(sys.argv[3])
nchannels = int(float(sys.argv[4]))
nplanes = int(float(sys.argv[5]))
path_to_raw_tiffs = str(sys.argv[6])
num_of_tiffs = int(float(sys.argv[8]))
name_of_raw_tiff = str(sys.argv[9])
ext_of_raw_tiff = str(sys.argv[10])

# set your options for running ------------>
ops = default_ops() # populates ops with the default options + the default has been changed itself under run_s2p
print('THE DEFAULT OPTIONS BEING USED ARE: ')
print(ops)

# only run on specified tiffs ------------>
db = {
      'h5py': [], # a single h5 file path

      'h5py_key': 'data',

      'look_one_level_down': True, # whether to look in ALL subfolders when searching for tiffs

      'subfolders': [], # choose subfolders of 'data_path' to look in (optional)

      'fast_disk': 'C:/BIN', # string which specifies where the binary file will be stored (should be an SSD)

      'tiff_list': [] # list of tiffs in folder * data_path *!
    }

db['data_path'] = path_to_raw_tiffs
if num_of_tiffs > 1:
	if ext_of_raw_tiff == '.raw':
		for i in range(1, num_of_tiffs + 1):
			db['tiff_list'].append(str(i) + '.tiff')
else:
	if ext_of_raw_tiff == '.raw':
		db['tiff_list'].append('1.tiff')
	else:
		db['tiff_list'].append(name_of_raw_tiff)

print('THE TIFF LIST AND DB PARAMETERS ARE: ')
print(db['tiff_list'])

ops['nplanes'] = nplanes
ops['nchannels'] = nchannels
ops['tau'] = tau
ops['fs'] = fs

print('THE OPS WITH THE EXPERIMENT INPUTS IS: ')
print(ops)
opsEnd = run_s2p(ops=ops, db=db)
