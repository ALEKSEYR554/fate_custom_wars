@tool
extends EditorScript


func _run():
	print(str(get_all_servants_subfolders_name()))
	
func get_all_servants_subfolders_name(path:String=""):
	
	var dir = ResourceLoader.load("res://servants/gray/gray.gd")
	
	return "./servants/gray/gray.gd".get_base_dir()

	
	
	var output=[]
	for folder in dir.get_directories():
		output.append(path+folder)
		output.append_array(get_all_servants_subfolders_name(str(path+folder+"/")))
	return output

