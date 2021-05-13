# import a bunch of necessary modules/functions --------------> 
import numpy as np
import sys
import re
import h5py
from scipy.io import loadmat
# option to import from github folder
# sys.path.insert(0, 'C:/Users/carse/github/suite2p/')
from suite2p import run_s2p, default_ops

# load in the .mat file saved within the same directory as this script ------------>
try:
	variables_from_matlab = loadmat('matlab_variables.mat')
except:
	variables_from_matlab = h5py.File('matlab_variables.mat', 'r+')

print('the variables in the file are....', variables_from_matlab)

# get variable for the data path for each experiment  ------------>
data_paths = variables_from_matlab['path_to_raw_tiffs_array']

# get the number of experiments
num_of_experiments = variables_from_matlab['num_of_experiments']
num_of_experiments = num_of_experiments[0]
num_of_experiments = int(num_of_experiments)
print('the number of experiments is....', num_of_experiments)

# get the number of tiffs for each experiment
num_of_tiffs_array = variables_from_matlab['num_of_tiffs_array']

# get the actual file name and extensions 
extensions = variables_from_matlab['ext_of_raw_tiffs'] 
print(extensions)
file_names = variables_from_matlab['names_of_raw_tiffs']
print(file_names)

# set your options for running ------------>
ops = default_ops() # populates ops with the default options + the default has been changed itself under run_s2p
print(ops)

# only run on specified tiffs ------------>
db = {
      'h5py': [], # a single h5 file path

      'h5py_key': 'data',

      'look_one_level_down': False, # whether to look in ALL subfolders when searching for tiffs 
       
      'subfolders': [], # choose subfolders of 'data_path' to look in (optional)

      'fast_disk': 'C:/BIN', # string which specifies where the binary file will be stored (should be an SSD)

      'tiff_list': [] # list of tiffs in folder * data_path *!
    }

for x in range (0, num_of_experiments):
	db['data_path'] = data_paths[0,x]
	num_of_tifs = num_of_tiffs_array[0,x]
	ext_of_experiment = str(extensions[0,x])
	name = str(file_names[0,x])
	pattern = "'(.*?)'"
	name = re.search(pattern, name).group(1)
	if num_of_tifs > 1:
		if ext_of_experiment == "['.raw']":
	    		for i in range(1, num_of_tifs + 1):
                		db['tiff_list'].append(str(i) + '.tiff') 
	else:	
		if ext_of_experiment == "['.raw']":	
           		db['tiff_list'].append(str(i) + '.tiff')
		else:
                    	db['tiff_list'].append(name) 
	print(db['tiff_list'])
        
	#opsEnd = run_s2p(ops=ops, db=db)
	db['tiff_list'].clear()
	print('Moving Onto Next Experiment')

print('Finished With Registration!')
