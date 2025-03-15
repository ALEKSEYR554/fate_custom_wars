extends Node2D

var dragging = false
var drag_offset = Vector2()

var resizing = false
var resize_start_size = Vector2()
var resize_start_global_position = Vector2() # Запоминаем глобальную позицию Node2D в начале изменения размера
@onready var texture_rect = %TextureRect
@onready var resize_handle_area = %ResizeHandleArea



@export var min_size = Vector2(10, 10)

func _ready():
	#texture_rect = get_node("TextureRect")
	if texture_rect == null:
		printerr("Error: TextureRect node not found as a child of this Node2D.")
		return

	#resize_handle_area = texture_rect.get_child(0)
	if resize_handle_area == null:
		printerr("Error: ResizeHandleArea node not found as a child of TextureRect.")
		return

	_update_resize_handle_position()


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			resize_start_global_position = global_position
			if event.pressed:
				if is_mouse_over_texture_rect():
					dragging = true
					drag_offset = get_global_mouse_position() - global_position

				if is_mouse_over_area(resize_handle_area):
					resizing = true
					resize_start_size = texture_rect.size
					#resize_start_global_position = global_position # **Захватываем позицию только здесь, при нажатии кнопки**
					drag_offset = get_global_mouse_position()
			else:
				dragging = false
				resizing = false

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

	if resizing:
		var mouse_pos = get_global_mouse_position()
		var delta_mouse = mouse_pos - drag_offset
		var new_size = resize_start_size + delta_mouse

		new_size.x = max(new_size.x, min_size.x)
		new_size.y = max(new_size.y, min_size.y)

		# Вычисляем смещение позиции Node2D, чтобы верхний левый угол TextureRect оставался на месте
		var size_difference = new_size - texture_rect.size # Разница между новым и текущим размерами
		global_position = resize_start_global_position + size_difference * Vector2(0.5, 0.5) # Смещаем Node2D на половину разницы размеров

		texture_rect.size = new_size
		_update_resize_handle_position()


func _update_resize_handle_position():
	if resize_handle_area != null and texture_rect != null:
		resize_handle_area.position = texture_rect.size


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
