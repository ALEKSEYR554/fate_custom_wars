extends Node2D

@onready var players_handler = self.get_parent()

"""
3S-003
(Мексика)
Мировоззрение: Хаотично-Сбалансированная
Класс: Лансер
Имя: Джагер-Мен
Сила: С (3 очка урона)
Выносливость: С (Очки Жизни: 26)
Ловкость: В (+1 к выпавшему результату при уклонении)
Удача: В (+1 к выпавшему результату при активации мгновенной смерти)
Магия: Е (Магическая Защита - 1)
Н.Фантазм: В
Классовые Навыки:
Божественность: А - Повышает свою силу на 3 очка на пять ходов. (Куллдаун - 15),
Безумное Усиление: Е - Повышает свою силу вдвое на один ход, но теряет возможность использовать навыки. (Нельзя активировать при действующих навыках) (Куллдаун - 5),
Личные Навыки:
1) Удар Ягуара: А - Увеличивает свою силу на 1 очко, а также даёт иммунитет ко всем дебаффам на три хода + Даёт себе 2 уклонения и увеличивает шанс критической атаки на 3 хода (1 и 6 на втором кубике считаются критической атакой) (Куллдаун - 9)
2) Пинок Ягура: В - Увеличивает себе или союзнику силу на 1 очко на три хода. Если у противника параметр Силы выше на один ранг, то сила увеличивается на 2 очка, а не на 1. (Куллдаун - 6)
3) Око Ягуара: А+ - Увеличивает свою шкалу Фантазма на 2 очка Фантазма, а также не позволяет противникам включать навык Сокрытие Присутствия на протяжении пяти ходов. (Куллдаун - 8)
Небесный Фантазм:
1) Великий Коготь Смерти - Наносит 6 урона одному противнику игнорируя уклонения.
Оверчардж: Наносит 12 урона одному противнику игнорируя уклонения. 
2) Ягуар в Чёрном - Пассивный Небесный Фантазм активирующийся автоматически ночью:
Когда наступает ночь, то параметр Силы Джагер-Мена повышается на один, но с восходом Солнца сила возвращается к норме + Если Джагер-Мен атакует своего противника ночью, то урон наносится игнорируя уклонения.


"""



const default_stats={
	"hp":26,
	"servant_class":"Lancer",
	"ideology":["Chaotic","Balanced"],
	"gender":"Female",
	"attribute":"Earth",
	"attack_range":2,#most lancers has range=2
	"attack_power":3,#check table info
	"strength":"C",
	"agility":"B",
	"endurance":"C",
	"luck":"B",
	"magic":{"Rank":"E","Power":0,"resistance":1},#check table info
	"traits":["Animal Characteristics Servant", "Divinity", "Hominidae Servant", "Humanoid", "Living Human", "Pseudo-Servant", "Servant", "Seven Knights Servant", "Weak to Enuma Elish", "Wild Beast"]
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
	{
		"Name":"ATK Up",
		"Power":1,
		"Condition":{
			"Who To Check":"Self",
			"What To Check":"Time",
			"Exact":["Night"]
		},
	},
	{
		"Name":"Ignore Evade",
		"Condition":{
			"Who To Check":"Self",
			"What To Check":"Time",
			"Exact":["Night"]
		},
	}
]

var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":9,
	"Description":"Increases your strength by 1 point, and also gives immunity to all debuffs for three turns + Gives yourself 2 dodge and increases critical attack chance for 3 turns (1 and 6 on the second die are considered critical attacks) (Cooldown - 9)",
	
	"Effect":[
		{"Buffs":[
			{
                "Name":"ATK Up",
                "Duration":3,
                "Power":1
            },
            {
                "Name":"Nullify Debuff",
                "Duration":3
            },
            {
                "Name":"Evade",
                "Power":2
            },
            {
                "Name":"Critical Hit Rate Up",
                "Crit Chances":[1,6],
                "Duration":3
            },
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Increases your or an ally's Strength by 2 points for three turns. (Cooldown - 6)",
	
	"Effect":[
		{
            "Buffs":[
                {
                    "Name":"ATK Up",
                    "Power":2,
                    "Duration":3
                }
            ],
		"Cast":"single allie"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"A+",
	"Cooldown":8,
	"Description":"Increases your Phantasm gauge by 2 Phantasm points and also prevents opponents from using Presence Concealment for five turns. (Cooldown - 8)",
	
	"Effect":[
		{"Buffs":[
            {
                "Name":"NP Charge",
                "Power":2
            }
			],
			"Cast":"Self"},
        {"Buffs":[
            {
                "Name":"Nullify Buff",
                "Duration":5,
                "Types To Block":["Presence Concealment"]
            }
			],
			"Cast":"all enemies"}
		]
},
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":15,
	"Description":"Divinity: A - Increases own power by 3 points for five turns. (Cooldown - 15),",
	"Effect":[
		{"Buffs":
			[
				{
					"Name":"ATK Up",
					"Power":3,
					"Duration":5
				}
			],
		"Cast":"Self"}
		]
	},
"Class Skill 2":{
	"Type":"Buff Granting",
	"Rank":"E",
	"Cooldown":5,
	"Description":"Doubles your power for one turn, but loses the ability to use skills. (Cannot be activated while skills are active) (Cooldown - 5)",
	"Effect":[
	{"Buffs":[
		{"Name":"Madness Enhancement",
		"Duration":1,
		"Power":2}
		],
	"Cast":"Self"}
	]}

}

var phantasms={
	"Great Death Claw":{
		"Type":"Buff Granting",
		"Rank":"A",
		"Description":"""Great Death Claw - Deals 6 damage to one enemy, ignoring evade action.
Overcharge: Deals 12 damage to one enemy, ignoring evade action.""",
		"Overcharges":{
		"Default":
			{"Cost":6,"Attack Type":"Single In Range","Range":2,"Damage":6,
				"Phantasm Buffs":[
					{
						"Name":"Ignore Evade",
						"Power":1
					}
				]
            },
		"Overcharge":
			{"Cost":12,"Attack Type":"Single In Range","Range":2,"Damage":12,
				"Phantasm Buffs":[
					{
						"Name":"Ignore Evade",
						"Power":1
					}
				]
            }
		}
	}
}






func _on_button_pressed():
	print(self.name)
	print("buff="+str(buffs))
	pass # Replace with function body.
