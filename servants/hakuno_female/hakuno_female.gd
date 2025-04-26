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
	"Cooldown":6,
	"Description":"Заряжает свою Шкалу Фантазма на 2 очка, а также увеличивает свою силу вдвое против противников с Божественностью. (Куллдаун - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"NP Gauge",
				"Duration":3,
				"Power":2},
			#{"Name":"ATK UP X Against Trait",
			#	"Duration":3,
			#	"Power":2,
			#	"Trait":"Divinity"}
			],
			"Cast":"Self"}
		]
},

"Class Skill 1":{
	"Type":"Weapon Change",
	"Rank":"UNIQ",
	"Cooldown":0,
	"Description":"Владеет Оддом который может транформироваться в оружия (Куллдаун - 8, однако, если оружие нужно снять, то Куллдаун игнорируется)",
	"free_unequip":true,
	"weapons":{#first is base weapon
		"Scythe":{
			"Description":"(Стандарное) радиус 1 стандарт урон, магическая защита - 6, при получении магического урона увеличивает себе силу на 1 до конца следующего хода",
			"Is One Hit Per Turn":false,"Damage":4,"Range":1,"Buff":
				{"Name":"Magical Damage Get + Attack",
				"Trigger": "Magical Damage Taken",
				"Effect On Trigger":
					{"Buffs":[
						{"Name":"ATK Up",
							"Duration":2,
							"Power":1}
						],
						"Cast":"Self"},
				"Duration":"Passive",
				"Power":1},
		},
		"Hammer":{
			"Description":"радиус 1, урон 6, пробивает защиту и защитные баффы, но за ход можно будет проводить только одну атаку.",
			"Is One Hit Per Turn":true,"Damage":6,"Range":1,"Buff":[
				{"Name":"Ignore DEF Buffs",
					"Duration":"Passive",
					"Power":1},
				{"Name":"Ignore Defence",
					"Duration":"Passive",
					"Power":1},
			]
		},
		"Boomerang":{
			"Description":"Радиус 5, урон 0, но возможно повысить баффами, при успешной атаке может притянуть к себе противников на любое количество клеток",
			"Is One Hit Per Turn":false,"Damage":0,"Range":5,"Buff":
				{"Name":"pull enemies on attack",
				"Duration":"Passive",
				"Trigger":"Success Attack",
				"Effect On Trigger":"pull enemies on attack"}
		},
		"Bow":{
			"Description":"Радиус 3, урон 2",
			"Is One Hit Per Turn":false,"Damage":2,"Range":2
		},
		"Alebard":{
			"Description":"Радиус 2, урон 3, при владении алебардой, ловкость Грей считается B++",
			"Is One Hit Per Turn":false,"Damage":3,"Range":2
		}
	}
}
}
var phantasms={
	"Rongominiad":{
		"Type":"Line",
		"Rank":"A",
		"Description":"""Ронгоминиад: - Наносит 6 урона всем противникам на одной линии в радиусе 5 игнорируя защиту и неуязвимость, заряжает шкалу фантазма на одно очко\n
Оверчардж: Наносит 12 урона всем противникам на одной линии в радиусе 5 игнорируя защиту и неуязвимость, после понижает им защиту на 2 на три хода, заряжает себе шкалу фантазма на одно очко
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
