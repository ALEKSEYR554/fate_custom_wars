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
var ascension_stage
var buffs=[]
# 0,1,2 - личные навыки, все далее это классовые
var skill_cooldowns=[]
var additional_moves=0
var additional_attack=0
var current_weapon="Scythe"
var phantasm_charge=0
var attribute

var skills={
"First Skill":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":7,
	"Description ID":"First Skill",
	
	"Effect":[
		{"Buffs":[
			{
				"Name":"ATK Up",
				"Duration":3,
				"Power":3
			},
			{
				"Name":"ATK UP X Against Trait",
				"Duration":3,
				"Power":2,
				"Trait":"Summonable"
			}
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"C",
	"Cooldown":6,
	"Description ID":"Second Skill",
	
	"Effect":[
		{
			"Buffs":[
				{
					"Name":"ATK Up X",
					"Duration":1,
					"Power":2
				},
				{
					"Name":"Invincible",
					"Duration":1,
					"Hit Times":1
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
		{
			"Buffs":[
				{
					"Name":"Charge NP",
					"Duration":1,
					"Power":1
				},
				{
					"Name":"Debuff Immune",
					"Duration":1,
					"Power":3
				}
			],
			"Cast":"Self"}
		]
},

"Class Skill 1":{
	"Type":"Weapon Change",
	"Rank":"UNIQ",
	"Cooldown":8,
	"Description ID":"Class Skill 1",
	"free_unequip":true,
	"weapons":{#first is base weapon
		"Scythe":{
			"Description ID":"Weapon Scythe",
			"Is One Hit Per Turn":false,
			"Damage":4,
			"Range":1,
			"Buff":
				{
					"Name":"Magical Damage Get + Attack",
					"Trigger": "Magical Damage Taken",
					"Effect On Trigger":
						{
							"Buffs":[
								{
									"Name":"ATK Up",
									"Duration":2,
									"Power":1
								}
							],
							"Cast":"Self"},
					"Type":"Passive",
					"Power":1
				},
		},
		"Hammer":{
			"Description ID":"Weapon Hammer",
			"Is One Hit Per Turn":true,
			"Damage":6,
			"Range":1,
			"Buff":[
				{
					"Name":"Ignore DEF Buffs",
					"Type":"Passive",
					"Power":1
				},
				{
					"Name":"Ignore Defence",
					"Type":"Passive",
					"Power":1
				},
			]
		},
		"Boomerang":{
			"Description ID":"Weapon Boomerang",
			"Is One Hit Per Turn":false,
			"Damage":0,
			"Range":5,
			"Buff":
				{
					"Name":"pull enemies on attack",
					"Type":"Passive",
					"Trigger":"Success Attack",
					"Effect On Trigger":"pull enemies on attack"
				}
		},
		"Bow":{
			"Description ID":"Weapon Bow",
			"Is One Hit Per Turn":false,
			"Damage":2,
			"Range":2
		},
		"Alebard":{
			"Description ID":"Weapon Alebard",
			"Is One Hit Per Turn":false,
			"Damage":3,
			"Range":2,
			"Buff":
				{
					"Name":"Agility Set",
					"Type":"Passive",
					"Power":"B++"
				}
		}
	}
}
}
var phantasms={
	"Rongominiad":{
		"Rank":"A",
		"Description ID":"Rongominiad",
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
						{"Buffs":
							[
								{
									"Name":"NP Charge",
									"Duration":3,
									"Power":2
								}
							],
						"Cast":"Self"},
						
						{"Buffs":[
							{
								"Name":"Def Down",
								"Duration":3,
								"Power":2
							}
						],
						"Cast":"Phantasm Attacked"},
						]
					},
		}
	}
}



var translation={
	"ru":{
		"First Skill":"Увеличивает свою атаку на 3, увеличивает урон по призываемым существам вдвое на три хода. (Куллдаун - 7)",
		"Second Skill":"Высвобождение запечатанных цепей: C - Увеличивает свой урон вдвое на один ход, а так же получает неуязвимость на одну атаку на один ход (Куллдаун - 6)",
		"Third Skill":"Защита конца света: В - Заряжает свою шкалу фантазма на одно очко, а также даёт себе иммунитет к дебаффам на три хода. (Куллдаун - 6)",
		"Class Skill 1":"Владеет Оддом который может транформироваться в оружия (Куллдаун - 8, однако, если оружие нужно снять, то Куллдаун игнорируется)",
		"Weapon Scythe":"(Стандарное) радиус 1 стандарт урон, магическая защита - 6, при получении магического урона увеличивает себе силу на 1 до конца следующего хода",
		"Weapon Hammer":"радиус 1, урон 6, пробивает защиту и защитные баффы, но за ход можно будет проводить только одну атаку.",
		"Weapon Boomerang":"Радиус 5, урон 0, но возможно повысить баффами, при успешной атаке может притянуть к себе противников на любое количество клеток",
		"Weapon Bow":"Радиус 3, урон 2",
		"Weapon Alebard":"Радиус 2, урон 3, при владении алебардой, ловкость Грей считается B++",
		"Rongominiad":"Ронгоминиад: - Наносит 6 урона всем противникам на одной линии в радиусе 5 игнорируя защиту и неуязвимость, заряжает шкалу фантазма на одно очко\n	Оверчардж: Наносит 12 урона всем противникам на одной линии в радиусе 5 игнорируя защиту и неуязвимость, после понижает им защиту на 2 на три хода, заряжает себе шкалу фантазма на одно очко"
	},
	"en":{
		"First Skill":"Increases own attack by 3, doubles damage against summoned creatures for three turns. (Cooldown - 7)",
		"Second Skill":"Unsealing Chains: C - Doubles own damage for one turn, and also gains invincibility to one attack for one turn (Cooldown - 6)",
		"Third Skill":"Apocalypse Protection: B - Charges own NP gauge by one point, and also grants self debuff immunity for three turns. (Cooldown - 6)",
		"Class Skill 1":"Possesses an Odd that can transform into weapons (Cooldown - 8, however, if the weapon needs to be removed, the Cooldown is ignored)",
		"Weapon Scythe":"(Standard) radius 1 standard damage, magic defense - 6, upon taking magic damage increases own strength by 1 until the end of the next turn",
		"Weapon Hammer":"radius 1, damage 6, penetrates defense and defensive buffs, but only one attack can be performed per turn.",
		"Weapon Boomerang":"Radius 5, damage 0, but can be increased by buffs, upon a successful attack can pull opponents towards self by any number of cells",
		"Weapon Bow":"Radius 3, damage 2",
		"Weapon Alebard":"Radius 2, damage 3, when wielding the halberd, Gray's Agility is considered B++",
		"Rongominiad":"Rhongomyniad: - Deals 6 damage to all opponents in a straight line within a radius of 5, ignoring defense and invincibility, charges the NP gauge by one point\n	Overcharge: Deals 12 damage to all opponents in a straight line within a radius of 5, ignoring defense and invincibility, then reduces their defense by 2 for three turns, charges own NP gauge by one point"
	}
}