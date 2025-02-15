extends Button
# Called when the node enters the scene tree for the first time.
var color=Color.GOLD

func _ready():
	self.size=Vector2(60,60)
	self.position=Vector2(0,0)
	self.pivot_offset=Vector2(60,60)
	#position=Vector2(-300,-300)
	#self.z_index=2
	pass # Replace with function body.


func _draw():
	# Your draw commands here
	draw_circle(Vector2(0,0),30, color)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
