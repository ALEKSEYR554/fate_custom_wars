extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":26,
	"servant_class":"Caster",
	"ideology":["Lawful","Good"],
	"attack_range":1,#most casters has range=1
	"attack_power":4,#check table info
	"agility":"B",
	"endurance":"C",
	"luck":"C",
	"magic":{"Rank":"C","Power":6,"resistance":3},#check table info
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
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":NAN,#one time skill
	"Description":"Territory Creation: Captures one cell and five cells around it. All captured cells become a territory where Magic damage ignores magical defence (but not sabes's magical resistance). Standing on these cells Caster raises his Phantasm charge by one point once per turn. This skill can be activated only once.",
	"Effect":[
	{"Buffs":[
		{"Name":"Field Creation",
		"Amount":5,"Config":
			{"Owner":Globals.self_peer_id,
				"Np Up Every N Turn":1,
				"Ignore Magical Defence":true,
				"Additional":null}
			}
		],
	"Cast":"Self"}
	]
},

"Class Skill 2":{
	"Type":"Potion Creating",
	"Rank":"B",
	"Cooldown":8,
	"Description":"Item Construction: Caster can create various poisons or potions to restore health. (Max. number of potions/poisons created: 2) (Only one potion/poison can be created per turn)(Cooldown - 8).",
	"Effect":[
		{"Buffs":[
			{"Name":"Potion creation",
			"Potions":
				{
					"Heal Potion":{
						"Description":"Heal Potion: Restores 5 health points and removes all debuffs to yourself or another servant within a two cell radius.",
						"Buff":[
							{"Name":"Heal",
								"Range":2,
								"Power":5}
							]
					},
					"Poison Potion":{
						"Description":"Poison: Affects one servant within a two cell radius with a poison condition and lowers health by 2 points each turn for three turns.",
						"Buff":[
							{"Name":"Poison",
								"Duration":3,
								"Range":2,
								"Power":2,
								"Trigger":"End Turn",
								"Effect On Trigger":"Take Damage By Power"}
							]
					}
				},
			}
			],
		"Cast":"Self"}
		]
	}
}
var phantasms={
	"!!!!!!!!!!!!!!!!!!PHANTASM NAME!!!!!!!!!!!!!!!!!!":{
		"Rank":"A",
		"Description":"""PHANTASM NAME: - Increase damage by 2 times, increase defence by 2 times for 3 turns for self and allies\n
	Overcharge: Increase damage by 2 times, increase defence by 2 times for 5 turns for self and allies
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{"Name":"DEF Up X",
							"Duration":3,
							"Power":2},
						{"Name":"ATK Up X",
							"Duration":3,
							"Power":2}
					],
					"Cast":"All enemies"}
					]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{"Name":"DEF Up X",
							"Duration":3,
							"Power":2},
						{"Name":"ATK Up X",
							"Duration":3,
							"Power":2}
					],
					"Cast":"All enemies"}
					]
				},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
