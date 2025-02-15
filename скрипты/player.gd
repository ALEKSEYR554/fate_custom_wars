extends Node2D
var hp=30
const servant_class="Berserker"
var ideology=["Balanced","Neutral"]
var attack_range=1
var attack_power=3
var agility="C"#ловкость
var Endurance="A"#вынослиость
var luck="E+"
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
#magic power / magic resistance
var magic=[0,1]
var additional_moves=0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func first_skill():
	pass

func attack():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	print(self.name)
	pass # Replace with function body.
