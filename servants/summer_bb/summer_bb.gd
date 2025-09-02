extends Node2D

@onready var players_handler = self.get_parent()
var TTTTTTTTTTTTTTTTT='''
5S-041
(Лунная Клеть)
Мировоззрение: Хаотично-Злая
Класс: Мун Кэнсер
Имя: БиБи (Летняя)
Сила: С (3 очка урона) (Радиус атаки 2)
Выносливость: С (Очки Жизни: 26)
Ловкость: С 
Удача: ЕХ (+3 к выпавшему результату при активации Мгновенной Смерти)
Магия: А++ (Магическая Защита - 7)
Н.Фантазм: ЕХ
Классовые Навыки: 
Эссенция Богини: Союзники стоящие рядом с БиБи в радиусе двух клеток, раз в два хода повышают свою Шкалу Фантазма на одно очко.
Существование За Пределами Домена: Силу БиБи невозможно понизить.
Тот Кто Поглощает Землю: Постоянный иммунитет к дебаффу Горения.
Создание Территории: Биби может захватывать или перестраивать клетки под себя и вокруг себя в радиусе трёх клеток. (Максимальное количество захваченных/перстроенных клеток: 3) Захваченные клетки поднимают все характеристики на один ранг выше, если Биби стоит на них. Перестраивая клетки Биби может перекрывать пути на поле или вовсе их обрезать другим слугам, чтобы они не могли свободно перемещаться.
Изменённые клетки возвращаются к норме через 4 хода. (Куллдаун - 8)
Личные Навыки:
1) Самомодификация (Любовь): ЕХ - Увеличивает свою силу на 3 очка урона на три хода, а также увеличивает шанс критических атак (1 и 6 на втором кубике считаются критической атакой) на три хода.
2) Aurea Pork Poculum: A - Заряжает свою Шкалу Фантазма на 3 очка, восполняет своё здоровье на 8 очков, увеличивает урон от своего фантазма вдвое на три хода, а также даёт себе одно уклонение. (Куллдаун - 7)
3) Безликая Луна: ЕХ - Запоминает свой последний бросок кубиков. На протяжении трёх ходов будет выпадать только тот результат который был последним у БиБи до активации навыка. (Куллдаун - 8)
Небесный Фантазм:
Cursed Cutting Crater (ССС): Наносит всем противникам в радиусе четырёх клеток 5 урона, после чего понижает их Шкалу Фантазма на 2 очко.
Оверчардж: Наносит всем противникам в радиусе четырёх клеток 10 урона, после чего понижает их Шкалу Фантазма на 4 очка.
(Если сила фантазма увеличена вдвое, то при активации ССС Шкала Фантазма противников будет понижаться вдвое больше) 

'''

const default_stats={
	"hp":26,
	"servant_class":"Moon Cancer",
	"ideology":["Chaotic","Evil"],
	"attribute":"Earth",
	"attack_range":2,
	"gender":"Female",
	"attack_power":3,
	"strength":"C",
	"agility":"C",
	"endurance":"C",
	"luck":"EX",
	"magic":{"Rank":"A+","Power":0,"Resistance":7},
	"traits":[
		"Costume-Owning",
		"Divine Spirit", 
		"Divinity", 
		"Existence Outside the Domain", 
		"Giant", 
		"Goddess Servant", 
		"Immune to Pigify", 
		"Mechanical", 
		"Non-Hominidae Servant", 
		"Sakura Series", 
		"Servant", 
		"Summer Mode Servant", 
		"Super Large", 
		"Weak to Enuma Elish"]
}

var servant_class
var ideology
var strength
var attack_range
var attack_power
var agility#ловкость
var endurance#вынослиость
var hp
var luck
#magic power / magic resistance
var magic 
var traits
var gender
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon#="Scythe"
var phantasm_charge=0
var attribute

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
	strength=default_stats["strength"]
	attribute=default_stats["attribute"]
	gender=default_stats["gender"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.

var passive_skills=[
	{
		"Name":"Existence Outside the Domain",
		"Type":"Status",
		"Types":["Buff Positive Effect"],#addes as demonstration
		"Power":0
		},
	{
		"Name":"Nullify Debuff",
		"Display Name":"The One Who Swallows the Earth",#TODO
		"Type":"Status",
		"Types To Block":["Buff Burn"]
	},
	{
		"Name":"Buff In Range",
		"Display Name":"Goddess' Essence",
		"Types":["Buff Positive Effect"],
		"Trigger":"Turns Dividable By Power",
		"Power":2,
		"Effect On Trigger":
			{"Buffs":[
				{"Name":"NP Charge",
					"Duration":0,
					"Power":1}
				],
				"Cast":"self",# except self",
				"Cast Range":2},
	}
]


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":5,
	"Description":"Увеличивает свою силу на 3 очка урона на три хода, а также увеличивает шанс критических атак (1 и 6 на втором кубике считаются критической атакой) на три хода) (Куллдаун 5)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Duration":1.5,
				"Power":3
			},
			{"Name":"Critical Hit Rate Up",
				"Duration":3,
				"Crit Chances":[1,6]
			}
			],
		"Cast":"Self"}
	]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":7,
	"Description":"Заряжает свою Шкалу Фантазма на 3 очка, восполняет своё здоровье на 8 очков, увеличивает урон от своего фантазма вдвое на три хода, а также даёт себе одно уклонение. (Куллдаун - 7)",
	"Effect":[
		{"Buffs":[
			{"Name":"NP Charge",
				"Power":3
			},
			{"Name":"Heal",
				"Power":8
			},
			{"Name":"NP Strength Up X",
				"Duration":3,
				"Power":2
			},
			{"Name":"Evade",
				"Power":1
			},
			],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B+",
	"Cooldown":6,
	"Description":"Запоминает свой последний бросок кубиков. На протяжении трёх ходов будет выпадать только тот результат который был последним у БиБи до активации навыка. (Куллдаун - 8)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"Faceless Moon",
				"Duration":3,
				"Power":2}
			],
			"Cast":"Self"}
		]
},

"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":8,
	"Description":"Создание Территории: Биби может захватывать или перестраивать клетки под себя и вокруг себя в радиусе трёх клеток. (Максимальное количество захваченных/перстроенных клеток: 3) Захваченные клетки поднимают все характеристики на один ранг выше, если Биби стоит на них. Перестраивая клетки Биби может перекрывать пути на поле или вовсе их обрезать другим слугам, чтобы они не могли свободно перемещаться.\nИзменённые клетки возвращаются к норме через 4 хода. (Куллдаун - 8).",
	"Effect":[
	{"Buffs":[
		{"Name":"Field Manipulation",
		"Amount":3,"Range":3,"Config":
			{"Stats Up By":1,
				"Duration":4,
				"Additional":null}
			}
		],
	"Cast":"Self"}
	]
}
}
var phantasms={
	"CCC":{
		#"Type":"All Enemies In Range",
		"Rank":"A",
		"Description":"""Cursed Cutting Crater (ССС): Наносит всем противникам в радиусе четырёх клеток 5 урона, после чего понижает их Шкалу Фантазма на 2 очко.
Оверчардж: Наносит всем противникам в радиусе четырёх клеток 10 урона, после чего понижает их Шкалу Фантазма на 4 очка.
(Если сила фантазма увеличена вдвое, то при активации ССС Шкала Фантазма противников будет понижаться вдвое больше) 
""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"All Enemies In Range","Range":4,"Damage":5,
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Discharge",
								"Power":2}
						],
						"Cast":"Self"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"All Enemies In Range","Range":4,"Damage":10,
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Discharge",
								"Power":4}
						],
						"Cast":"Self"}
						]
					},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
