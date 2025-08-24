extends Node2D
#Bynyan
@onready var players_handler = self.get_parent()
const default_stats={
	"hp":40,
	"servant_class":"Berserker",
	"ideology":["Balanced","Neutral"],
	"gender":"Female",
	"attack_range":1,
	"attack_power":3,
	"strength":"C",
	"attribute":"Earth",
	"agility":"C",
	"endurance":"A",
	"luck":"E+",
	"magic":{"Rank":"E","Power":0,"Resistance":1},#magic power / magic resistance,
	"traits":[
		"Child Servant",
		"Costume-Owning", 
		"Fairy Tale Servant", 
		"Giant", 
		"Hominidae Servant", 
		"Humanoid", 
		"Servant", 
		"Seven Knights Servant", 
		"Weak to Enuma Elish"
	]
}

var servant_class
var ideology
var attack_range
var attack_power
var agility#ловкость
var endurance#вынослиость
var hp
var luck
var magic #["C",0,3]
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var traits
var strength
var phantasm_charge=0
var attribute
var gender
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
	strength=default_stats["strength"]
	traits=default_stats["traits"]
	attribute=default_stats["attribute"]
	gender=default_stats["gender"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.


var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":6,
	"Description":"Счастливые Товарищи: А - Увеличивает силу на 3 очка себе и союзникам на три хода. (Куллдаун - 6)",
	"Effect":[
	{"Buffs":
		{"Name":"ATK Up",
		"Duration":3,
		"Power":3},
	"Cast":"All allies"},
	{
		"Buffs":
			{
				"Name":"Summon",#
				"Duration":3,#
				"Summon Name":"rama",#
				"Skills Enabled":false,#
				"One Time Skills":false,#
				"Can Use Phantasm":false,#
				"Disappear After Summoner Death":true,#?
				"Mount":false,
				"Require Riding Skill":false,
				"Can Attack":true,#
				"Can Evade":true,#
				"Can Defence":true,#
				"Can Parry":true,#
				"Move Points":1,#
				"Attack Points":1,#
				"Phantasm Points Farm":false,#
				"Limit":3,#
				"Servant Data Location":"Main"#
			},
		"Cast":"Self"
	}
]},
"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A",
	"Cooldown":6,
	"Description":"Озеро Фасолевого Супа: А - Восполняет здоровье всей команде на 8 очков. (Куллдаун - 6)",
	"Effect":[
		{"Buffs":[{"Name":"Heal",
		"Duration":3,
		"Power":8}],
	"Cast":"All Allies"}
]},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":6,
	"Description":"Попкорновая Снежная Буря: В - Понижает всем противника защиту вдвое на три хода, а также увеличивает себе и союзникам вдвое восполнение здоровье (Если здоровье восполняется на какое-либо значение, то это значение удваивается) на пять ходов. (Куллдаун - 6)",
	"Effect":[
		{"Buffs":
			{"Name":"Def Down X",
			"Duration":3,
			"Power":2},
		"Cast":"All Enemies"},
		{"Buffs":{"Name":"HP Recovery Up X",
			"Duration":6,
			"Power":2},
		"Cast":"All Allies"}
		]
},

"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"D",
	"Cooldown":5,
	"Description":"Безумное Усиление: D - Увеличивает силу вдвое на три хода, но снимает с себя все баффы и запрещает использовать навыки во время действия Безумного усиления (Куллдаун - 5)",
	"Effect":[
	{"Buffs":[
		{"Name":"Madness Enhancement",
		"Duration":3,
		"Power":2}
		],
	"Cast":"Self"}
	]}
}
#Чудесные Подвиги - Бунян увеличивается и на четыре хода сила умножается в три раза, радиус атаки увеличивается до четырёх клеток и повышается вдвое защита. 
		#Оверчардж: Бунян увеличивается и на семь ходов сила умножается в три раза, радиус атаки увеличивается до четырёх клеток и повышается вдвое защита. 
var phantasms={
	"Marvelous Exploits":{
		"Type":"Buff Granting",
		"Rank":"C",
		"Description":"""Чудесные Подвиги - Бунян увеличивается и на четыре хода сила умножается в три раза, радиус атаки увеличивается до четырёх клеток и повышается вдвое защита.\n
Оверчардж: Бунян увеличивается и на семь ходов сила умножается в три раза, радиус атаки увеличивается до четырёх клеток и повышается вдвое защита. 
""",
		"Overcharges":{
			"Default":
				{"Cost":6,"Attack Type":"Buff Granting",
				"Effect":[
						{"Buffs":[
							{"Name":"ATK Up X",
								"Duration":4,
								"Power":3},
							{"Name":"Attack Range Set",
								"Duration":4,
								"Power":4},
							{"Name":"Def Up X",
								"Duration":4,
								"Power":2},
						],
						"Cast":"Self"}
						]
					},
			"Overcharge":
				{"Cost":12,"Attack Type":"Buff Granting",
				"Effect":[
						{"Buffs":[
							{"Name":"ATK Up X",
								"Duration":7,
								"Power":3},
							{"Name":"Attack Range Set",
								"Duration":7,
								"Power":4},
							{"Name":"Def Up X",
								"Duration":7,
								"Power":2},
						],
						"Cast":"Self"}
						]
					},
		}
	}
}
