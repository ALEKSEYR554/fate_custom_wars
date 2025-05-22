extends Control
@onready var resolution_choice:OptionButton = $VBoxContainer/HBoxContainer/resolution_choice

const resolutions=[
"1280x720",
"1280x1024",
"1366x768",
"1440x900",
"1600x900",
"1680x1050",
"1920x1080",
"1920x1200",
"2560x1080",
"2560x1440"
]
# Called when the node enters the scene tree for the first time.
func _ready():
	for item in resolutions:
		resolution_choice.add_item(item)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_apply_button_pressed():
	var cut_selected_id=resolution_choice.get_selected_id()
	var resolution_choosen=resolution_choice.get_item_text(cut_selected_id)
	var resolulion_split=resolution_choosen.split("x")
	var base_window_size=Vector2(int(resolulion_split[0]),int(resolulion_split[1]))

	get_viewport().content_scale_size = base_window_size
	#update_container.call_deferred()
	pass # Replace with function body.


func _on_full_screen_toggle_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.
