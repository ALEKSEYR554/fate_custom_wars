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
var ascension_stage
var buffs=[]
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"#if character doen't have weapon then dont touch it
var phantasm_charge=0
var strength


var passive_skills=[
	{
		"Name":"Magic Resistance",#ALL SABERS HAS IT
		"Type":"Status",
		"Types":["Buff Positive Effect"],#addes as demonstration
		"Power":0
	},
	{
		"Name":"Riding",#currently useless
		"Display Name":"Surfing",
		"Type":"Status"
	}
]


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":9,
	"Description ID":"First Skill",
	
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
	"Description ID":"Second Skill",
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
	"Description ID":"Third Skill",
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
	"Description ID":"Class Skill 1",
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
		"Description ID":"Brahmastra",
		
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
								"Condition":"All",
								"Trait":["Demonic"]
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
							"Condition":"All",
							"Trait":["Demonic"]
						}
						}
						]
					},
		}
	}
}


var translation={
	"en":{
		"First Skill":"Increases critical attack damage by three times per critical attack until the end of the next turn. (Cooldown: 9)",
		"Second Skill":"Increases the strength for yourself and allies by 2 points for three turns. (Cooldown: 6)",
		"Third Skill":"Gives yourself one Guts (Resurrects with 8 HP) for three turns, heal health by 9 points, charge Phantasm by 2 points, and increases the chance of critical attacks (2 on the second dice counts as a critical attack) (Cooldown - 6).",
		"Class Skill 1":"Divinity: Increases your strength by 3 points (Cooldown - 8)",
		"Brahmastra":"Brahmastra: - Deals 8 damage to one enemy within six cells, if the enemy is Demonic, the damage is increased by 3 points, lowers their defense by 2 points for three turns, if the enemy is Demonic, it lowers their Phantasm gauge by one point\nOvercharge: Deals 16 damage to one enemy within six cells, if the enemy is Demonic, the damage is increased by 3 points, lowers their defense by 2 points for five turns, if the enemy is Demonic, it lowers their Phantasm gauge by two points."
	},
	"ru":{
		"First Skill":"Увеличивает урон критической атаки в три раза за критическую атаку до конца следующего хода. (Куллдаун: 9)",
		"Second Skill":"Увеличивает силу себе и союзникам на 2 очка на три хода. (Куллдаун: 6)",
		"Third Skill":"Дает себе одну Стойкость (Воскрешает с 8 HP) на три хода, лечит здоровье на 9 очков, заряжает Фантазм на 2 очка и увеличивает шанс критических атак (2 на втором кубике считается критической атакой) (Куллдаун - 6).",
		"Class Skill 1":"Божественность: Увеличивает вашу силу на 3 очка (Куллдаун - 8)",
		"Brahmastra":"Брахмастра: - Наносит 8 урона одному врагу в пределах шести клеток, если враг Демонический, урон увеличивается на 3 очка, понижает его защиту на 2 очка на три хода, если враг Демонический, понижает его шкалу Фантазма на одно очко\nОверчардж: Наносит 16 урона одному врагу в пределах шести клеток, если враг Демонический, урон увеличивается на 3 очка, понижает его защиту на 2 очка на пять ходов, если враг Демонический, понижает его шкалу Фантазма на два очка."
	}

}