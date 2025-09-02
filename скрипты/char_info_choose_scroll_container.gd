extends ScrollContainer

var char_info_selected:CharInfo

@onready var char_info_holder_h_box_container = $char_info_holder_HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_char_infos(char_info_array:Array):
	for child in char_info_holder_h_box_container.get_children():
		child.queue_free()
	print("choose char info cleared")
	char_info_selected=char_info_array[0]
	for char_info:CharInfo in char_info_array:
		var node=char_info.get_node()
		var char_name=node.name
		var texture=node.get_child(0).texture
		
		var char_info_vbox:VBoxContainer=VBoxContainer.new()
		char_info_vbox.modulate=Color(0.5, 0.5, 0.5)
		
		var char_info_name_label:Label = Label.new()
		char_info_name_label.text=char_name
		
		var char_info_TextureButton:TextureButton=TextureButton.new()
		char_info_TextureButton.texture_normal=texture
		char_info_TextureButton.ignore_texture_size=true
		char_info_TextureButton.stretch_mode=TextureButton.STRETCH_SCALE
		char_info_TextureButton.custom_minimum_size=Vector2(200,200)
		
		char_info_TextureButton.pressed.connect(char_pressed.bind(char_info.to_dictionary(),char_info_vbox))
		
		char_info_vbox.add_child(char_info_name_label)
		char_info_vbox.add_child(char_info_TextureButton)
		char_info_holder_h_box_container.add_child(char_info_vbox)
	#1 bc there is example node on index 0
	char_info_holder_h_box_container.get_child(1).modulate=Color(1, 1, 1)
	pass

func char_pressed(char_info_dic:Dictionary,char_info_vbox):
	var char_info = CharInfo.from_dictionary(char_info_dic)
	char_info_selected=char_info
	for child in char_info_holder_h_box_container.get_children():
		child.modulate=Color(0.5, 0.5, 0.5)
	char_info_vbox.modulate=Color(1, 1, 1)
	return

func get_char_info_selected()->CharInfo:
	return char_info_selected
