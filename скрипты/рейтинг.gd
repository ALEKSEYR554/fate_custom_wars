extends Node2D

var rating_data = [
	{"rank": 1, "image": "res://icon.svg"}, # **Замените ПУТИ к изображениям!**
	{"rank": 2, "image": "res://icon.svg"},
	{"rank": 3, "image": "res://icon.svg"},
	{"rank": 4, "image": "res://icon.svg"},
	{"rank": 5, "image": "res://icon.svg"}
]

var vertical_spacing = 250
var horizontal_spacing = 250
var start_y = 0
var start_x = 0
var line_thickness = 10
var line_color = Color.BLACK
var line :Line2D

var points_array=[]

func do_the_thing(players:Array):
	generate_points(players.size())
	place_players_by_order(players)

func generate_points(mest:int):
	print("generate_points")
	line=Line2D.new()
	add_child(line,true)
	line.position=Vector2(start_x,start_y)
	line.width = line_thickness
	line.z_index=-1
	line.default_color = line_color
	# Отрисовываем линии лесенки
	for i in range(mest):
		# Горизонтальная линия
		line.add_point(Vector2(start_x - i * horizontal_spacing, start_y + i * vertical_spacing))
		line.add_point(Vector2(start_x - (i + 1) * horizontal_spacing, start_y + i * vertical_spacing))

		line.add_point(Vector2(start_x - (i + 1) * horizontal_spacing, start_y + i * vertical_spacing))
		line.add_point(Vector2(start_x - (i + 1) * horizontal_spacing, start_y + (i + 1) * vertical_spacing))

func place_players_by_order(players:Array):
	print("place_players_by_order")
	print("players="+str(players))
	var points=line.points
	var place_count=0
	print("points="+str(points))
	var glob_pos=self.global_position
	for i in range(0,points.size(),4):
		var texture_size=players[place_count].get_child(0).texture.get_size()
		
		var playr_pos=(points[i]+points[i+1])/2
		print("playr_pos="+str(playr_pos))
		players[place_count].position=playr_pos+glob_pos
		
		var count_label=Label.new()
		var label_pos=points[i+1]
		add_child(count_label)
		count_label.position=label_pos
		count_label.text=str(place_count+1)
		count_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		count_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		
		count_label.add_theme_font_size_override("font_size",int(vertical_spacing/1.4))
		count_label.size=Vector2(horizontal_spacing,vertical_spacing)
		place_count+=1
		if place_count>=players.size():
			break
	pass
