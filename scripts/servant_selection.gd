extends Control

var current_character_index = 0
var current_ascension_index = 0
var current_costume_index = 0
var characters_without_summons:Array=[]

@onready var character_image = %character_image
@onready var character_text = %character_text
@onready var ascensions_tab_cont = %ascensions_TabCont
@onready var button = $_VBoxContainer_5/Button

func open_folder_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _ready():
	#character_image.queue_free()
	print("\nGlobals.characters=", Globals.characters)
	for character in Globals.characters:
		if character["Name"].contains('/'):
			continue
		characters_without_summons.append(character)
	print("characters_without_summons=",characters_without_summons)
	_update_character_display()

func _update_character_display():
	var character = characters_without_summons[current_character_index]
	#print_debug("character=", character)
	
	# Clear existing tabs
	for child in ascensions_tab_cont.get_children():
		ascensions_tab_cont.remove_child(child)
		child.call_deferred("queue_free")
	print("\n ---Adding character Name=", character["Name"])
	# Add tabs for each ascension

	

	print("Adding character ascensions size=", character["ascensions"].size())
	print("Adding character ascensions=", character["ascensions"])
	for ascension_index in range(character["ascensions"].size()):
		var ascension = character["ascensions"][ascension_index]
		
		if ascension.size() == 1:
			# Single sprite - add directly to ascensions tab
			var texture = ImageTexture.create_from_image(Globals.local_path_to_servant_sprite[ascension[0]])
			var texture_rect = TextureRect.new()
			texture_rect.texture = texture
			texture_rect.custom_minimum_size = Vector2(250, 250)
			texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			
			var tab_namee="Ascension " + str(ascension_index + 1)
			print("Adding ascension tab for index ", ascension_index," with name ", tab_namee)
			texture_rect.name=tab_namee

			ascensions_tab_cont.add_child(texture_rect,true)
			
			
		else:
			# Multiple costumes - create nested TabContainer
			var costume_tab = TabContainer.new()
			costume_tab.tab_changed.connect(_on_costume_tab_changed)
			costume_tab.tab_alignment = TabBar.ALIGNMENT_CENTER
			
			for costume_index in range(ascension.size()):
				var texture = ImageTexture.create_from_image(Globals.local_path_to_servant_sprite[ascension[costume_index]])
				var texture_rect = TextureRect.new()
				texture_rect.texture = texture
				texture_rect.custom_minimum_size = Vector2(250, 250)
				texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				
				
				
				var tab_title = "Base" if costume_index == 0 else "Costume " + str(costume_index)
				#print("Adding costume tab for ascension ", ascension_index, " costume index ", costume_index, " with title ", tab_title)
				var tab_namee="Ascension " + str(ascension_index + 1)
				costume_tab.name=tab_namee
				texture_rect.name=tab_title
				
				costume_tab.add_child(texture_rect,true)
			
			ascensions_tab_cont.add_child(costume_tab,true)
		#ascensions_tab_cont.set_tab_title(ascension_index, "Ascension " + str(ascension_index + 1))
	# Set current tabs
	
	ascensions_tab_cont.current_tab = current_ascension_index
	#_update_costume_tab()
	print("update char disp current_character_index=",current_character_index)
	
	character_text.text = character["Text"]

func _update_costume_tab():
	if %ascensions_TabCont.get_child_count() > current_ascension_index:
		var current_tab = %ascensions_TabCont.get_child(current_ascension_index)
		if current_tab is TabContainer:
			current_tab.current_tab = current_costume_index

func get_current_servant():
	var char_name = characters_without_summons[current_character_index]["Name"]
	return {
		"name": char_name,
		"ascension": current_ascension_index,
		"costume": current_costume_index
	}

func _on_left_button_pressed():
	current_character_index = (current_character_index - 1 + characters_without_summons.size()) % characters_without_summons.size()
	current_ascension_index = 0
	current_costume_index = 0
	_update_character_display()

func _on_right_button_pressed():
	current_character_index = (current_character_index + 1) % characters_without_summons.size()
	current_ascension_index = 0
	current_costume_index = 0
	_update_character_display()

# Add these new functions to handle tab changes
func _on_ascensions_tab_cont_tab_changed(tab):
	print("_on_ascensions_tab_cont_tab_changed: tab=",tab)
	current_ascension_index = tab
	current_costume_index = 0
	_update_costume_tab()

# Connect this to the tab_changed signal of dynamically created costume TabContainers
func _on_costume_tab_changed(tab):
	print("_on_costume_tab_changed: tab=",tab)
	current_costume_index = tab


func _on_button_pressed():
	button.text=str(get_current_servant())
	pass # Replace with function body.
