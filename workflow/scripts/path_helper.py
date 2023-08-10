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