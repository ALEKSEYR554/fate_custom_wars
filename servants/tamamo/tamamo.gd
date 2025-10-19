extends Node2D

@onready var players_handler = self.get_parent()

"""
5S-069
(Япония)
Мировоззрение: Нейтрально-Злая
Класс: Кастер
Имя: Тамамо-но-Маэ
Сила: Е (1 очко урона)
Выносливость: Е (Очки Жизни: 15)
Ловкость: В (+1 к выпавшему результату при уклонении)
Удача: D
Магия: А (Магическая Защита - 5 / Магический урон - 10)
Н.Фантазм: В
Классовые Навыки:
Создание Территории: Захватывает одну клетку и пять клеток вокруг неё. Все захваченные клетки становятся территорией на которой Магический урон никогда не понижается. Стоя на этих клетках Кастер поднимает свою шкалу фантазма на одну единицу раз в ход. Этот навык можно активировать лишь один раз.,
Божественность: Увеличивает свою силу на 4 очка на три хода. (Куллдаун - 8),
Личные Навыки:
1) Мантра: Безграничный Солнечный Свет: А - Понижает Шкалу Фантазма одного противника на 1 очко, а также увеличивает союзникам силу фантазма вдвое на три хода. (Куллдаун - 5)
2) Перевоплощение: А - Увеличивает свою защиту вдвое до конца хода, а также поверх этого баффа ещё увеличивает свою защиту вдвое на три хода. (Куллдаун - 6)
3) Лисичья Свадьба: ЕХ - Увеличивает себе или союзнику силу на 4 очка на три хода, (если основной урон является магическим, то на 8) а также восполняет здоровье на 9 очков. Также, если у противников есть навыки исцеления или удаления дебаффов, то они обязаны использовать их на том игроке на которого укажет Тамамо (Либо конкретно на самой Тамамо). Если навыки недоступны, то игроки не обязаны их использовать. (Куллдаун - 7)
Небесный Фантазм:
Suiten Nikkō Amaterasu Yano Shizu-Ishi - Активируются следующие баффы на всю команду: 
Понижает себе и союзникам куллдауны навыков на 1,
Восполняет 13 очков здоровья,
Повышает Шкалу Фантазма на 3 очка.,
Оверчардж: Активируются следующие баффы на всю команду: 
Понижает себе и союзникам куллдауны навыков на 2,
Восполняет 22 очков здоровья,
Повышает Шкалу Фантазма на 6 очков.

"""


const default_stats={
	"hp":15,
	"servant_class":"Caster",
	"ideology":["Neutral","Evil"],
	"attribute":"Sky",
	"gender":"Female",
	"attack_range":1,#most casters has range=1
	"attack_power":1,#check table info
	"strength":"E",
	"agility":"B",
	"endurance":"E",
	"luck":"D",
	"magic":{"Rank":"A","Power":10,"Resistance":5},#check table info
	"traits":["Animal Characteristics Servant", "Demonic Beast Servant", "Divine Spirit", "Divinity", "Goddess Servant", "Humanoid", "Non-Hominidae Servant", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
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
	"Rank":"A",
	"Cooldown":5,
	"Description ID":"First Skill",
	
	"Effect":[
		{
            "Buffs":[
			{
                "Name":"NP Discharge",
				"Power":1
            }
			],
			"Cast":"single in range","Cast Range":99
        },
        {
            "Buffs":[
			{
                "Name":"NP Strength Up X",
				"Power":2,
                "Duration":3
            }
			],
			"Cast":"all allies"
        }
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":6,
	"Description ID":"Second Skill",
	
	"Effect":[
		{"Buffs":[
			{
                "Name":"Def Up X",
				"Power":2,
                "Duration":0.5
            },
            {
                "Name":"Def Up X",
				"Power":2,
                "Duration":3
            }
				],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":7,
	"Description ID":"Third Skill",
	
	"Effect":[
		{
            "Buffs":
            [
                {
                    "Name":"ATK Up",
                    "Duration":3,
                    "Power":4
                },
                {
                    "Name":"ATK Up",
                    "Condition":{
                        "Who To Check":"Self",
                        "What To Check":"Magic Power",
                        "Bigger Than":0
                    },
                    "Duration":3,
                    "Power":4
                },
                {
                    "Name":"Heal",
                    "Power":9
                },
                {
                    "Name":"Absorb Buffs",
                    "Duration":3,
                    "Buffs Names":["Heal","Debuff Removal"]
                }
			],
			"Cast":"Self"
        }
		]
},
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":NAN,#one time skill
	"Description ID":"Class Skill 1",
	"Effect":[
	{"Buffs":[
		{"Name":"Field Creation",
		"Amount":5,"Config":
			{
				"Np Up Every N Turn":1,
				"Ignore Magical Defence":true,
				"Additional":null}
			}
		],
	"Cast":"Self"}
	]
},

"Class Skill 2":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":8,
	"Description ID":"Class Skill 2",
	"Effect":[
		{"Buffs":
			[
				{
					"Name":"ATK Up",
					"Power":4,
					"Duration":3
				}
			],
		"Cast":"Self"}
		]
	}
}
var phantasms={
	"Suiten Nikkō Amaterasu Yano Shizu-Ishi":{
		"Rank":"A",
		"Description ID":"Suiten Nikkō Amaterasu Yano Shizu-Ishi",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{
                            "Name":"Reduce Skills Cooldown",
                            "Power":1
                        },
						{
                            "Name":"Heal",
							"Power":13
                        },
                        {
                            "Name":"NP Charge",
							"Power":3
                        }
					],
					"Cast":"All allies"}
					]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{
                            "Name":"Reduce Skills Cooldown",
                            "Power":2
                        },
						{
                            "Name":"Heal",
							"Power":22
                        },
                        {
                            "Name":"NP Charge",
							"Power":6
                        }
					],
					"Cast":"All allies"}
					]
					},
		}
	}
}


var translation={
	"en":{
		"First Skill":"Decreases the Phantasm Gauge of one enemy by 1 point, and also doubles the Phantasm power of allies for three turns. (Cooldown - 5)",
		"Second Skill":"Doubles your defense until the end of the turn, and on top of that buff, doubles your defense for three turns. (Cooldown - 6)",
		"Third Skill":"Increases your or an ally's strength by 4 points for three turns (if the main damage is magical, then by 8) and also restores health by 9 points. Also, if opponents have healing or debuff removal skills, then their use will be redirected to this player (Cooldown - 7)",
		"Class Skill 1":"Territory Creation: Captures one cell and five cells around it. All captured cells become a territory where Magic damage ignores magical defence (but not sabes's magical resistance). Standing on these cells Caster raises his Phantasm charge by one point once per turn. This skill can be activated only once.",
		"Class Skill 2":"Divinity: Increases own power by 4 points for three turns. (Cooldown - 8)",
		"Suiten Nikkō Amaterasu Yano Shizu-Ishi":"Suiten Nikkō Amaterasu Yano Shizu-Ishi - Activates the following buffs for the entire team:\nDecreases self and allies' skill cooldowns by 1,\nRestores 13 HP,\nIncreases Phantasm Gauge by 3 points.\n		Overcharge: Activates the following buffs for the entire team:\nDecreases self and allies' skill cooldowns by 2,\nRestores 22 HP,\nIncreases Phantasm Gauge by 6 points."
	},
	"ru":{
		"First Skill":"Понижает Шкалу Фантазма одного врага на 1 очко, а также удваивает силу Фантазма союзников на три хода. (Куллдаун - 5)",
		"Second Skill":"Удваивает вашу защиту до конца хода, а также поверх этого баффа удваивает вашу защиту на три хода. (Куллдаун - 6)",
		"Third Skill":"Увеличивает силу вашу или союзника на 4 очка на три хода (если основной урон магический, то на 8), а также восстанавливает здоровье на 9 очков. Также, если у противников есть навыки лечения или снятия дебаффов, то их использование будет перенаправлено на этого игрока (Куллдаун - 7)",
		"Class Skill 1":"Создание Территории: Захватывает одну клетку и пять клеток вокруг нее. Все захваченные клетки становятся территорией, где Магический урон игнорирует магическую защиту (но не магическое сопротивление Сэйберов). Стоя на этих клетках Кастер повышает свой заряд Фантазма на одно очко раз в ход. Этот навык можно активировать только один раз.",
		"Class Skill 2":"Божественность: Увеличивает собственную силу на 4 очка на три хода. (Куллдаун - 8)",
		"Suiten Nikkō Amaterasu Yano Shizu-Ishi":"Suiten Nikkō Amaterasu Yano Shizu-Ishi - Активирует следующие баффы для всей команды:\nПонижает куллдаун навыков себе и союзникам на 1,\nВосстанавливает 13 HP,\nУвеличивает Шкалу Фантазма на 3 очка.\n		Оверчардж: Активирует следующие баффы для всей команды:\nПонижает куллдаун навыков себе и союзникам на 2,\nВосстанавливает 22 HP,\nУвеличивает Шкалу Фантазма на 6 очков."
	}
}