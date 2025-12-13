extends Node2D

@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	await teto()
	return
	var memory_before = OS.get_static_memory_usage()
	
	var path="res://servants/rama/sprite_stage_1.png"
	var image = Image.new()
	
	image.load(path)
	#image.compress(Image.COMPRESS_S3TC) 
	#var img = load()
	var texture = ImageTexture.new()
	texture.set_image(image)
	texture_rect.texture=texture
	print("typeof=",typeof(image))
	
	var memory_used = OS.get_static_memory_usage() - memory_before
	print("memory_used after sprite loaded = ",memory_used*1.0/1024/1024," mb")
	print("memory_used rn = ",OS.get_static_memory_usage()*1.0/1024/1024," mb")
	pass

func teto():
	for i in range(999):
		await get_tree().create_timer(0.01).timeout
		print("number=",i)
	
