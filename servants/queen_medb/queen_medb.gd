extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":22,
	"servant_class":"Rider",
	"ideology":["Chaotic","Evil"],
	"gender":"Female",
	"attribute":"Earth",
	"attack_range":1,#most riders has range=1
	"attack_power":1,#check table info
	"strength":"E",
	"agility":"B",
	"endurance":"E",
	"luck":"EX",
	"magic":{"Rank":"C","Power":0,"Resistance":3},#check table info
	"traits":["Costume-Owning", "Hominidae Servant", "Humanoid", "King", "Riding", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
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
var ascension_stage


var passive_skills=[
	{
		"Name":"Temptation",
		"Type":"Status",
		"Types":["Buff Positive Effect"],
		"Trigger":"Total Kill",
		"Effect On Trigger":{
			"Buffs":[
				
				{
					"Name":"Attacking Phantasm Absorb",
					"Power":1
				}
				],
				"Cast":"Trigger Initiator"
			
		}
	},
	{
		"Name":"Riding",
		"Rank":"A",
		"Type":"Status"
	}
]
var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A+",
	"Cooldown":6,
	"Description ID":"First Skill",
	
	"Effect":[
		{"Buffs":[
			{
				"Name":"Nullify Debuff",
				"Duration":3
			},
			{
				"Name":"Restore HP Each Turn",
				"Duration":3,
				"Trigger": "End Turn",
				"Effect On Trigger":
					{"Buffs":[
						{"Name":"Heal",
							"Power":2}
						],
						"Cast":"Self"
					}
			},
			{
				"Name":"Restore NP Each Turn",
				"Duration":3,
				"Trigger": "End Turn",
				"Effect On Trigger":
					{"Buffs":[
						{"Name":"NP Charge",
							"Power":1}
						],
						"Cast":"Self"
					}
			}
			],
			"Cast":"Self"},

		{
			"Buffs":[
				
				{
					"Name":"NP Charge",
					"Power":2
				}
			],
			"Cast":"",
			"Cast Condition":{
				"Condition":"Any",
				"Gender":["Male"],
				"Trait":["Fae"]
			}
		}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":6,
	"Description ID":"Second Skill",
	
	"Effect":[
		{
			"Buffs":[
				{
					"Name":"ATK Up",
					"Power":2,
					"Duration":3
        	    }
			],
			"Cast":"All Allies"},
		{
			"Buffs":[
				{
					"Name":"ATK Up",
					"Power":3,
					"Duration":2
        	    }
			],
			"Cast":"All Allies",
			"Cast Condition":{
				"Condition":"Any",
				"Gender":["Male"]
			}
		},
		{
			"Buffs":[
				{
					"Name":"Heal",
					"Power":5
        	    }
			],
			"Cast":"Self"
		},
	]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":6,
	"Description ID":"Third Skill",
	
	"Effect":[
		{"Buffs":[
			{
				"Name":"Charm",
				"Duration":1,
				"Cast Condition":{
					"Condition":"Any",
					"Gender":["Male"]
				},
				"Types":["Buff Negative Effect","Buff Mental Effect", "Buff Charm","Buff Charm Female", "Buff Immobilize"]
			},
			{
				"Name":"DEF Down",
				"Duration":4,
				"Power":3
			}
			],
			"Cast":"single enemie"}
		]
},

"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":0,
	"Description ID":"Class Skill 1",
	
	"Effect":[
		{"Choose Buff":
			{"Warrior":#mini buff name REQUIED
				{"Buffs":[
					{
						"Name":"Summon",
						"Summon Name":"druid",
						"Servant Data Location":"Sub",
						"Limit":3
					}
					
					],
					"Cost":{
						"Currency":"HP",
						"Amount":3
					},
					"Cast":"Self",
					"Description ID":"Druid Summon"},
		
		"Druid":#mini buff name REQUIED
			{"Buffs":[
				{
					"Name":"Summon",
					"Summon Name":"warrior",
					"Servant Data Location":"Sub",
					"Limit":3
				}
				],
				"Cost":{
					"Currency":"HP",
					"Amount":2
				},
				"Cast":"Self",
				"Description ID":"Warriow Summon"},
			}
		}
		]
}

}
var phantasms={
	"Chariot My Love":{
		"Rank":"A",
		"Description":"Chariot My Love",
		"Overcharges":
			{"Default":
				{"Cost":6,"Attack Type":"Single In Range","Range":4,"Damage":5,
				"Phantasm Buffs":[
					{
						"Name":"ATK Up X Against Gender",
						"Gender":"Male",
						"Power":2
					}
				],
				"effect_after_attack":[
						{"Buffs":[
							{
								"Name":"Disable Resistance For Buff",
								"Duration":3,
								"Types":["Buff Mental Effect"]
							}
						],
						"Cast":"phantasm attacked"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Single In Range","Range":4,"Damage":10,
				"Phantasm Buffs":[
					{
						"Name":"ATK Up X Against Gender",
						"Gender":"Male",
						"Power":2
					}
				],
				"effect_after_attack":[
						{"Buffs":[
							{
								"Name":"Disable Resistance For Buff",
								"Duration":5,
								"Types":["Buff Mental Effect"]
							}
						],
						"Cast":"phantasm attacked"}
						]
					}
		}
	},
	"My Red Mead: My Dear Honey Wine":{
		"Rank":"C",
		"Description ID":"My Red Mead: My Dear Honey Wine",
		"Overcharges":
			{"Default":
				{"Cost":12,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{
							"Name":"Charm",
							"Duration":1
						},
						{
							"Name":"Attack Restrict Against Player",
							"Duration":6
						}
					],
					"Cast":"Single Enemie",
					"Cast Condition":{
						"Condition":"Any",
						"Gender":["Male"]
					}
					}
				]
			}
		}
	},
	"Conchobar My Love":{
		"Rank":"C",
		"Description ID":"Conchobar My Love",
		"Overcharges":
			{"Default":
				{"Cost":5,"Attack Type":"Buff Granting","Range":0,"Damage":0,
				"Effect":[
					{"Buffs":[
						{
							"Name":"Dice +",
							"Action":"Evade",
							"Duration":3,
							"Power":1
						},
						{
							"Name":"Dice Reroll",
							"Action":"Evade",
							"Duration":3,
							"Power":1
						}
					],
					"Cast":"Self"
					}
				]
			}
		}
	}

}


var translation={
	"ru":{
		"First Skill":"Великолепное Тело: A+ - Даёт себе неуязвимость к дебаффам на 3 хода, накладывает на себя бафф регенерации который восстанавливает 2 хп на протяжении 3 ходов, бафф восполнения фантазма на одно очко на 3 хода. Заряжает фантазм союзникам мужчинам и феям на 2 очка. (Куллдаун - 6)",
		"Second Skill":"Королевская дисциплина: A - Увеличивает силу себе и союзникам на 2 очка на три хода, увеличивает силу союзникам мужчинам на 3 очка на три хода, а также восстанавливает своё здоровье на 5 очков. (Куллдаун - 6)",
		"Third Skill":"Мой красный мед: Мое дорогое медовое вино: С - Очаровывает одного мужского противника на один ход, после понижает его защиту на 4 очка на 3 хода (Куллдаун - 6)",
		"Class Skill 1":"Королевская Кровь: Позволяет потратить 2 хп и призвать на поле одного кельтского воина с 2 хп и атк 2. Может потратить 3 хп и призвать одного друида с 2хп и магической атакой 3. У данного навыка нет куллдауна. Максимум воинов - 6.",
		"Druid Summon":"Может потратить 3 хп и призвать одного друида с 2хп и магической атакой 3",
		"Warriow Summon":"Позволяет потратить 2 хп и призвать на поле одного кельтского воина с 2 хп и атк 2.",
		"Chariot My Love":"Колесница Моя Любовь - Наносит 5 урона одному противнику в радиусе 4 клеток, наносит вдвое больше урона по мужчинам. После чего отключает этому противнику сопротивление к ментальным баффам на 3 хода.\nОверчардж:\nНаносит 10 урона одному противнику в радиусе 4 клеток, наносит вдвое больше урона по мужчинам. После чего отключает этому противнику сопротивление к ментальным баффам на 5 ходов.",
		"My Red Mead: My Dear Honey Wine":"Мой красный мед: Мое дорогое медовое вино: Очаровывает одного мужского противника на один ход, а так же запрещает ему атаковать Медб на протяжении 6 ходов. Можно активировать только в состоянии оверчарджа",
		"Conchobar My Love":"Конхобар, любовь моя: Моё дорогое предвидение: Накладывает на себя бафф на 3 хода который позволяет прекинуть кубик один раз за уклонение, если выпал неудовлетворительный результат. А так же повышает значение кубика при уклонении на 1 очко на 3 хода. Стоимость 5 очков фантазма. Оверчардж отсутствует."
	},
	"en":{
		"First Skill":"Magnificent Body: A+ - Grants self debuff invulnerability for 3 turns, applies a regeneration buff to self that restores 2 hp for 3 turns, and a NP restoration buff by one point for 3 turns. Charges NP for male allies and fairies by 2 points. (Cooldown - 6)",
		"Second Skill":"Royal Discipline: A - Increases the strength of self and allies by 2 points for three turns, increases the strength of male allies by 3 points for three turns, and also restores own health by 5 points. (Cooldown - 6)",
		"Third Skill":"My Red Mead: My Dear Honey Wine: C - Charms one male opponent for one turn, then reduces their defense by 4 points for 3 turns (Cooldown - 6)",
		"Class Skill 1":"Royal Blood: Allows to spend 2 hp and summon one Celtic warrior with 2 hp and 2 attack on the field. Can spend 3 hp and summon one druid with 2 hp and 3 magic attack. This skill has no cooldown. Maximum warriors - 6.",
		"Druid Summon":"Can spend 3 hp and summon one druid with 2 hp and 3 magic attack",
		"Warriow Summon":"Allows to spend 2 hp and summon one Celtic warrior with 2 hp and 2 attack on the field.",
		"Chariot My Love":"Chariot My Love - Deals 5 damage to one opponent within a radius of 4 cells, deals twice the damage to males. After that, disables the opponent's resistance to mental buffs for 3 turns.\nOvercharge:\nDeals 10 damage to one opponent within a radius of 4 cells, deals twice the damage to males. After that, disables the opponent's resistance to mental buffs for 5 turns.",
		"My Red Mead: My Dear Honey Wine":"My Red Mead: My Dear Honey Wine: Charms one male opponent for one turn, and also prohibits him from attacking Medb for 6 turns. Can only be activated in Overcharge state",
		"Conchobar My Love":"Conchobar, My Love: My Dear Foresight: Applies a buff to self for 3 turns that allows rerolling the die once for evasion if an unsatisfactory result is rolled. And also increases the value of the die during evasion by 1 point for 3 turns. Cost 5 Phantasm points. Overcharge is absent."
	}
}