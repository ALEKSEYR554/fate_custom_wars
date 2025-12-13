extends Node2D


func _ready()->void:
	print("aaaa=",get_child(0).text)

func _process(delta: float) -> void:
	print("aaaa=",get_child(0).text)
