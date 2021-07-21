# import a bunch of necessary modules/functions -------------->
import numpy as np
import sys
import re
import h5py
from scipy.io import loadmat

# option to import from github folder
sys.path.insert(0, '/vf/users/guptaa12/conda/envs/suite2p/lib/python3.7/site-packages')
print('SUITE2P FOLDER BEING USED IS: ' + sys.path[0])
import suite2p
from suite2p import run_s2p, default_ops

# load in the .mat file saved within the same directory as this script ------------>
try:
        variables_from_matlab = loadmat('matlab_variables.mat')
except:
        variables_from_matlab = h5py.File('matlab_variables.mat', 'r+')

# get experiment paths
data_paths = variables_from_matlab['h5_location_array']
print('THE EXERPIMENT DIRECTORIES ARE: ' + str(data_paths))

# get num of experiments
num_of_experiments = data_paths.shape[1]
print('THE # OF EXPERIMENTS IS: ' + str(num_of_experiments))

# get the num of tiffs for each experiment 
num_of_tiffs_array = variables_from_matlab['num_of_tiffs_array']

# get the relevant recording/experiment parameters
nplanes = variables_from_matlab['nplanes_array']
nchannels = variables_from_matlab['nchannels_array']
tau = variables_from_matlab['tau_array']
framerate = variables_from_matlab['fs_array']


db = {
      'h5py': [], # a single h5 file path

      'h5py_key': 'data',

      'look_one_level_down': True, # whether to look in ALL subfolders when searching for tiffs 

      'subfolders': [], # choose subfolders of 'data_path' to look in (optional)

      'fast_disk': 'C:/BIN', # string which specifies where the binary file will be stored (should be an SSD)
	
      'tiff_list':  [],
      
      'data_path': []
 }

ops = default_ops()
ops['do_registration'] = 0

for x in range (0, num_of_experiments):
	data_path = str(data_paths[0,x])
	pattern = "'(.*?)'"
	data_path = re.search(pattern, data_path).group(1)
	db['h5_path'] = data_path
	db['h5py'] = data_path
	db['input_format'] = 'h5'
	db['nplanes'] = nplanes[0,x]
	db['nchannels'] = nchannels[0,x]	
	db['tau'] = tau[0,x]
	db['fs'] = framerate[0,x]
	db['sparse_mode'] = True

	print('THE DB PARAMETERS ARE: ')
	print(db)
	print('THE OPS WITH THE EXPERIMENT INPUTS IS: ')
	print(ops)
	opsEnd = run_s2p(ops=ops, db=db)
	print(' >>>>>>>>>> | Moving Onto Next Experiment | <<<<<<<<<<')
