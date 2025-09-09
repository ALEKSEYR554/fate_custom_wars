extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":26,
	"servant_class":"Assasin",
	"ideology":["Lawful","Good"],
	"gender":"Male",
	"attack_range":1,#most assasins has range=1
	"attack_power":3,#check table info
	"strength":"C",
	"attribute":"Human",
	"agility":"B",
	"endurance":"C",
	"luck":"C",
	"magic":{"Rank":"C","Power":0,"Resistance":3},#check table info
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
var attribute
var gender
var strength

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
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":10,
	"Description":"Assasin can become invisible for five turns. (Assasin disappears from the field) When at least 2 moves have passed, Assasin can come out of invisibility early and stand on any cell on the field, however, he skips his next turn. (Cooldown - 10).",
	"Effect":[
		{"Buffs":[
			{"Name":"Presence Concealment",
				"Type":"Passive",
				"Minimum Turns":2,
				"Maximum Turns":5,
				"Power":1
				}
			],
			"Cast":"Self"}
	]
}
}
var phantasms={
	"!!!!!!!!!!!!!!!!!!PHANTASM NAME!!!!!!!!!!!!!!!!!!":{
		"Rank":"A",
		"Description":"""PHANTASM NAME: - Deals 6 damage to single enemie in range 5, if hit was succesful then stun it for 1 turn\n
	Overcharge:  Deals 12 damage to single enemie in range 5, if hit was succesful then stun it for 2 turns
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Single In Range","Range":5,"Damage":6,
				"effect_on_success_attack":[
						{"Buffs":[
							{"Name":"Paralisys",
								"Duration":1}
						],
						"Cast":"Phantasm Attacked"},
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Single In Range","Range":5,"Damage":12,
				"effect_on_success_attack":[
						{"Buffs":[
							{"Name":"Paralisys",
								"Duration":2}
						],
						"Cast":"Phantasm Attacked"},
						]
					}
			}
	}
}






func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
