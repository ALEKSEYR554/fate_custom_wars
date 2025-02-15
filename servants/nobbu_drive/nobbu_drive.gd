extends Node2D

const servant_class="Caster"
var ideology=["Balanced","Neutral"]
var attack_range=1
var attack_power=1
var agility="D"#ловкость
var Endurance="E"#вынослиость
var hp=15
var luck="B+"
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
#magic power / magic resistance
var magic=["A+",6,12]
var additional_moves=0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func first_skill():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
