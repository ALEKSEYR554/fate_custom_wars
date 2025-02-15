extends Node

#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
# https://github.com/PacktPublishing/The-Essential-Guide-to-Creating-Multiplayer-Games-with-Godot-4.0
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

@onready var main_menu = $"."

@onready var connect_scene = $Connect_scene
@onready var host_scene = $Host_scene
@onready var start_screen = $start_screen
@onready var back_button = $Back_button
const GAME_FIELD = preload("res://game_field.tscn")

func _ready():
	#DisplayServer.window_set_title("gogod_debug="+str(OS.get_process_id()))
	print(str("\n\n\n EDITOR=",OS.has_feature("editor")," \n\n"))
	
	var folders_in_user=DirAccess.open("user://").get_directories()
	if !folders_in_user.has("servants") and !OS.has_feature("editor"):
		self.visible=false
		var vb=VBoxContainer.new()
		var butt=Button.new()
		butt.text="open"
		butt.pressed.connect(_on_button_pressed)
		var ll=Label.new()
		ll.text="ERROR\n ADD 'servants' folder in\n"+OS.get_user_data_dir()
		
		ll.add_theme_font_size_override("font_size", 20)
		ll.add_theme_color_override("font_color",Color.RED)
		#ll.autowrap_mode=TextServer.AUTOWRAP_WORD
		vb.add_child(ll)
		vb.add_child(butt)
		#get_tree().root.add_child(vb)
		get_parent().add_child.call_deferred(vb)
		vb.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	pass

func _on_host_button_up():
	start_screen.visible=false
	host_scene.visible=true
	back_button.visible=true
	DisplayServer.window_set_title("gogod_debug= HOST")
	pass # Replace with function body.

func _on_connect_button_up():
	var file_content = FileAccess.get_file_as_bytes("res://jopa.png")
	#print(file_content)
	var file2 = FileAccess.open("user://save_game.png", FileAccess.WRITE)
	DisplayServer.window_set_title("gogod_debug= USER")
	file2.store_buffer(file_content)
	start_screen.visible=false
	connect_scene.visible=true
	back_button.visible=true
	pass # Replace with function body.

@rpc
func set_avatar():
	pass

func _on_back_button_button_up():
	connect_scene.visible=false
	host_scene.visible=false
	back_button.visible=false
	start_screen.visible=true
	pass # Replace with function body.


func _on_button_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://"))
	pass # Replace with function body.
	
func game_initiate():
	print("FUCK")
	var game_field_instanse=GAME_FIELD.instantiate()
	get_tree().root.add_child(game_field_instanse)
	pass
