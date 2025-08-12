extends Node2D

@onready var players_handler = self.get_parent()
var TTTTTTTTTTTTTTTTT='''
4S-061
(Япония)
Мировоззрение: Добропорядочно-Добрая
Класс: Ассасин
Имя: Грей
Сила: В (4 очка урона)
Выносливость: С (Очки Жизни: 26)
Ловкость: B (+1 к выпавшему результату при уклонении)
Удача: C
Магия: C (Магическая Защита - 3)
Н.Фантазм: A+
Классовые Навыки:
(Смотреть в ветке)
Личные Навыки: 
1) Антидуховное сражение: B - Увеличивает свою атаку на 3, увеличивает урон по призываемым существам вдвое на три хода. (Куллдаун - 7)
2) Высвобождение запечатанных цепей: C - Увеличивает свой урон вдвое на один ход, а так же получает неуязвимость на одну атаку на один ход (Куллдаун - 6)
3) Защита конца света: В - Заряжает свою шкалу фантазма на одно очко, а также даёт себе иммунитет к дебаффам на три хода. (Куллдаун - 6)
Небесный Фантазм:
1) Ронгоминиад: - Наносит 6 урона всем противникам на одной линии в радиусе 5 игнорируя защитные баффы и неуязвимость, заряжает шкалу фантазма на одно очко
Оверчардж: Наносит 12 урона всем противникам на одной линии в радиусе 5 игнорируя защитные баффы и неуязвимость, после понижает им защиту на 2 на три хода, заряжает себе шкалу фантазма на одно очко
2) Великий Щит: - Теряет возможность атаковать, повышает себе защиту вдвое и принуждает всех противников атаковать себя на протяжении 2 ходов, по окончании баффа наносит весь полученный урон всем противникам в радиусе двух клеток
Оверчардж: - Теряет возможность атаковать, повышает себе защиту вдвое и принуждает всех противников атаковать себя на протяжении 4 ходов, по окончании баффа наносит весь полученный урон всем противникам в радиусе двух клеток
3) Мифология Ронгоминиады: - Наносит 6 урона одному противнику в радиусе 4 клеток. Если противником является псевдо-слуга то его сила понижается вдвое на 5 ходов
Оверчардж: отсутствует
'''



const default_stats={
	"hp":26,
	"servant_class":"Assasin",
	"ideology":["Lawful","Good"],
	"gender":"Female",
	"attack_range":1,
	"attack_power":4,
	"strength":"B",
	"agility":"B",
	"attribute":"Human",
	"endurance":"C",
	"luck":"C",
	"magic":{"Rank":"C","Power":0,"Resistance":3},
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
var agility#ловкость
var endurance#вынослиость
var hp
var luck
#magic power / magic resistance
var magic #["C",0,3]
var traits=[]
var strength
var gender
var buffs=[{"Name":"Magical Damage Get + Attack",
				"Trigger": "Magical Damage Taken",
				"Effect On Trigger":
					{"Buffs":[
						{"Name":"ATK Up",
							"Duration":2,
							"Power":1}
						],
						"Cast":"Self"},
				"Type":"Passive",
				"Power":1}]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"
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

var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":7,
	"Description":"Увеличивает свою атаку на 3, увеличивает урон по призываемым существам вдвое на три хода. (Куллдаун - 7)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up",
				"Duration":3,
				"Power":3},
			{"Name":"ATK UP X Against Trait",
				"Duration":3,
				"Power":2,
				"Trait":"Summonable"}
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":6,
	"Description":"Высвобождение запечатанных цепей: C - Увеличивает свой урон вдвое на один ход, а так же получает неуязвимость на одну атаку на один ход (Куллдаун - 6)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"ATK Up X",
				"Duration":1,
				"Power":2},
			{"Name":"Invincible",
				"Duration":1,
				"Hit Times":1}
				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Защита конца света: В - Заряжает свою шкалу фантазма на одно очко, а также даёт себе иммунитет к дебаффам на три хода. (Куллдаун - 6)",
	
	"Effect":[
		{"Buffs":[
			{"Name":"Charge NP",
				"Duration":1,
				"Power":1},
			{"Name":"Debuff Immune",
				"Duration":1,
				"Power":3}
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
				"Type":"Passive",
				"Power":1},
		},
		"Hammer":{
			"Description":"радиус 1, урон 6, пробивает защиту и защитные баффы, но за ход можно будет проводить только одну атаку.",
			"Is One Hit Per Turn":true,"Damage":6,"Range":1,"Buff":[
				{"Name":"Ignore DEF Buffs",
					"Type":"Passive",
					"Power":1},
				{"Name":"Ignore Defence",
					"Type":"Passive",
					"Power":1},
			]
		},
		"Boomerang":{
			"Description":"Радиус 5, урон 0, но возможно повысить баффами, при успешной атаке может притянуть к себе противников на любое количество клеток",
			"Is One Hit Per Turn":false,"Damage":0,"Range":5,"Buff":
				{"Name":"pull enemies on attack",
				"Type":"Passive",
				"Trigger":"Success Attack",
				"Effect On Trigger":"pull enemies on attack"}
		},
		"Bow":{
			"Description":"Радиус 3, урон 2",
			"Is One Hit Per Turn":false,"Damage":2,"Range":2
		},
		"Alebard":{
			"Description":"Радиус 2, урон 3, при владении алебардой, ловкость Грей считается B++",
			"Is One Hit Per Turn":false,"Damage":3,"Range":2,"Buff":
				{"Name":"Agility Set",
				"Type":"Passive",
				"Power":"B++"}
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
							{"Name":"NP Charge",
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
							{"Name":"NP Charge",
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
