extends Node2D

@onready var players_handler = self.get_parent()
var TTTTTTTTTTTTTTTTT='''
4S-066
(Япония)
Мировоззрение: Нейтрально-Добрый
Класс: Мун Кэнсер
Имя: Кишинами Хакуно (Девушка)
Сила: С (3 очка урона) (Радиус атаки 3)
Выносливость: С (Очки Жизни: 26)
Ловкость: В- (+1 к выпавшему результату при уклонении)
Удача: В (+1 к выпавшему результату при активации Мгновенной Смерти)
Магия: В+ (Магическая Защита - 4)
Н.Фантазм: ЕХ 
Классовые Навыки:
Код Каст: А - Позволяет использовать эффекты командных заклинаний, предметов, командных кодов или карточек на союзниках.
Лунная Регалия: ЕХ - Если игрок на Хакуно выиграл прошлые войны и его желания всё ещё действуют, то сила Хакуно увеличивается на 1 очко за каждую победу в этом месяце. (Максимум: 3) Этот навык не учитывается, если противником Хакуно является Форэйнер.
Личные Навыки:
1) Перехватный Шах и Мат: ЕХ - Даёт на выбор один бафф из трёх на три хода:
Если Хакуно успешно проводит атаку, то он получает уклонение от одной атаки (этот бафф может сработать 3 раза)
Если Хакуно успешно проводит атаку, то его Шкала Фантазма увеличивается не на одно очко, а на два.
Если Хакуно успешно проводит атаку, то следующая атака получает повышенный шанс на крит (1, 3 и 6 на втором кубике считаются критической атакой) (Куллдаун - 7)
2) Маршут Искристой Бесконечности: ЕХ - Позволяет остановить время в рамках хода Хакуно. Хакуно может пожертвовать одно очко фантазма, чтобы добавить себе один дополнительный шаг. (Не действие, именно дополнительный шаг) (Куллдаун - 0)  (НАВЫК НЕ ТРАТИТ ДЕЙСТВИЙ)
3) C³ Наказание: В+ - Заряжает свою Шкалу Фантазма на 2 очка, а также увеличивает свою силу вдвое против противников с Божественностью. (Куллдаун - 7)
Небесный Фантазм: 
Недействительная Запись - Лунный Якорь: Наносит 4 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.
Оверчардж: Наносит 8 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.

'''



const default_stats={
	"hp":26,
	"servant_class":"Moon Cancer",
	"ideology":["Neutral","Good"],
	"attack_range":3,
	"attack_power":3,
	"agility":"B-",
	"endurance":"C",
	"luck":"B",
	"magic":{"Rank":"B+","Power":0,"resistance":4},
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

var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon#="Scythe"
var phantasm_charge=0

# Called when the node enters the scene tree for the first time.
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
	"Description":"Даёт на выбор один бафф из трёх на три хода:
	Если Хакуно успешно проводит атаку, то он получает уклонение от одной атаки (этот бафф может сработать 3 раза)
	Если Хакуно успешно проводит атаку, то его Шкала Фантазма увеличивается не на одно очко, а на два.
	Если Хакуно успешно проводит атаку, то следующая атака получает повышенный шанс на крит (1, 3 и 6 на втором кубике считаются критической атакой) (Куллдаун - 7)",
	
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
					"Description":"Если Хакуно успешно проводит атаку, то он получает уклонение от одной атаки (этот бафф может сработать 3 раза)"},
		
		"Np up":#mini buff name REQUIED
			{"Buffs":[
				{"Name":"NP gain on Attack",
					"Trigger": "Success Attack",
					"Types":["Buff Positive Effect"],
					"Effect On Trigger":
						{"Buffs":[
							{"Name":"NP Gauge",
								"Duration":0,
								"Power":1}
							],
							"Cast":"Self"},
					"Duration":3,
					"Power":1}
				],
				"Cast":"Self",
				"Description":"Если Хакуно успешно проводит атаку, то его Шкала Фантазма увеличивается не на одно очко, а на два."},
		
		"Crit up":#mini buff name REQUIED
			{"Buffs":[
				{"Name":"Crit gain on Attack",
					"Trigger": "Success Attack",
					"Types":["Buff Positive Effect"],
					"Effect On Trigger":
						{"Buffs":[
							{"Name":"Critical Hit Rate Up",
								"Duration":0,
								"Power":1,
								"Crit Chances":[1,3,6]}
							],
							"Cast":"Self"},
					"Duration":3,
					"Power":1}
				],
				"Cast":"Self",
				"Description":"Если Хакуно успешно проводит атаку, то следующая атака получает повышенный шанс на крит (1, 3 и 6 на втором кубике считаются критической атакой)"}
			}
		}
	]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":0,
	"Description":"Позволяет остановить время в рамках хода Хакуно. Хакуно может пожертвовать одно очко фантазма, чтобы добавить себе один дополнительный шаг. (Не действие, именно дополнительный шаг) (Куллдаун - 0)  (НАВЫК НЕ ТРАТИТ ДЕЙСТВИЙ)",
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
	"Description":"Заряжает свою Шкалу Фантазма на 2 очка, а также увеличивает свою силу вдвое против противников с Божественностью. (Куллдаун - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"NP Gauge",
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
	"Rongominiad":{
		#"Type":"Line",
		"Rank":"A",
		"Description":"""Недействительная Запись - Лунный Якорь: Наносит 4 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.
Оверчардж: Наносит 8 урона одному противнику в любом радиусе и всем остальным противникам находящимся рядом с ним в радиусе трёх клеток. Если атака прошла успешно, то противник парализуется на один ход. Этот фантазм игнорирует абсолютно любую защиту (Даже непробиваемую и если написано, что её невозможно пробить ни при каких условиях), но не способен пробить уклонения.
""",
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





func _on_button_pressed():
	#idk what this does but dont touch
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
