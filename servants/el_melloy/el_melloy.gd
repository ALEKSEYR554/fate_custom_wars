extends Node2D
@onready var players_handler = self.get_parent()
var TTT='''
5S-071
(Китай)
Мировоззрение: Нейтрально-Добрый
Класс: Кастер
Имя: Чжугэ Лян (Лорд Эль-Меллой II)
Сила: Е (1 очко урона)
Выносливость: Е (Очки Жизни: 15)
Ловкость: D
Удача: В+ (+1 к выпавшему результату при активации Мгновенной Смерти)
Магия: А+ (Магическая Защита - 6 / Магический урон - 12)
Н.Фантазм: А
Классовые Навыки:
Создание Территории: Захватывает одну клетку и пять клеток вокруг неё. Все захваченные клетки становятся территорией на которой Магический урон никогда не понижается.Стоя на этих клетках Кастер поднимает свою шкалу фантазма на одну единицу раз в ход. Этот навык можно активировать лишь один раз.
Создание Предметов: Кастер может создавать различные яды или зелья для восстановления здоровья. (Макс.количество созданных зелий/ядов: 2 штуки)
(Яд: Накладывает на одного слугу в радиусе двух клеток состояние отравления и понижает здоровье на 1 очко каждый ход на протяжении трёх ходов.)
(Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток)
(За ход можно сделать только одно зелье/яд)
(Куллдаун - 8) 
Личные Навыки:
1) Проницательный Взгляд: А - Увеличивает вдвое наносимый критический урон вдвое себе или одному союзнику на три хода, а также восполняет Шкалу Фантазма на 2 очка. (Куллдаун - 7)
2) Совет Стратега: А+ - Увеличивает себе и союзникам защиту вдвое на три хода, а также понижает сверху получаемый урон на 2 очка пока действует этот навык + восполняет Шкалу Фантазма на 1 очко себе и союзникам. (Куллдаун - 7)
3) Командование Стратега: А+ - Увеличивает себе и союзникам силу на 3 очка на три хода, а также восполняет Шкалу Фантазма на 1 очко. (Куллдаун - 7)
Небесный Фантазм:
Unreturning Formation - Понижает всем противникам Шкалу Фантазма на одно очко, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 1 урона в конце хода) на пять ходов.
Оверчардж: Понижает всем противникам Шкалу Фантазма на два очка, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 2 урона в конце хода) на пять ходов.
'''

const default_stats={
	"hp":15,
	"servant_class":"Caster",
	"ideology":["Neutral","Good"],
	"attack_range":1,
	"attack_power":1,
	"agility":"D",
	"endurance":"E",
	"luck":"B+",
	"magic":{"Rank":"A+","Power":6,"resistance":12},
	"traits":[
		"Hominidae Servant",
		"Humanoid",
		"Living Human",
		"Loved One",
		"Pseudo-Servant",
		"Servant",
		"Seven Knights Servant",
		"Weak to Enuma Elish"]
}

var servant_class="Caster"
var ideology=["Balanced","Neutral"]
var attack_range=1
var attack_power=1
var agility="D"#ловкость
var endurance="E"#вынослиость
var hp=15
var luck="B+"
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
#magic power / magic resistance
var magic=["A+",6,12]
var additional_moves=0
var additional_attack=0
var traits
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

var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":7,
	"Description":"Проницательный Взгляд: А - Увеличивает вдвое наносимый критический урон вдвое себе или одному союзнику на три хода, а также восполняет Шкалу Фантазма на 2 очка. (Куллдаун - 7)",
	"Effect":[
	{"Buffs":[
		{"Name":"Critical Strength Up X",
			"Duration":3,
			"Power":2},
		{"Name":"NP Gauge",
			"Duration":3,
			"Power":2},
		],
	"Cast":"single allie"}
]},
"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A+",
	"Cooldown":7,
	"Description":"Совет Стратега: А+ - Увеличивает себе и союзникам защиту вдвое на три хода, а также понижает сверху получаемый урон на 2 очка пока действует этот навык + восполняет Шкалу Фантазма на 1 очко себе и союзникам. (Куллдаун - 7)",
	"Effect":[
		{"Buffs":[
			{"Name":"Def Up X",
				"Duration":3,
				"Power":2},
			{"Name":"Def Up",
				"Duration":3,
				"Power":2},
			{"Name":"NP Gauge",
				"Duration":3,
				"Power":1}
			],
		"Cast":"All allies"}
		]
},
"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"A+",
	"Cooldown":7,
	"Description":"Командование Стратега: А+ - Увеличивает себе и союзникам силу на 3 очка на три хода, а также восполняет Шкалу Фантазма на 1 очко. (Куллдаун - 7)",
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Duration":3,
				"Power":3},
			{"Name":"NP Gauge",
				"Duration":1,
				"Power":1}
			],
		"Cast":"All allies"}
	]
},
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":NAN,
	"Description":"Создание Территории: Захватывает одну клетку и пять клеток вокруг неё. Все захваченные клетки становятся территорией на которой Магический урон никогда не понижается. Стоя на этих клетках Кастер поднимает свою шкалу фантазма на одну единицу раз в ход. Этот навык можно активировать лишь один раз.",
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
	]},
"Class Skill 2":{
	"Type":"Potion Creating",
	"Rank":"B",
	"Cooldown":8,
	"Description":"Создание Предметов: Кастер может создавать различные яды или зелья для восстановления здоровья. (Макс.количество созданных зелий/ядов: 2 штуки) (За ход можно сделать только одно зелье/яд)(Куллдаун - 8)",
	"Effect":[
		{"Buffs":[
			{"Name":"Potion creation",
			"Potions":
				{
					"Heal Potion":{
						"Description":"Зелье лечения: Восполняет 5 очков здоровья, а также снимает все дебаффы себе или другому слуге в радиусе двух клеток",
						"Buff":[
							{"Name":"Heal",
								"Range":2,
								"Power":5}
							]
					},
					"Poison Potion":{
						"Description":"Яд: Накладывает на одного слугу в радиусе двух клеток состояние отравления и понижает здоровье на 1 очко каждый ход на протяжении трёх ходов.",
						"Buff":[
							{"Name":"Poison",
								"Duration":3,
								"Range":2,
								"Power":1,
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

	#Unreturning Formation - Понижает всем противникам Шкалу Фантазма на одно очко, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 1 урона в конце хода) на пять ходов.
	#Оверчардж: Понижает всем противникам Шкалу Фантазма на два очка, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 2 урона в конце хода) на пять ходов.

var phantasms={
	"Unreturning Formation":{
		"Type":"Buff Granting",
		"Rank":"A",
		"Description":"""Понижает всем противникам Шкалу Фантазма на одно очко, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 1 урона в конце хода) на пять ходов.\n
		Оверчардж: Понижает всем противникам Шкалу Фантазма на два очка, понижает им защиту вдвое на три хода, после чего бросает кубик вместе с другими игроками: Если у противников выпавший результат ниже чем у Вэйвера, то они парализуются на один ход и получают дебафф Проклятья (Наносит 2 урона в конце хода) на пять ходов.""",
		"Overcharges":{"Default":
			{"Cost":6,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{"Name":"Discharge NP",
							"Duration":3,
							"Power":1},
						{"Name":"Def Down X",
							"Duration":3,
							"Power":2}
					],
					"Cast":"All enemies"},
					
					{"Buffs":[
						{"Name":"Roll dice for effect",
							"Duration":3,
							"Power":1,
							"Buff To Add":
								[{"Name":"Paralysis",
									"Duration":1
									},
								{"Name":"Curse",
										"Duration":5,
										"Power":2,
										"Trigger":"end turn"
										},
									
									]}
						],
					"Cast":"All enemies"}
					]},
		"Overcharge":
			{"Cost":12,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{"Name":"Discharge NP",
							"Duration":3,
							"Power":2},
						{"Name":"Def Down X",
							"Duration":3,
							"Power":2}
					],
					"Cast":"All enemies"},
					
					{"Buffs":[
						{"Name":"Roll dice for effect",
							"Duration":3,
							"Power":1,
							"Buff To Add":
								[{"Name":"Paralysis",
									"Duration":1
									},
								{"Name":"Curse",
										"Duration":5,
										"Power":2,
										"Trigger":"end turn"
										}]
								}
						],
					"Cast":"All enemies"}
					]}
		}
	}
}


func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
