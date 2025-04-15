extends Control

# Массив данных о персонажах
var characters = [
	{ "image": "res://servants/bunyan/sprite.png", "Text": "Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah Blah " },
	{ "image": "res://servants/el_melloy/sprite.png", "Text": "Character 2 Description" },
	{ "image": "res://servants/gray/sprite.png", "Text": "Character 3 Description" }
]

# Текущий индекс персонажа
var current_character_index = 0

# GUI элементы
var character_image
var character_text

func _ready():
	# Создаем корневой контейнер, который будет масштабироваться
	var root_container = VBoxContainer.new()
	add_child(root_container)
	root_container.anchor_right = 1.0
	root_container.anchor_bottom = 1.0

	
	
	# Создаем контейнер для кнопок и изображения с текстом
	var hbox = HBoxContainer.new()
	root_container.add_child(hbox)
	
	# Кнопка для предыдущего персонажа
	var left_button = Button.new()
	left_button.text = "<"
	left_button.connect("pressed", Callable(self, "_on_left_button_pressed"))
	hbox.add_child(left_button)
	
	# Создаем VBoxContainer для изображения и текста
	var vbox = VBoxContainer.new()
	hbox.add_child(vbox)
	
	# Изображение персонажа
	character_image = TextureRect.new()
	character_image.expand = true
	character_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_image.custom_minimum_size = Vector2(200, 200)  # Минимальный размер для изображения
	vbox.add_child(character_image)
	
	# Текст персонажа
	character_text = Label.new()
	character_text.autowrap_mode = TextServer.AUTOWRAP_WORD  # Автоматический перенос текста
	vbox.add_child(character_text)
	
	# Кнопка для следующего персонажа
	var right_button = Button.new()
	right_button.text = ">"
	right_button.connect("pressed", Callable(self, "_on_right_button_pressed"))
	hbox.add_child(right_button)
	
	# Обновляем отображение персонажа
	_update_character_display()

func _update_character_display():
	var character = characters[current_character_index]
	character_image.texture = load(character["image"])
	character_text.text = character["Text"]

func _on_left_button_pressed():
	current_character_index = (current_character_index - 1 + characters.size()) % characters.size()
	_update_character_display()

func _on_right_button_pressed():
	current_character_index = (current_character_index + 1) % characters.size()
	_update_character_display()
