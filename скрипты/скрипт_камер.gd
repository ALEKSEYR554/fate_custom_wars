extends Camera2D
@onready var gui:CanvasLayer = $"../GUI"

# Lower cap for the `_zoom_level`.
var min_zoom := 0.4
# Upper cap for the `_zoom_level`.
var max_zoom := 2.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
var zoom_factor := 0.1
# Duration of the zoom's tween animation.
var zoom_duration := 0.2

var mouse_start_pos
var screen_start_position

var gui_focused=false

var dragging = false
func _ready():
	self.z_index=90
	pass

func mouse_entered_gui_element():
	#print("entered")
	gui_focused=true

func mouse_exited_gui_element():
	#print("exited")
	gui_focused=false

func zoom_():
	if gui_focused:
		return
	if Input.is_action_just_released('zoom_in'):
		set_zoom(get_zoom() + Vector2(0.25, 0.25))
	if Input.is_action_just_released('zoom_out') and self.get_zoom().x > min_zoom and self.get_zoom().y > min_zoom:
		set_zoom(get_zoom() - Vector2(0.25, 0.25))
	
	#print("curr_zoom="+str(get_zoom())+"\n")
func _input(event):
	#print(event)
	if event.is_action("drag"):
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging and not gui_focused:
		position =  (mouse_start_pos - event.position)/zoom + screen_start_position
		

func _physics_process(delta):
	zoom_()
	pass
