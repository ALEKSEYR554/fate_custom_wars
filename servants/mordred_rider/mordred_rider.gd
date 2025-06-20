extends Node2D

@onready var players_handler = self.get_parent()

"""
4S-071
(Англия)
Мировоззрение: Хаотично Добрая
Имя: Мордред
Класс: Райдер
Сила: C (3 очка урона)
Выносливость: B (Очки Жизни: 26)
Ловкость: A+ (+2 к выпавшему результату при уклонении)
Удача: А (+2 к выпавшему результату при активации Мгновенной Смерти)
Магия: B (Магическая Защита - 5)
Н.Фантазм: A
Классовые Навыки:
Сёрфинг - Если Мордред получит транспорт, то она сможет передвигаться на две клетки больше.,
Личные Навыки:
1) Серулеанская поездка: А - Увеличивает свою силу на 3 очков на три хода. (Куллдаун - 5)
2) Сальто родео: A+ - Даёт себе гарантированные уклонение до конца следующего хода. Повышает себе шанс критических атак (1,6 на втором кубике считаются критической атакой) на три хода (Куллдаун - 7)
3) Вечное лето: ЕХ - Даёт себе одно Воскрешение (Воскрешает с 2 ОЗ) на три хода. А так же заряжает свою шкалу фантазма на 2 очка (Куллдаун - 7)
Небесный Фантазм:
1) Катание верхом на Prydwen: Делает рывок на 6 клеток и наносит всем пересеченным противникам 7 урона. После чего снимает с них одно очко фантазма.
Оверчардж: Делает рывок на 6 клеток и наносит всем пересеченным противникам 14 урона. После чего снимает с них два очка фантазма.

"""



const default_stats={
	"hp":26,
	"servant_class":"Rider",
	"ideology":["Chaotic","Good"],
	"gender":"Female",
	"attack_range":1,#most riders has range=1
	"attack_power":3,#check table info
	"strength":"C",
	"attribute":"Earth",
	"agility":"A+",
	"endurance":"B",
	"luck":"A",
	"magic":{"Rank":"B","Power":0,"resistance":5},#check table info
	"traits":["Artoria Face",
        "Dragon", 
        "Hominidae Servant", 
        "Humanoid", 
        "Round Table Knight", 
        "Servant", 
        "Seven Knights Servant", "Summer Mode Servant", "Weak to Enuma Elish"]
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
var gender

var buffs=[]
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"#if character doen't have weapon then dont touch it
var phantasm_charge=0
var attribute
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
	attribute=default_stats["attribute"]
	gender=default_stats["gender"]
	strength=default_stats["strength"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.


var passive_skills=[
	{"Name":"Riding",#currently useless
		"Display Name":"Surfing",#TODO
		"Type":"Status"
	}
]



var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":5,
	"Description":"Increases self damage by 3 for 3 turns. (Cooldown - 5)",
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
	"Rank":"A+",
	"Cooldown":7,
	"Description":"Gives herself guaranteed evasion until the end of your next turn. Increases the chance of critical attacks (1,6 on the second dice is considered a critical attack) for three turns (Cooldown - 7).",
	"Effect":[
		{"Buffs":[
			{
                "Name":"Evade",
				"Duration":1.5
            },
            {
                "Name":"Critical Hit Rate Up",
                "Duration":3,
                "Crit Chances":[1,6]
            }

				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":7,
	"Description":"Gives herself one Guts (Revives with 2 HP) for three turns. Then charges her Phantasm by 2 points (Cooldown - 7).",
	
	"Effect":[
		{"Buffs":[
			{
                "Name":"Guts",
				"Duration":3,
				"HP To Recover":2
            },
            {
                "Name":"NP Charge",
				"Power":2
            },
			],
			"Cast":"Self"}
		]
},

}
var phantasms={
	"Prydwen Tube Riding":{
		"Rank":"A",
		"Description":"""Prydwen Tube Riding: - Deals 6 damage to all enemies on one line in 5 range ignoring defence and defencive buffs. Then charges self NP bar by 1 point\n
	Overcharge: Deals 12 damage to all enemies on one line in 5 range ignoring defence and defencive buffs. Then charges self NP bar by 2 points
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Dash","Range":5,"Damage":6,
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Discharge",
								"Power":1}
						],
						"Cast":"Phantasm Attacked"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Dash","Range":5,"Damage":12,
				"effect_after_attack":[
						{"Buffs":[
							{"Name":"NP Discharge",
								"Power":2}
						],
						"Cast":"Phantasm Attacked"}
						]
					},
		}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
