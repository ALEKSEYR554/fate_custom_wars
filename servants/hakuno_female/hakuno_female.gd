extends Node2D

@onready var players_handler = self.get_parent()


const default_stats={
	"hp":26,
	"servant_class":"Moon Cancer",
	"ideology":["Neutral","Good"],
	"gender":"Female",
	"attack_range":3,
	"attack_power":3,
	"attribute":"Human",
	"strength":"C",
	"agility":"B-",
	"endurance":"C",
	"luck":"B",
	"magic":{"Rank":"B+","Power":0,"Resistance":4},
	"traits":["Enuma Elish Nullification",
	"Hominidae Servant", 
	"Humanoid", 
	"Loved One", 
	"Mechanical", 
	"Servant"]
}

var servant_class
var ideology
var attack_range
var attack_power
var agility#ловкость
var endurance#вынослиость
var hp
var luck
#magic power / magic resistance
var magic #["C",0,3]
var traits

var strength
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon#="Scythe"
var phantasm_charge=0
var attribute
var gender
var ascension_stage


var passive_skills=[
	{"Name":"Code Cast",
		"Duration":"Passive",
		"Types":["Buff Positive Effect"],#addes as demonstration
		"Trait":"Divinity",
		"Power":3
		}
]


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":7,
	"Description ID":"First Skill",
	
	"Effect":[
		{"Choose Buff":
			{"Evade":#mini buff name REQUIED
				{"Buffs":[
					{"Name":"Evade gain on Attack",
						"Trigger": "Success Attack",
						"Types":["Buff Positive Effect"],
						"Total Trigger Uses":3,
						"Effect On Trigger":
							{"Buffs":[
								{"Name":"Evade",
									"Duration":0,
									"Power":1}
								],
								"Cast":"Self"},
						"Duration":3,
						"Power":1}
					],
					"Cast":"Self",
					"Description ID":"Evade Buff First Skill"},
		
		"Np up":#mini buff name REQUIED
			{"Buffs":[
				{"Name":"NP gain on Attack",
					"Trigger": "Success Attack",
					"Types":["Buff Positive Effect"],
					"Effect On Trigger":
						{"Buffs":[
							{"Name":"NP Charge",
								"Duration":0,
								"Power":1}
							],
							"Cast":"Self"},
					"Duration":3,
					"Power":1}
				],
				"Cast":"Self",
				"Description ID":"NP Gain Buff First Skill"},
		
		"Crit up":#mini buff name REQUIED
			{"Buffs":[
				{"Name":"Crit gain on Attack",
					"Trigger": "Success Attack",
					"Types":["Buff Positive Effect"],
					"Effect On Trigger":
						{"Buffs":[
							{"Name":"Critical Hit Rate Up",
								"Duration":1,
								"Power":1,
								"Crit Chances":[1,3,6]}
							],
							"Cast":"Self"},
					"Duration":3,
					"Power":1}
				],
				"Cast":"Self",
				"Description ID":"Crit Buff First Skill"}
			}
		}
	]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":0,
	"Description ID":"Second Skill",
	"Consume Action":false,
	"Effect":[
		{"Buffs":[
			{"Name":"Additional Move",
				"Duration":1,
				"Power":1
			}
			],
		"Cost":{
				"Currency":"NP",
				"Amount":1
				},
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B+",
	"Cooldown":7,
	"Description ID":"Third Skill",
	
	"Effect":[
		{"Buffs":[
			{"Name":"NP Charge",
				"Duration":3,
				"Power":2},
			{"Name":"ATK UP X Against Trait",
				"Duration":3,
				"Power":2,
				"Trait":"Divinity"}
			],
			"Cast":"Self"}
		]
},

}
var phantasms={
	"Void Record":{
		"Rank":"EX",
		"Description ID":'Void Record',
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Bomb","Range":999,"AOE_Range":3,"Damage":4,
				"Ignore":["Buff Increase Defence","Defence"],
				"effect_on_success_attack":[
						{"Buffs":[
							{"Name":"Paralysis",
								"Duration":1,
								"Power":1}
						],
						"Cast":"Phantasm Attacked"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Bomb","Range":999,"AOE_Range":3,"Damage":8,
				"Ignore":["Buff Increase Defence","Defence"],
				"effect_on_success_attack":[
						{"Buffs":[
							{"Name":"Paralysis",
								"Duration":1,
								"Power":1}
						],
						"Cast":"Phantasm Attacked"}
						]
					},
		}
	}
}

var translation={
	"ru":{
		"Second Skill":"Позволяет остановить время в рамках хода Хакуно. Хакуно может пожертвовать одно очко фантазма, чтобы добавить себе один дополнительный шаг. (Не действие, именно дополнительный шаг) (Куллдаун - 0)  (НАВЫК НЕ ТРАТИТ ДЕЙСТВИЙ)",
		"First Skill":"Даёт на выбор один бафф из трёх на три хода:\nЕсли Хакуно успешно проводит атаку, то он получает уклонение от одной атаки (этот бафф может сработать 3 раза)\nЕсли Хакуно успешно проводит атаку, то его Шкала Фантазма увеличивается не на одно очко, а на два.\nЕсли Хакуно успешно проводит атаку, то следующая атака получает повышенный шанс на крит (1, 3 и 6 на втором кубике считаются критической атакой) (Куллдаун - 7)",
		"Third Skill":"Заряжает свою Шкалу Фантазма на 2 очка, а также увеличивает свою силу вдвое против противников с Божественностью. (Куллдаун - 7)",
		"Void Record":"Недействительная Запись - Лунный Якорь: Наносит 4 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.\nОверчардж: Наносит 8 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.",
		"Evade Buff First Skill":"Если Хакуно успешно проводит атаку, то он получает уклонение от одной атаки (этот бафф может сработать 3 раза)",
		"NP Gain Buff First Skill":"Если Хакуно успешно проводит атаку, то его Шкала Фантазма увеличивается не на одно очко, а на два.",
		"Crit Buff First Skill":"Если Хакуно успешно проводит атаку, то следующая атака получает повышенный шанс на крит (1, 3 и 6 на втором кубике считаются критической атакой)"
		
	},
	"en":{
		"Second Skill":"Allows to stop time within Hakuno's turn. Hakuno can sacrifice one Phantasm point to add one extra step to himself. (Not an action, but an extra step) (Cooldown - 0) (SKILL DOES NOT SPEND ACTIONS)",
		"First Skill":"Grants a choice of one buff out of three for three turns:\nIf Hakuno successfully lands an attack, he gains evasion from one attack (this buff can activate 3 times)\nIf Hakuno successfully lands an attack, his Phantasm Gauge increases by two points instead of one.\nIf Hakuno successfully lands an attack, the next attack gains an increased critical chance (1, 3, and 6 on the second die count as a critical attack) (Cooldown - 7)",
		"Third Skill":"Charges own Phantasm Gauge by 2 points, and also doubles own strength against opponents with Divinity. (Cooldown - 7)",
		"Void Record":"Void Record - Lunar Anchor: Deals 4 damage to one opponent within any radius and all other opponents near him within a radius of three cells. If the attack is successful, the opponent is paralyzed for one turn. This Phantasm ignores absolutely any defense (Even impenetrable and if it is written that it is impossible to penetrate under any conditions), but cannot pierce evasion.\nOvercharge: Deals 8 damage to one opponent within any radius and all other opponents near him within a radius of three cells. If the attack is successful, the opponent is paralyzed for one turn. This Phantasm ignores absolutely any defense (Even impenetrable and if it is written that it is impossible to penetrate under any conditions), but cannot pierce evasion.",
		"Evade Buff First Skill":"If Hakuno successfully lands an attack, he gains evasion from one attack (this buff can activate 3 times)",
		"NP Gain Buff First Skill":"If Hakuno successfully lands an attack, his Phantasm Gauge increases by two points instead of one.",
		"Crit Buff First Skill":"If Hakuno successfully lands an attack, the next attack gains an increased critical chance (1, 3, and 6 on the second die count as a critical attack)"
	}
}
