extends Node2D
@onready var file_dialog = $"../FileDialog"
const DRAG_OBJECT = preload("res://сцены/drag_object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("any_peer","call_local","reliable")
func add_image(image_data):
	
	var data = image_data
	var img = Image.new()
	#FaceImg is just what I called the dictionary in the resource file
	img = Image.create_from_data(data["width"], data["height"], data["mipmaps"], data["format"], data["data"])

	var texture = ImageTexture.new()
	texture.set_image(img)
	
	var drag_img=DRAG_OBJECT.instantiate()
	drag_img.get_child(0).size=Vector2(data["width"],data["height"])
	drag_img.get_child(0).texture=texture
	
	#var node2=Node2D.new()
	#var image_to_add=TextureRect.new()
	#image_to_add.name="TextureRect"
	#image_to_add.texture=texture
	
	#var resize_area=Area2D.new()
	
	#node2.add_child(image_to_add)
	
	#node2.set_script(load("res://скрипты/drag_script.gd"))
	add_child(drag_img)
	pass

func _on_file_dialog_file_selected(path):
	var image = Image.new()
	image.load(path)
	var imgTexture = ImageTexture.new()#idk man
	imgTexture.set_image(image)
	
	var imageData = image.data
	imageData["format"] = image.get_format()
	
	rpc("add_image",imageData)
	pass # Replace with function body.


func _on_add_image_button_pressed():
	file_dialog.visible=true
	pass # Replace with function body.
