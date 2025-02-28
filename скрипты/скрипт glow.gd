extends Node2D
# Called when the node enters the scene tree for the first time.
var color=Color.GOLD

func _ready():
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
	#p_pos=Vector2(-p_pos.x/2)
	#print("writing Button")
	draw_circle(Vector2(0,0),30, color)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
