import os

###### root path ######
def get_abs_root_path(): 
    abs_root_path = os.path.abspath(config["root"])
    return(abs_root_path)


###### results path ######
def get_res_path():
	abs_root_path = os.path.abspath(config["root"])
	res_path= abs_root_path + "/" + config["resdir"]
	return(res_path)

def find_all_assemblies():
	"""
	Output all the asembled genomes in the results directories
	"""
	res_path = get_res_path()
	assemblies = []
	for root, _, files in os.walk(res_path):
		for file in files:
			if file.endswith(".fa.gz"):
				assemblies.append(os.path.join(root, file))
	return assemblies

def get_ref():
	ref_path = os.path.abspath(config["reference_genome"])
	return(ref_path)