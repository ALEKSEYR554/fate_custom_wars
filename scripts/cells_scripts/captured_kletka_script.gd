extends Node2D

var color=Color.GOLD

func _ready():
	#self.size=Vector2(60,60)
	#self.position=Vector2(0,0)
	#self.pivot_offset=Vector2(60,60)
	#position=Vector2(-300,-300)
	#self.z_index=2
	pass # Replace with function body.


func _draw():
	# Your draw commands here
	if color==Color.FUCHSIA:
		draw_line(Vector2(-20,-20),Vector2(20,20),Color.RED,5.0)
		draw_line(Vector2(-20,20),Vector2(20,-20),Color.RED,5.0)
		#draw_cross
	else:
		draw_circle(Vector2(0,0),30, color)
	pass
