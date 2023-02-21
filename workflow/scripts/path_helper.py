import os

###### root path ######
def get_abs_root_path(): 
    abs_root_path = "/" + "/".join(os.path.abspath(config["root"]).split("/")[2:])
    return(abs_root_path)


###### results path ######
def get_res_path():
    abs_root_path = "/" + "/".join(os.path.abspath(config["root"]).split("/")[2:])
    res_path= abs_root_path + "/" + config["resdir"]
    return(res_path)