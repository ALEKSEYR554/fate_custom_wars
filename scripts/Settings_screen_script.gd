extends Control
@onready var resolution_choice:OptionButton = $VBoxContainer/HBoxContainer/resolution_choice
@onready var language_option_button:OptionButton = $VBoxContainer/HBoxContainer3/language_OptionButton
@onready var full_screen_toggle = $VBoxContainer/HBoxContainer2/full_screen_toggle

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

func _ready():
	for item in resolutions:
		resolution_choice.add_item(item)
		
	for language_name in TranslationServer.get_loaded_locales():
		language_option_button.add_item(language_name)
		print("adding language_name=",language_name)
	
	#Globals.language_code_selected=language_option_button.get_item_text(language_option_button.get_selected_id())
	TranslationServer.set_locale(
		language_option_button.get_item_text(
			language_option_button.get_selected_id()
			)
		)
	print("current locale=",TranslationServer.get_locale())

	#print(tr("WAITING_ENEMIE_ATTACK_RESPONCE"))
	#TranslationServer.set_locale("ru")
	#print(tr("WAITING_ENEMIE_ATTACK_RESPONCE"))
	pass # Replace with function body.

func _on_apply_button_pressed():
	var cut_selected_id=resolution_choice.get_selected_id()
	var resolution_choosen=resolution_choice.get_item_text(cut_selected_id)
	var resolulion_split=resolution_choosen.split("x")
	var base_window_size=Vector2(int(resolulion_split[0]),int(resolulion_split[1]))

	get_viewport().content_scale_size = base_window_size
	#update_container.call_deferred()
	pass # Replace with function body.


func _on_full_screen_toggle_toggled(toggled_on):
	if toggled_on==null:
		toggled_on=!full_screen_toggle.button_pressed
		full_screen_toggle.button_pressed=toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	pass # Replace with function body.


func _on_language_option_button_item_selected(index):
	TranslationServer.set_locale(language_option_button.get_item_text(language_option_button.get_selected_id()))
	pass # Replace with function body.
