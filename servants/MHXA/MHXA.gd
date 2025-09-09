extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":38,
	"servant_class":"Berserker",
	"ideology":["Neutral","Evil"],
	"gender":"Female",
	"attribute":"Star",
	"attack_range":1,#most berserkers has range=1
	"attack_power":5,#check table info
	"strength":"A",
	"agility":"B",
	"endurance":"B",
	"luck":"C",
	"magic":{"Rank":"A+","Power":0,"Resistance":6},#check table info
	"traits":["Arthur", "Artoria Face", "Dragon", "Enuma Elish Nullification", "Hominidae Servant", "Humanoid", "King", "Round Table Knight", "Servant", "Seven Knights Servant", "Spaceflight-able Servant"]
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

var passive_skills=[
	{"Name":"Buff In Range",
		"Display Name":"Altereactor",
		"Types":["Buff Positive Effect"],
		"Trigger":"Turns Dividable By Power",
		"Power":2,
		"Effect On Trigger":
			{"Buffs":[
				{"Name":"NP Charge",
					"Duration":0,
					"Power":1}
				],
				"Cast":"self"},
	}
]
var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":7,
	"Description":"Бесконечная Каштановая Паста: ЕХ - Восполняет своё здоровье по 7 очков, после чего восполняет своё здоровье на протяжении трёх ходов по 4 очка, а также увеличивает силу на 3 очка на три удара и на три хода. . (Cooldown - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Trigger": "Success Attack",
				"Types":["Buff Positive Effect"],
				"Total Trigger Uses":3,
				"Duration":3,
				"Power":3},
			{"Name":"Heal",
				"Power":7},
			{"Name":"Restore HP Each Turn",
				"Types":["Buff Positive Effect","Buff Hp Recovery Per Turn"],
				"Duration":3,
				"Trigger": "End Turn",
				"Effect On Trigger":
					{"Buffs":[
						{"Name":"Heal",
							"Power":4}
						],
						"Cast":"Self"
					}}
			],
		"Cast":"Self"
		},
	]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"C+",
	"Cooldown":9,
	"Description":"Клинок Мгновенно Вылезший из Тьмы: С+ - Увеличивает свою ловкость (Выпадаемый результат при уклонении будет выше на один) на три хода, а также увеличивает шанс критических атак (1 и 6 на втором кубике считаются критической атакой) на три хода. (Куллдаун - 9)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"Dice +",
				"Action":"Evade",
				"Duration":3,
				"Power":1#1 point
			},
			{"Name":"Critical Hit Rate Up",
				"Crit Chances":[1,6],
				"Duration":3
			}
				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":7,
	"Description":"Невидимая Рука Правителя: С - Увеличивает себе и своим союзникам силу на 2 очка на три хода, а также увеличивает им шанс критических атак (1 и 6 на втором кубике считается критической атакой) на три хода. (Куллдаун - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Duration":3,
				"Power":2},
			{"Name":"Critical Hit Rate Up",
				"Crit Chances":[1,6],
				"Duration":3}
			],
			"Cast":"All Allies"}
		]
},
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":15,
	"Description":"Увеличивает силу вдвое, но теряется возможность использовать больше одного навыка. (Нельзя активировать во время активных навыков) (Куллдаун - 15)",
	"Effect":[
	{"Buffs":[
		{"Name":"Madness Enhancement",
		"Duration":3,
		"Can Use 1 Skill":true,
		"Power":2}
		],
	"Cast":"Self"}
	]}
}

var phantasms={
	"Cross Calibur":{
		"Rank":"EX",
		"Description":"""Кросс-Калибур: Наносит 7 урона одному противнику в радиусе трёх клеток. Если противник Сэйбер, то наносимый урон увеличивается на 3 очка. Если Противник имеет Добропорядочное Мировоззрение, то наносимый урон увеличивается на 3.
Оверчардж: Наносит 14 урона одному противнику в радиусе трёх клеток. Если противник Сэйбер, то наносимый урон увеличивается на 3 очка. Если Противник имеет Добропорядочное Мировоззрение, то наносимый урон увеличивается на 3. 
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Single In Range","Range":3,"Damage":7,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Class",
						"Class":"Saber",
						"Power":3},
					{"Name":"ATK Up Against Alignment",
						"Alignment":"Good",
						"Power":3},
					]
				},
			"Overcharge":
				{"Cost":12,"Attack Type":"Single In Range","Range":3,"Damage":14,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Class",
						"Class":"Saber",
						"Power":3},
					{"Name":"ATK Up Against Alignment",
						"Alignment":"Good",
						"Power":3},
					]
				},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
