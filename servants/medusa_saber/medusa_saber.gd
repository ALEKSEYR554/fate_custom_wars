extends Node2D

@onready var players_handler = self.get_parent()


"""
5S-074
(Древняя Греция)
Мировоззрение: Хаотично-Нейтральный
Класс: Сэйбер
Имя: Медуза
Сила: А+ (6 очков урона)
Выносливость: С (Очки Жизни: 26)
Ловкость: С 
Удача: Е
Магия: А (Магическая Защита - 5)
Н.Фантазм: А
Классовые Навыки:
Магическое Сопротивление: Вдвое понижает получаемый Магический Урон,
Верховая Езда: Если Медуза получит транспорт, то она сможет передвигаться на две клетки больше. (Дополнительные шаги не учитываются остальными действиями),
Божественность: Увеличивает силу на 1 очко на четыре хода. (Куллдаун - 6),
Личные Навыки:
1) Горгон Брэйкер: В - Парализует одного противника в радиусе трёх клеток на один ход, увеличивает точность своих атак (результат броска кубика при атаке больше 1) на три хода, а также даёт себе следующий бафф:
Если атака проводится успешно, то на противника накладывается дебафф отравления на пять ходов, который наносит 1 урона, когда тот пытается уклоняться.,
(Куллдаун - 7)
2) Демонические Кровеносные Сосуды: А - Восполняет свою Шкалу Фантазма на 3 очка, увеличивает себе и союзникам силу на 2 очка на три хода, а также увеличивает свою силу против демонов вдвое на три хода. (Куллдаун - 7)
3) Фактор Хищничества (Богиня Войны): ЕХ - Даёт себе бафф неуязвимости на три атаки, иммунитет к дебаффам на три хода, а также увеличивает шанс критической атаки (1 и 6 на втором кубике считается критической атакой) на три хода. (Куллдаун - 8)
Небесный Фантазм:
Хриосаор - Наносит 8 урона одному противнику в радиусе пяти клеток, после чего бросает кубик с противником. Если результат Медузы выше, то противник парализуется. После чего увеличивает союзникам силу вдвое на один ход. 
Если противник является мужчиной, то урон увеличивается на 3 очка.,
Оверчардж: Наносит 16 урона одному противнику в радиусе пяти клеток, после чего бросает кубик с противником. Если результат Медузы выше, то противник парализуется. После чего увеличивает союзникам силу вдвое на один ход. 
Если противник является мужчиной, то урон увеличивается на 6 очка.
"""
const default_stats={
	"hp":26,
	"servant_class":"Saber",
	"ideology":["Chaotic","Balanced"],
	"gender":"Female",
	"attack_range":1,#most sabers has range=1
	"attack_power":6,#check table info
	"strength":"A+",
	"agility":"C",
	"endurance":"C",
	"luck":"E",
	"magic":{"Rank":"A","Power":0,"resistance":5},#check table info
	"traits":["Divine Spirit", "Divinity", "Humanoid", "Non-Hominidae Servant", "Riding", "Serpent", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
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
	"Cooldown":7,
	"Description":"Paralyzes one enemy within three cells for one turn, increases the accuracy of your attacks (the result of the dice roll when attacking is greater than 1) for three turns, and also gives yourself the following buff:
If the attack is successful, the enemy is debuffed with poison for five turns, which deals 1 damage (Cooldown - 7)",
	
	"Effect":[
		{
            "Buffs":[
			{
				"Name":"Paralysis",
				"Duration":1
			}
			],
			"Cast":"single in range","Cast Range":3},
        {
            "Buffs":[
                {
                    "Name":"Dice +",
                    "Action":"Attack",
                    "Duration":3
                },
                {
                    "Name":"Poison On Attack",
                    "Trigger": "Success Attack",
                    "Types":["Buff Positive Effect"],
                    "Effect On Trigger":
                        {"Buffs":[
                            {
                                "Name":"Poison",
                                "Duration":5,
                                "Power":2,
                                "Trigger":"End Turn",
                                "Effect On Trigger":"Take Damage By Power"
                            }
                            ],
                            "Cast":"Trigger Initiator"},
                    "Duration":3,
                    "Power":1
                }
                ],
			"Cast":"Self"}
    
    ]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":7,
	"Description":"Charge her Phantasma Gauge by 3 points, increases hers' and allies' strength by 2 points for 3 turns, and doubles your strength against Demonic trait for 3 turns. (Cooldown - 7)",
	"Effect":[
		{"Buffs":[
			{
				"Name":"NP Charge",
				"Power":3
			},
            {
				"Name":"ATK Up",
				"Duration":3,
				"Power":2
			},
            {
                "Name":"ATK Up X Against Trait",
                "Power":2,
                "Trait":"Demonic"
            }
			],
			"Cast":"All allies"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":8,
	"Description":"Gives herself an invulnerability buff for three attacks, immunity to debuffs for three turns, and increases her critical attack chance (1 and 6 on the second die count as a critical attack) for three turns. (Cooldown - 8).",
	"Effect":[
		{"Buffs":[
			{
				"Name":"Invincible",
				"Power":3,
			},
			{
                "Name":"Nullify Debuff",
                "Duration":3,
            },
			{
				"Name":"Critical Hit Rate Up",
				"Duration":3,
				"Crit Chances":[1,6]
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
				"Power":3
			}
			],
			"Cast":"Self"}
		]
}
}
var phantasms={
	"Chrysaor":{
		"Rank":"A",
		"Description":"""Chrysaor - Deals 8 damage to one enemy within a five-cell radius, then rolls the die with the enemy. If Medusa's result is higher, the enemy is paralyzed. Then doubles allies' strength for one turn. If the enemy is male, the damage is increased by 3 points.
Overcharge: Deals 16 damage to one enemy within a five-cell radius, then rolls the die with the enemy. If Medusa's result is higher, the enemy is paralyzed. Then doubles allies' strength for one turn. If the enemy is male, the damage is increased by 6 points.
	""",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Single In Range","Range":5,"Damage":8,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Gender",
						"Gender":"Male",
						"Power":3}
					],
				"effect_after_attack":
					[
						{"Buffs":[
							{
                                "Name":"Roll dice for effect",
							    "Buff To Add":
								[
                                    {
                                        "Name":"Paralysis",
									    "Duration":1
									}									
								]
                            }
						],
						"Cast":"Phantasm Attacked"},
						{
							"Buffs":[
								{
									"Name":"ATK Up X",
									"Power":2,
                                    "Duration":0.5
								}
							],
							"Cast":"All Allies"
						}
					]
				},
			"Overcharge":
				{"Cost":12,"Attack Type":"Single In Range","Range":5,"Damage":16,
				"Phantasm Buffs":[
					{"Name":"ATK Up Against Gender",
						"Gender":"Male",
						"Power":6}
					],
				"effect_after_attack":
					[
						{"Buffs":[
							{
                                "Name":"Roll dice for effect",
							    "Buff To Add":
								[
                                    {
                                        "Name":"Paralysis",
									    "Duration":1
									}									
								]
                            }
						],
						"Cast":"Phantasm Attacked"},
						{
							"Buffs":[
								{
									"Name":"ATK Up X",
									"Power":2,
                                    "Duration":0.5
								}
							],
							"Cast":"All Allies"
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
