extends Node2D

@onready var players_handler = self.get_parent()

"""
    4S-057
    (Франция)
    Мировоззрение: Хаотично-Добрая
    Класс: Лансер
    Имя: Жанна Д'арк (Санта Альтер Лили)
    Сила: С (3 очка урона)
    Выносливость: D (Очки Жизни: 24)
    Ловкость: А (+2 к выпавшему результату при уклонении)
    Удача: А++ (+2 к выпавшему результату при активации Мгновенной Смерти)
    Магия: В (Магическая Защита - 4) 
    Небесный Фантазм: А+
    Личные Навыки:
    1) Святой Подарок: С - Восполняет себе или союзнику здоровье на 13 очков, а также удаляет дебафф отключения критов. (Куллдаун - 5)
    2) Переворот в Себе: А - Заряжает свою Шкалу Фантазма на 1 очко, а также даёт себе иммунитет к дебаффам на три хода. (Куллдаун - 5)
    3) Эфемерная Мечта: ЕХ - Даёт себе следующие баффы на один ход:
    Неуязвимость до конца следующего хода,
    Увеличение силы на 3 очка,
    Однако, после активации наносится 2 урона. (Навык не может убить) (Куллдаун - 6)
    Небесный Фантазм:
    La Grâce Fille Noël: Наносит всем противникам в радиусе трёх клеток 6 урона, после чего увеличивает себе и союзникам силу на 3 очка на три хода, а также увеличивает восполнение здоровья вдвое на три хода.
    Оверчардж: Наносит всем противникам в радиусе трёх клеток 12 урона, после чего увеличивает себе и союзникам силу на 5 очков на три хода, а также увеличивает восполнение здоровья вдвое на три хода. 
"""


const default_stats={
	"hp":24,
	"servant_class":"Lancer",
	"ideology":["Chaotic","Good"],
	"gender":"Female",
	"attribute":"Man",
	"attack_range":2,#most lancers has range=2
	"attack_power":3,#check table info
	"strength":"C",
	"agility":"A",
	"endurance":"D",
	"luck":"B",
	"magic":{"Rank":"B","Power":0,"Resistance":4},#check table info
	"traits":["Artoria Face", "Child Servant", "Hominidae Servant", "Humanoid", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
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

var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":5,
	"Description":"Restores 13 health to yourself or an ally, and removes the crit disable debuff. (Cooldown - 5)",

	"Effect":[
		{"Buffs":[
			{
                "Name":"Heal",
				"Power":13
            },
            {
                "Name":"Buff Removal",
                "Types To Remove":["Crit Block"]
            }
			],
			"Cast":"Single Allie"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":5,
	"Description":"Charges your Phantasm Gauge by 1 point and also grants yourself immunity to debuffs for three turns. (Cooldown - 5)",
	
	"Effect":[
		{"Buffs":[
			{
                "Name":"NP Charge",
				"Power":1#1 point
            },
            {
                "Name":"Nullify Debuff",
                "Duration":3,
            }
				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":6,
	"Description":"Grants herself the following buffs for one turn:
Invulnerability until the end of the next turn,
Increases strength by 3 points,
However, after activation, it deals 2 damage. (Skill cannot kill) (Cooldown - 6)",
	
	"Effect":[
		{"Buffs":[
			{
                "Name":"Invincible",
                "Duration":1.5,
            },
            {
                "Name":"ATK Up",
                "Duration":1.5,
                "Power":3
            },
            {
                "Name":"HP Drain",
                "Power":2,
            }
            ],
			"Cast":"Self"}
		]
},

}

var phantasms={
	"!!!!!!!!!!!!!!!!!!PHANTASM NAME!!!!!!!!!!!!!!!!!!":{
		"Rank":"A",
		"Description":"""La Grace Fille Noël: Deals 6 damage to all enemies within a 3-tile radius, then increases self and allies' strength by 3 for 3 turns, and doubles health regeneration for 3 turns.
Overcharge: Deals 12 damage to all enemies within a 3-tile radius, then increases self and allies' strength by 5 for 3 turns, and doubles health regeneration for 3 turns.
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"All Enemies In Range","Range":3,"Damage":6,
                "effect_after_attack":[
						{"Buffs":[
							{
                                "Name":"ATK Up",
								"Duration":3,
								"Power":3
                            },
                            {
                                "Name":"HP Recovery Up X",
                                "Duration":3,
                                "Power":2
                            }
						],
						"Cast":"all allies"}
					]
                },
			"Overcharge":
				{"Cost":12,"Attack Type":"All Enemies In Range","Range":3,"Damage":12,
                "effect_after_attack":[
						{"Buffs":[
							{
                                "Name":"ATK Up",
								"Duration":3,
								"Power":5
                            },
                            {
                                "Name":"HP Recovery Up X",
                                "Duration":3,
                                "Power":2
                            }
						],
						"Cast":"all allies"}
					]
                },
			}
	}
}





func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
