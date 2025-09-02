extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":28,
	"servant_class":"Saber",
	"ideology":["Lawful","Good"],
	"gender":"Male",
	"attack_range":1,#most sabers has range=1
	"attack_power":5,#check table info
	"strength":"A",
	"agility":"B",
	"endurance":"B",
	"luck":"B",
	"magic":{"Rank":"B","Power":0,"Resistance":4},#check table info
	"traits":["Divinity", "Hominidae Servant", "Humanoid", "King", "Loved One", "Riding", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
}
"""
	4S-069
	(Индия)
	Мировоззрение: Добропорядочно-Добрый
	Имя: Рамаяна (Рама)
	Класс: Сэйбер
	Сила: А (5 очков урона)
	Выносливость: B (Очки Жизни: 28)
	Ловкость: B (+1 к выпавшему результату при уклонении)
	Удача: B
	Магия: B (Магическая Защита - 4)
	Н.Фантазм: A
	Классовые Навыки:
	Магическое Сопротивление: Вдвое понижает получаемый Магический Урон,
	Верховая Езда: Если Рама получит транспорт, то он сможет передвигаться на две клетки больше. (Дополнительные шаги не учитываются остальными действиями),
	Божественность: Увеличивает свою силу на 3 очка (Куллдаун - 8),
	Личные Навыки:
	1) Благословение боевых искусств: А - Увеличивает урон критических атак втрое на одну критическую атаку до конца следующего хода. (Куллдаун - 9)
	2) Харизма: В - Увеличивает силу себе и союзникам на 2 очка на три хода. (Куллдаун - 6)
	3) Мечта о воссоединении: ЕХ - Даёт себе одно Воскрешение (Воскрешает с 8 ОЗ) на три хода, восполняет своё здоровье на 9 очков, восполняет свою шкалу фантазма на 2 очка, а так же увеличивает шанс критических атак (2 на втором кубике считаются критической атакой) (Куллдаун - 6)
	Небесный Фантазм:
	Брахмастра: Наносит 8 урона одному противнику на расстоянии шести клеток, если противник Демонический, то урон увеличивается на 3 очка, понижает их защиту на 2 очка на три хода, если противник Демонический, то понижает его шкалу фантазма на одно очко.
	Оверчардж: Наносит 16 урона одному противнику на расстоянии шести клеток, если противник Демонический, то урон увеличивается на 3 очка, понижает их защиту на 2 очка на пять ходов, если противник Демонический, то понижает его шкалу фантазма на два очка. 
"""



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
var gender
var buffs=[]
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"#if character doen't have weapon then dont touch it
var phantasm_charge=0
var strength
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
	gender=default_stats["gender"]
	strength=default_stats["strength"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.



var passive_skills=[
	{
		"Name":"Magic Resistance",#ALL SABERS HAS IT
		"Type":"Status",
		"Types":["Buff Positive Effect"],#addes as demonstration
		"Power":0
	},
	{
		"Name":"Riding",#currently useless
		"Display Name":"Surfing",#TODO
		"Type":"Status"
	}
]


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":9,
	"Description":"Increases critical attack damage by three times per critical attack until the end of the next turn. (Cooldown: 9)",
	
	"Effect":[
		{"Buffs":[
			{
				"Name":"Critical Strength Up X",
				"Duration":1.5,
				"Power":3
			}
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Increases the strength for yourself and allies by 2 points for three turns. (Cooldown: 6)",
	"Effect":[
		{"Buffs":[
			{
				"Name":"ATK Up",
				"Duration":3,
				"Power":2
			}
			],
			"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Gives yourself one Guts (Resurrects with 8 HP) for three turns, heal health by 9 points, charge Phantasm by 2 points, and increases the chance of critical attacks (2 on the second dice counts as a critical attack) (Cooldown - 6).",
	"Effect":[
		{"Buffs":[
			{
				"Name":"Guts",
				"Duration":3,
				"HP To Recover":8
			},
			{
				"Name":"Heal",
				"Power":9
			},
			{
				"Name":"Critical Hit Rate Up",
				"Duration":3,
				"Crit Chances":[2]
			},
			],
			"Cast":"Self"}
		]
},

"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":8,
	"Description":"Divinity: Increases your strength by 3 points (Cooldown - 8),",
	"Effect":[
		{"Buffs":[
			{
				"Name":"ATK Up",
				"Duration":3,
				"HP To Recover":3
			}
			],
			"Cast":"Self"}
		]
}
}
var phantasms={
	"Brahmastra":{
		"Rank":"A",
		"Description":"""Brahmastra: - Deals 8 damage to one enemy within six cells, if the enemy is Demonic, the damage is increased by 3 points, lowers their defense by 2 points for three turns, if the enemy is Demonic, it lowers their Phantasm gauge by one point\n
Overcharge: Deals 16 damage to one enemy within six cells, if the enemy is Demonic, the damage is increased by 3 points, lowers their defense by 2 points for five turns, if the enemy is Demonic, it lowers their Phantasm gauge by two points.
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Line","Range":6,"Damage":8,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Trait",
						"Trait":"Demonic",
						"Power":3}
					],
				"effect_after_attack":
					[
						{"Buffs":[
							{"Name":"Def Down",
								"Duration":3,
								"Power":3}
						],
						"Cast":"Phantasm Attacked"},
						{
							"Buffs":[
								{
									"Name":"NP Discharge",
									"Power":1
								}
							],
							"Cast":"Phantasm Attacked",
							"Cast Condition":{
								"Condition":"Trait",
								"Trait":"Demonic"
							}
						}
					]
				},
			"Overcharge":
				{"Cost":12,"Attack Type":"Line","Range":6,"Damage":16,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Trait",
						"Trait":"Demonic",
						"Power":3}
					],
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"Def Down",
								"Duration":3,
								"Power":3}
						],
						"Cast":"Phantasm Attacked"},
						{"Buffs":[
							{"Name":"NP Discharge",
								"Power":1}
						],
						"Cast":"Phantasm Attacked",
						"Cast Condition":{
							"Condition":"Trait",
							"Trait":"Demonic"
						}
						}
						]
					},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
