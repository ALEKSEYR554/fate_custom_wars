@tool
extends EditorScript


func _run():
	pass
	var nu=Node2D.new()
	nu.set_script("res://скрипты/globals.gd")
	
	print(nu.get_script().get_file().get_basename())
	
