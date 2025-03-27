extends Node2D

var dragging = false
var drag_offset = Vector2()

var resizing = false
var resize_start_size = Vector2()
var resize_start_global_position = Vector2()
var resize_handle_area = null
var texture_rect = null

@export var min_size = Vector2(10, 10)

# Кнопки UI (больше не null в _ready, они дочерние TextureRect)

@onready var z_index_down_button = $TextureRect/ZIndexDownButton
@onready var delete_button = $TextureRect/DeleteButton
@onready var z_index_up_button = $TextureRect/ZIndexUpButton



var is_selected = false

func _ready():
	texture_rect = get_node("TextureRect")
	if texture_rect == null:
		printerr("Error: TextureRect node not found as a child of this Node2D.")
		return

	resize_handle_area = texture_rect.get_node("ResizeHandleArea")
	if resize_handle_area == null:
		printerr("Error: ResizeHandleArea node not found as a child of TextureRect.")
		return

	_update_resize_handle_position()

	# Получаем ссылки на кнопки UI (теперь они дочерние TextureRect)
	#delete_button = texture_rect.get_node("DeleteButton") # Получаем от TextureRect
	#z_index_up_button = texture_rect.get_node("ZIndexUpButton") # Получаем от TextureRect
	#z_index_down_button = texture_rect.get_node("ZIndexDownButton") # Получаем от TextureRect

	# Подключаем сигналы кнопок
	if delete_button:
		delete_button.pressed.connect(_on_delete_button_pressed)
	if z_index_up_button:
		z_index_up_button.pressed.connect(_on_z_index_up_button_pressed)
	if z_index_down_button:
		z_index_down_button.pressed.connect(_on_z_index_down_button_pressed)

	_set_buttons_visible(false)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if is_mouse_over_texture_rect():
					if not dragging and not resizing:
						_set_buttons_visible(true)
						is_selected = true
					dragging = true
					drag_offset = get_global_mouse_position() - global_position

				elif is_mouse_over_area(resize_handle_area):
					resizing = true
					resize_start_size = texture_rect.size
					resize_start_global_position = global_position
					drag_offset = get_global_mouse_position()

				else: # Клик вне TextureRect
					if is_selected and not (is_mouse_over_button(delete_button) or is_mouse_over_button(z_index_up_button) or is_mouse_over_button(z_index_down_button)):
						_set_buttons_visible(false)
						is_selected = false

			else: # Кнопка мыши отпущена
				dragging = false
				resizing = false


@rpc("any_peer","call_local")
func rpc_drag(mouse_pos_local,ofset_local):
	global_position = mouse_pos_local - ofset_local

@rpc("any_peer","call_local")
func rpc_resizing(new_size):
	new_size.x = max(new_size.x, min_size.x)
	new_size.y = max(new_size.y, min_size.y)

	# Вычисляем смещение позиции Node2D, чтобы верхний левый угол TextureRect оставался на месте
	var size_difference = new_size - texture_rect.size
	global_position = resize_start_global_position + size_difference * Vector2(0.5, 0.5)

	texture_rect.size = new_size
	_update_resize_handle_position() # Обновляем позицию ручки и кнопок


func _process(delta):
	if dragging:
		rpc("rpc_drag",get_global_mouse_position() , drag_offset)
		#global_position = get_global_mouse_position() - drag_offset

	if resizing:
		var mouse_pos = get_global_mouse_position()
		var delta_mouse = mouse_pos - drag_offset
		var new_size = resize_start_size + delta_mouse
		rpc("rpc_resizing",new_size)
		


func _update_resize_handle_position():
	if resize_handle_area != null and texture_rect != null:
		resize_handle_area.position = texture_rect.size

	# **Обновляем позиции кнопок здесь**
	_update_button_positions()


func _update_button_positions():
	if texture_rect == null:
		return

	# Пример: Располагаем кнопки над TextureRect, по центру по горизонтали
	var button_spacing = 5 # Расстояние между кнопками
	var total_buttons_width = 0
	if delete_button:
		total_buttons_width += delete_button.size.x
	if z_index_up_button:
		total_buttons_width += z_index_up_button.size.x
	if z_index_down_button:
		total_buttons_width += z_index_down_button.size.x
	total_buttons_width += button_spacing * 2 # Учитываем промежутки между кнопками

	var start_x = -total_buttons_width / 2.0 + delete_button.size.x / 2.0 # Начальная X позиция для центрирования

	var button_y_offset = -30 # Смещение кнопок вверх от TextureRect

	if delete_button:
		delete_button.position = Vector2(start_x, button_y_offset)
		start_x += delete_button.size.x + button_spacing
	if z_index_up_button:
		z_index_up_button.position = Vector2(start_x, button_y_offset)
		start_x += z_index_up_button.size.x + button_spacing
	if z_index_down_button:
		z_index_down_button.position = Vector2(start_x, button_y_offset)
		start_x += z_index_down_button.size.x + button_spacing


func is_mouse_over_texture_rect() -> bool:
	var mouse_pos_local_to_texture_rect = texture_rect.get_local_mouse_position()
	var texture_rect_size = texture_rect.size
	var texture_rect_rect = Rect2(Vector2.ZERO, texture_rect_size)
	return texture_rect_rect.has_point(mouse_pos_local_to_texture_rect)

func is_mouse_over_area(area: Area2D) -> bool:
	var mouse_pos = get_global_mouse_position()
	var space_state = area.get_world_2d().direct_space_state
	var query_parameters = PhysicsPointQueryParameters2D.new()
	query_parameters.position = mouse_pos
	query_parameters.collide_with_areas = true
	query_parameters.collide_with_bodies = false

	var result = space_state.intersect_point(query_parameters)
	if result.size() > 0:
		for res in result:
			if res.collider == area:
				return true
	return false

func _set_buttons_visible(visible: bool):
	if delete_button:
		delete_button.visible = visible
	if z_index_up_button:
		z_index_up_button.visible = visible
	if z_index_down_button:
		z_index_down_button.visible = visible

func is_mouse_over_button(button: Button) -> bool:
	if button == null or not button.visible:
		return false
	var mouse_pos_local_to_button = button.get_local_mouse_position()
	var button_size = button.size
	var button_rect = Rect2(Vector2.ZERO, button_size)
	return button_rect.has_point(mouse_pos_local_to_button)


# Функции-обработчики сигналов кнопок (не изменились)
func _on_delete_button_pressed():
	rpc("rpc_delete_but")

@rpc("any_peer","call_local","reliable")
func rpc_delete_but():
	queue_free()
	#printerr("Node2D deleted via button!")

func _on_z_index_up_button_pressed():
	#z_index += 1
	rpc("rpc_z_change",1)
	
@rpc("any_peer","call_local","reliable")
func rpc_z_change(amount:int):
	z_index += amount

func _on_z_index_down_button_pressed():
	#z_index -= 1
	rpc("rpc_z_change",-1)
	#printerr("Z-index decreased via button to: ", z_index)
