extends Node2D

@onready var glow: Button = $Button

var color=Color.GOLD
#var color=Color.FUCHSIA
func _ready():
	glow.size=Vector2(100,100)
	glow.modulate=Color(1,1,1,0)
	glow.set_anchors_preset(8)#PRESET_CENTER
	glow.position=Vector2(-glow.size.x/2,-glow.size.y/2)
	#self.size=Vector2(60,60)
	#self.position=Vector2(0,0)
	#self.pivot_offset=Vector2(60,60)
	#position=Vector2(-300,-300)
	#self.z_index=2
	#var par=get_parent()
	#par.draw.connect(_drawii.bind())
	pass # Replace with function body.


func _draw():
	# Your draw commands here
	#var p_pos=get_parent().position
	#p_pos=Vector2(-p_pos.x/2)#
	#print("writing Button")
	if color==Color.FUCHSIA:
		draw_line(Vector2(-20,-20),Vector2(20,20),Color.RED,5.0)
		draw_line(Vector2(-20,20),Vector2(20,-20),Color.RED,5.0)
		#draw_cross
	else:
		draw_circle(Vector2(0,0),30, color)
	pass
