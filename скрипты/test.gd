extends Node2D
#1717486472.816
#1717743283.689
var glow_array=[]
const Glow = preload("res://glow.tscn")
var time
var glowing_kletka_number_selected
var is_game_started=false

@onready var players_handler = $players_handler

# kletka: who is there node2d
var occupied_kletki={}
var current_player


var current_action
var current_action_points
var current_kletka
@onready var reset_button = $Camera2D/GUI/reset
var blinking_glow_button
const ANGRA = preload("res://player.tscn")
const cell_scene = preload("res://клетка.tscn")

@onready var skill_button = $Camera2D/GUI/Skill
@onready var attack_button = $Camera2D/GUI/Attack
@onready var move_button = $Camera2D/GUI/Move
@onready var cancel_button = $Camera2D/GUI/Cancel
@onready var current_action_points_label = $Camera2D/GUI/current_actions
@onready var make_action_button = $Camera2D/GUI/make_action

var texture_size=200

# Путь к сцене клетки
# Количество клеток
var cell_count # 100#randf_range(25,40)
# Размер клетки (ширина и высота)
var cell_size = Vector2(64, 64)
# Границы сцены, в которых могут располагаться клетки
var scene_bounds = Vector2(3000, 1500)
# Минимальное расстояние между клетками
var min_distance = 200.0
@onready var start_button = $Camera2D/GUI/start
@onready var gui = $Camera2D/GUI


# Словарь позиций клеток, где ключ - индекс клетки, значение - позиция клетки
var cell_positions = {}
# Словарь соединений, где connected[i][j] == true, если клетка i соединена с клеткой j
var connected = {}

func _ready():
	gui.z_index=99
	generate_pole()
	#print(get_all_children(self))

func generate_pole():
	cell_positions = {}
	connected = {}
	time=Time.get_unix_time_from_system()
	#time=1717424478.993
	print("seed"+str(time))
	seed(time)
	cell_count=round(randf_range(25,40))
	
	print(cell_count)
	generate_cells()
	print("ooooo="+str(cell_count))
	connect_cells_minimum(time)
	print("eeeee="+str(cell_count))
	print(cell_positions)

func get_random_unoccupied_kletka():
	var rand_kletka
	for p in range(10):
		rand_kletka=int(round(randf_range(0,cell_count-1)))
		if !occupied_kletki.has(rand_kletka):
			break
	return rand_kletka

func get_kletki_with_enemies_you_can_reach_in_steps(steps):
	#current_kletka
	var output=[]
	for end in occupied_kletki.keys():
		if current_kletka == end:
			return true
		var queue = []
		var visited = {}
		queue.append([current_kletka, 0])
		visited[current_kletka] = true
		while not queue.is_empty():
			var current = queue.front()
			queue.pop_front()
			var current_node = current[0]
			var current_steps = current[1]

			if current_steps >= steps:
				continue

			for neighbor in connected[current_node].keys():
				if neighbor == end:
					if !output.has(neighbor):
						output.append(neighbor)
				if not visited.has(neighbor):
					visited[neighbor] = true
					queue.append([neighbor, current_steps + 1])

	return output

func generate_characters_on_random_kletkax():
	var dir = DirAccess.open("user://servants/")
	print(str(dir.get_directories()))
	for i in dir.get_directories():#getting custom characters
		var player = Node2D.new()
		var texture=Sprite2D.new()
		player.set_script(load("user://servants/"+str(i)+"/"+str(i)+".gd"))
		texture.texture=load("user://servants/"+str(i)+"/sprite.png")
		
		var sizes=texture.texture.get_size()
		texture.position=Vector2(0,-(texture_size)/2)
		texture.scale=Vector2(texture_size/sizes.x,texture_size/sizes.y)
		
		print("sizes="+str(sizes))
		player.add_child(texture,true)
		var rand_kletka=get_random_unoccupied_kletka()
		
		#var jopa = ANGRA.instantiate()
		var cord = cell_positions[rand_kletka]
		occupied_kletki[rand_kletka]=player
		players_handler.add_child(player,true)
		player.name=i
		player.position=cord
		player.set_process(true)
		occupied_kletki[rand_kletka]=player
		players_handler.players.append(player)
		
		#add_child(jopa,true)
		#print(rand_kletka)
		#print(cell_positions[rand_kletka])
		
		#jopa.position = cord

func generate_cells():
	var i=0
	
	for j in range(cell_count):
		var new_position = generate_random_position(time)
		if new_position != Vector2():
			cell_positions[i] = new_position
			var cell_instance = cell_scene.instantiate()
			add_child(cell_instance,true)
			cell_instance.position = new_position
			cell_instance.name="клетка "+str(i)
			connected[i] = {}
			i+=1
	print("iiiii="+str(i))
	print("fff="+str(cell_count))
	
	cell_count=i

func generate_random_position(time):
	seed(time)
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

	# Если не удалось найти подходящее место
	return Vector2()

func connect_cells_minimum(time):
	seed(time)
	print("nnnn="+str(cell_count))
	for i in range(cell_count):
		if connected[i].size() < 2:
			var distances = []
			for j in range(cell_count):
				if i != j and not connected[i].has(j):
					var distance = cell_positions[i].distance_to(cell_positions[j])
					distances.append({'index': j, 'distance': distance})
			distances.sort_custom(_sort_distance)

			var connections_needed = 2 - connected[i].size()
			var connections_made = 0
			for k in range(distances.size()):
				if connections_made >= connections_needed:
					break
				var j = distances[k]['index']
				if not check_line_intersection(cell_positions[i], cell_positions[j]):
					draw_lineff(cell_positions[i], cell_positions[j])
					connected[i][j] = true
					connected[j][i] = true
					connections_made += 1

	# Обеспечить максимум 5 соединений на каждую клетку
	for i in range(cell_count):
		var rng=round(randf_range(2,4))
		if connected[i].size() < rng:
			var distances = []
			for j in range(cell_count):
				if i != j and not connected[i].has(j):
					var distance = cell_positions[i].distance_to(cell_positions[j])
					distances.append({'index': j, 'distance': distance})
			distances.sort_custom(_sort_distance)

			for k in range(distances.size()):
				if connected[i].size() >= rng:
					break
				var j = distances[k]['index']
				if not check_line_intersection(cell_positions[i], cell_positions[j]):
					draw_lineff(cell_positions[i], cell_positions[j])
					connected[i][j] = true
					connected[j][i] = true

func _sort_distance(a, b):
	if a['distance'] < b['distance']:
		return true
	return false

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
	add_child(line,true)
	line.width = 3
	line.z_index=-1
	line.default_color = Color.WHITE
	line.add_point(start)
	line.add_point(end)

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr

func _on_reset_pressed():
	for i in get_all_children(self):
		#print(i)
		pass
	for i in get_all_children(self):
		if i.name.contains("клетка") or i.name.contains("Line2D") or i.name.contains("angra"):
			remove_child(i)
		#print(i.name)
	#pass
	#await get_tree().create_timer(2).timeout
	#for i in get_all_children(self):
	#print(i.name)
	generate_pole()
 # Replace with function body.
	pass # Replace with function body.

func glow_cletki_intiate():
	glow_array=[]
	for i in get_all_children(self):
		if str(i.name).contains("клетка"):
			var kletka_numebr=int(i.name.trim_prefix("клетка "))
			var pos = cell_positions[int(kletka_numebr)]
			var glow = Glow.instantiate()
			glow.visible=false
			add_child(glow,true)
			glow.position = pos
			glow.name="glow "+str(kletka_numebr)
			#glow.button_down.connect(glow_cletka_pressed)
			#print(glow.name)

			glow.button_down.connect(glow_cletka_pressed.bind(glow))
			glow_array.append(glow)

func get_unoccupied_kletki():
	var output=[]
	for i in range(glow_array.size()):
		if occupied_kletki.has(i):
			continue
		output.append(i)
	return output

func choose_glowing_cletka_by_ids_array(glow_kletki_to_blink):
	#param: "unoccupied"
	print("glow_array="+str(glow_array))
	print("glow_kletki_to_blink="+str(glow_kletki_to_blink))
	blinking_glow_button=true
	var blink=1

	for i in glow_kletki_to_blink:#adding visibility
		glow_array[i].modulate=Color(1,1,1,0)
		glow_array[i].visible=true
		print(i)
	while (blinking_glow_button):#blinking
		for i in glow_kletki_to_blink:
			glow_array[i].modulate=Color(1,1,1,blink)
		await get_tree().create_timer(1).timeout
		if blink==1:
			blink=0
		else:
			blink=1
		
	if !blinking_glow_button:#removing
		for i in glow_kletki_to_blink:
			glow_array[i].modulate=Color(1,1,1,1)
			glow_array[i].visible=false

func glow_cletka_pressed(glow_kletka_selected):
	glowing_kletka_number_selected=int(glow_kletka_selected.name.trim_prefix("glow "))
	print(glow_kletka_selected)
	if blinking_glow_button:
		make_action_button.visible=true
		current_player = ANGRA.instantiate()
		add_child(current_player,true)
		current_player.position=glow_kletka_selected.position
		blinking_glow_button=false
		current_kletka=glowing_kletka_number_selected
		print("current kletka="+str(current_kletka))
		print(connected[current_kletka])
	elif current_action=="move":
		current_action="wait"
		print("cr-klet="+str(current_kletka))
		var tmp=connected[current_kletka]
		print(tmp)
		for i in tmp:
			glow_array[i].visible=false
			#i.visible=false
		current_player.position=glow_kletka_selected.position
		current_action_points-=1
		current_action_points_label.text=str(current_action_points)
		current_kletka=glowing_kletka_number_selected
		if current_action_points==0:
			make_action_button.disabled=true

func _on_start_pressed():
	#for i in get_all_children(self):
		#print(i)
	is_game_started=true
	main_game()

func new_turn():
	make_action_button.disabled=false

func main_game():
	print("GAME STARTED")
	print("connected="+str(connected))
	#spawn random dommies
	generate_characters_on_random_kletkax()
	glow_cletki_intiate()
	#choose kletka so spawn
	var kletka_to_initial_spawn=get_unoccupied_kletki()
	choose_glowing_cletka_by_ids_array(kletka_to_initial_spawn)
	
	print("occupied_kletki="+str(occupied_kletki))
	
	reset_button.queue_free()
	#random_kletka()
	start_button.queue_free()
	make_action_button.disabled=false
	#attack_button.visible=true
	#move_button.visible=true
	#cancel_button.visible=true
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	pass
	

func _on_attack_pressed():
	if current_action_points>=1:
		#for i in occupied_kletki.keys():
		var kk=get_kletki_with_enemies_you_can_reach_in_steps(3)
		for i in kk:
			print(occupied_kletki[i])
		#pass


func _on_cancel_pressed():
	if current_action_points>=1:
		pass


func _on_move_pressed():
	print(current_action_points)
	if current_action_points>=1:
		current_action="move"
		_on_make_action_pressed()
		var cn=connected[current_kletka]
		print("cn= "+str(cn))
		for i in cn:
			if occupied_kletki.has(i):
				continue
			glow_array[i].visible=true
		pass


func _on_make_action_pressed():
	skill_button.visible=!skill_button.visible
	attack_button.visible=!attack_button.visible
	move_button.visible=!move_button.visible
	cancel_button.visible=!cancel_button.visible
	pass # Replace with function body.


func _on_end_turn_pressed():
	current_action_points=3
	current_action_points_label.text=str(current_action_points)
	make_action_button.disabled=false
	players_handler.end_turn()
	pass # Replace with function body.


func _on_skill_pressed():
	pass # Replace with function body.
