extends Control

# Массив данных о персонажах
#var characters = [
#]

# Текущий индекс персонажа
var current_character_index = 0
# GUI элементы
@onready var character_image = $_HBoxContainer_3/_VBoxContainer_5/_TextureRect_6
@onready var character_text = $_HBoxContainer_3/_VBoxContainer_5/_Label_7
signal sleep

func open_folder_pressed():
	OS.shell_open(ProjectSettings.globalize_path("user://"))
	

func _ready():
	#print(str("\n\n\n EDITOR=",OS.has_feature("editor")," \n\n"))
	##$FileDialog.root_subfolder = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	#if !OS.has_feature("editor"):
	#	print("servant selection type Compiled")
	#	var count=1
	#	characters =[]
	#	var dir = DirAccess.open(Globals.user_folder+"servants/")
	#	print(OS.get_user_data_dir())
	#	for folder in dir.get_directories():
	#		print("appending characters\n")
	#		var img = Image.new()
	#		img.load(Globals.user_folder+"servants/"+str(folder)+"/sprite.png")
	#		characters.append({"Name":folder,"image":img, "Text": "Character "+str(count)+" Description "})
	#		print("characters="+str(characters))
	#else:
	#	characters=[]
	#	print("servant selection type Editor")
	#	for folder in ["bunyan","el_melloy","gray","hakuno_female","summer_bb","tamamo","ereshkigal_lancer","jaguar_man"]:
	#		var img = Image.new()
	#		img.load("res://servants/"+str(folder)+"/sprite.png")
	#		characters.append({"Name":folder,"image":img, "Text": "Character "+str(folder)+" Description "})
	#		
	_update_character_display()

func _update_character_display():
	var character = Globals.characters[current_character_index]
	character_image.texture = ImageTexture.create_from_image(character["image"])#load(character["image"])
	character_text.text = character["Text"]

func get_current_servant():
	return Globals.characters[current_character_index]["Name"]

func _on_left_button_pressed():
	current_character_index = (current_character_index - 1 + Globals.characters.size()) % Globals.characters.size()
	_update_character_display()

func _on_right_button_pressed():
	current_character_index = (current_character_index + 1) % Globals.characters.size()
	_update_character_display()
