extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":26,
	"servant_class":"Lancer",
	"ideology":["Lawful","Good"],
	"gender":"Male",
	"attribute":"Human",
	"attack_range":2,#most lancers has range=2
	"attack_power":3,#check table info
	"strength":"C",
	"agility":"B",
	"endurance":"C",
	"luck":"C",
	"magic":{"Rank":"C","Power":0,"resistance":3},#check table info
	"traits":["Artoria Face",
	 "Hominidae Servant",
	 "Humanoid",
	 "Living Human",
	 "Round Table Knight",
	 "Servant",
	 "Seven Knights Servant",
	 "Weak to Enuma Elish"]
}

var servant_class
var ideology
var attack_range
var attack_power
var agility
var endurance
var hp
var luck
var magic
var traits=[]
var strength
var buffs=[]
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"#if character doen't have weapon then dont touch it
var phantasm_charge=0

var attribute
var gender
func _ready():
	servant_class=default_stats["servant_class"]
	ideology=default_stats["ideology"]
	attack_range=default_stats["attack_range"]
	attack_power=default_stats["attack_power"]
	agility=default_stats["agility"]
	endurance=default_stats["endurance"]
	hp=default_stats["hp"]
	magic=default_stats["magic"]
	luck=default_stats["luck"]
	traits=default_stats["traits"]
	attribute=default_stats["attribute"]
	gender=default_stats["gender"]
	strength=default_stats["strength"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":7,
	"Description":"Increases self damage by 3 for 3 turns. (Cooldown - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Duration":3,
				"Power":3}
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":6,
	"Description":"Charge self's Noble Phantasm bar by 1 point (Cooldown - 6)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"NP Charge",
				"Power":1#1 point
                }
				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Increases self's defence by 2 times until end of next turn (Cooldown - 6)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"DEF Up X",
				"Duration":1.5,#end of next turn
				"Power":2}#2 times
			],
			"Cast":"Self"}
		]
},

}

var phantasms={
	"!!!!!!!!!!!!!!!!!!PHANTASM NAME!!!!!!!!!!!!!!!!!!":{
		"Rank":"A",
		"Description":"""PHANTASM NAME: - Deals 7 damage to single enemie in range 6\n
	Overcharge:  Deals 14 damage to single enemie in range 6
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Single In Range","Range":6,"Damage":7},
			"Overcharge":
				{"Cost":12,"Attack Type":"Single In Range","Range":6,"Damage":14}
			}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
