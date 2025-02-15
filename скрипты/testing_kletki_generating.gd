extends Node2D
const cell_scene = preload("res://клетка.tscn")
# Путь к сцене клетки

#ключ значение {1:=>[[position_x,pos_y],[artibutes]]}
var array_kletok={}
var cell_count = 30
var cell_size = Vector2(64, 64)
var scene_bounds = Vector2(1024, 768)
# Минимальное расстояние между клетками
var min_distance = 10.0

# Словарь позиций клеток, где ключ - индекс клетки, значение - позиция клетки
var cell_positions = {}
# Словарь соединений, где connected[i][j] == true, если клетка i соединена с клеткой j
var connected = {}

func _ready():
	randomize()
	generate_cells()
	connect_cells_with_probability()

func generate_cells():
	for i in range(cell_count):
		var new_position = generate_random_position()
		if new_position!=Vector2():
			cell_positions[i] = new_position
			var cell_instance = cell_scene.instantiate()
			add_child(cell_instance)
			cell_instance.position = new_position
			connected[i] = {}

func generate_random_position():
	var max_attempts = 100
	for attempt in range(max_attempts):
		var position = Vector2(
			randf_range(0, scene_bounds.x - cell_size.x),
			randf_range(0, scene_bounds.y - cell_size.y)
		)
		var is_valid = true
		for key in cell_positions:
			if position.distance_to(cell_positions[key]) < cell_size.x + min_distance:
				is_valid = false
				break
		if is_valid:
			return position
	return Vector2()

func connect_cells_with_probability():
	for i in range(cell_count):
		for j in range(i + 1, cell_count):
			if not connected[i].has(j):
				var distance = cell_positions[i].distance_to(cell_positions[j])
				#var probability = exp(-distance * distance_decay)
				var probability=snapped(1/(distance/100), 0.01)
				print(distance)
				print(probability)
				
				if randf() < probability:
					if not check_line_intersection(cell_positions[i], cell_positions[j]):
						draw_lineff(cell_positions[i], cell_positions[j])
						connected[i][j] = true
						connected[j][i] = true

func check_line_intersection(p1, p2):
	for i in connected:
		for j in connected[i]:
			if i == j:
				continue
			var q1 = cell_positions[i]
			var q2 = cell_positions[j]
			if q1 == p1 or q1 == p2 or q2 == p1 or q2 == p2:
				continue
			if segments_intersect(p1, p2, q1, q2):
				return true
	return false

func segments_intersect(p1, p2, q1, q2):
	return ccw(p1, q1, q2) != ccw(p2, q1, q2) and ccw(p1, p2, q1) != ccw(p1, p2, q2)

func ccw(a, b, c):
	return (c.y - a.y) * (b.x - a.x) > (b.y - a.y) * (c.x - a.x)

func draw_lineff(start, end):
	var line = Line2D.new()
	add_child(line)
	line.width = 2
	line.default_color = Color(1, 1, 1)
	line.add_point(start)
	line.add_point(end)
