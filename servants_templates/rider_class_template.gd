extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":26,
	"servant_class":"Rider",
	"ideology":["Lawful","Good"],
	"attack_range":1,#most riders has range=1
	"attack_power":4,#check table info
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

var buffs=[]
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"#if character doen't have weapon then dont touch it
var phantasm_charge=0

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
			{"Name":"NP Gauge",
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
		"Description":"""PHANTASM NAME: - Deals 6 damage to all enemies on one line in 5 range ignoring defence and defencive buffs. Then charges self NP bar by 1 point\n
	Overcharge: Deals 12 damage to all enemies on one line in 5 range ignoring defence and defencive buffs. Then charges self NP bar by 2 points
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Line","Range":5,"Damage":6,
				"Ignore":["Buff Increase Defence","Defence"],
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Gauge",
								"Duration":3,
								"Power":1}
						],
						"Cast":"Self"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Line","Range":5,"Damage":12,
				"ignore":["Defence","defensive_buffs"],
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Gauge",
								"Duration":3,
								"Power":2}
						],
						"Cast":"Self"},
						
						{"Buffs":[
							{"Name":"Def Down",
								"Duration":3,
								"Power":2}
						],
						"Cast":"Phantasm Attacked"},
						]
					},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
