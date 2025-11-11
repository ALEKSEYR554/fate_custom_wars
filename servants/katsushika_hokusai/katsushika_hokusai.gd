extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":24,
	"servant_class":"Foreigner",
	"ideology":["Chaotic","Neutral"],
	"gender":"Female",
	"attribute":"Man",
	"attack_range":3,
	"attack_power":2,
	"strength":"D",
	"agility":"B",
	"endurance":"D",
	"luck":"A",
	"magic":{"Rank":"B","Power":8,"Resistance":4},
	"traits":["Divinity", "Existence Outside the Domain", "Hominidae Servant", "Humanoid", "Servant", "Threat to Humanity", "Weak to Enuma Elish"]
}

var ttt='''
5S-117
(Япония)
Мировоззрение: Хаотично-Сбалансированная
Класс: Форейнер (Радиус атаки - 3 клетки)
Имя: Кацусика Хокусай
Сила: D (2 очка урона)
Выносливость: D (Очки Жизни: 24)
Ловкость: B +1 к выпавшему результату при уклонении)
Удача: A (+2 к выпавшему результату при мгновенной смерти)
Магия: B (Магическая Защита - 4 / Магический Урон - 8)
Н.Фантазм: B+
Классовые Навыки: 
Существование За Пределами Домена: Силу Хокусай невозможно понизить.
Создание Предметов (Картин): B - Хокусай может материализовывать вещи нарисованные ею. Хокусай Бросает кубик и призывает на поле один из вариантов на выбор:
Маунт: Призывает коня с ХП равным 6 + значение кубика
Защитные баррикады: Призывает 4 столпа на расстоянии 3 клеток от себя, должны находится на одной линии с ХП равным 5 + значение кубика
Клетка: Позволяет расширить игровое поле добавлением новой клетки с минимум двумя линиями к ней
Смена облика: Позволяет изменить свой облик без смены эффекта ассеншена
(Куллдаун - 10)
Создание Территории: Захватывает одну клетку и три клеток клетки вокруг неё. Все захваченные клетки становятся территорией на которой Магический урон никогда не понижается. Если при использовании создания предметов Хокусай стоит на поле то куллдаун будет 8, а не 10. Этот навык можно активировать лишь один раз
Божественность: B - Увеличивает свою силу на 3 очка на два хода (Куллдаун - 10)
КосмоПолёт - Если поле является космосом то может передвигаться на 3 дополнительные клетки
Личные Навыки:
1) Все в природе: A+ - Накладывает на себя уклонения до конца следующего хода, а так же заряжает свою шкалу фантазма на 2 очка (Кулдаун - 5)
2) Связь отца и дочери: A - Увеличивает свою силу на 3 очка на три хода, даёт иммунитет к снятию баффов и иммунитет к дебаффам на 3 хода (Кулдаун - 6)
3) Псевдоним: Внеземной осьминог: A - Накладывает на себя бафф на 3 хода при котором при каждой успешной атаке она накладывает понижение защиты на 2 на 3 хода и увеличивает свой шанс критических атак (1 и 6 на втором кубике считаются критическими атаками) на три хода. (Кулдаун - 7)
Небесный Фантазм: 
Тридцать шесть видов горы Фудзи: - Понижает защиту всех противников в радиусе 4 клеток на 2 очка на три хода после чего наносит им всем 6 урона, наносит на 4 урона больше по противникам с атрибутом Man
Понижает защиту всех противников в радиусе 4 клеток на 2 очка на три хода после чего наносит им всем 12 урона, наносит на 4 урона больше по противникам с атрибутом Man 


'''


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
var phantasm_charge=0
var attribute
var gender
var ascension_stage

var passive_skills=[
	{
		"Display Name":"Existence Outside the Domain",
		"Types":["Class Skill"],
		"Name":"Nullify Buff",
		"Types To Block":["Buff Decrease Damage"],
		"Duration":"Status"
	},
	{
		"Name":"Space Flight",
		"Types":["Buff Positive Effect"],
		"Duration":"Status",
		"Trigger":"Turn Started",
		"Effect On Trigger":
		{"Buffs":[
				{
					"Name":"Additional Move",
					"Power":3
				}
			],
			"Cast":"Self",
			"Cast Condition":{
				"Condition":"All",
				"Field":["Void"]
			}
		},
	}
]

var skills={
	"First Skill":{
		"Type":"Buff Granting",
		"Rank":"A+",
		"Cooldown":5,
		"Description ID":"First Skill",
		"Effect":[
			{"Buffs":[
				{
					"Name":"Evade",
					"Duration":1.5
				},
				{
					"Name":"NP Charge",
					"Power":2
				}
			],
			"Cast":"Self"}
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
					"Name":"ATK Up",
					"Duration":3,
					"Power":3
				},
				{
					"Name":"Removal Resist Up",
					"Duration":3
				},
				{
					"Name":"Debuff Immune",
					"Duration":3
				}
			],
			"Cast":"Self"}
		]
	},

	"Third Skill":{
		"Type":"Buff Granting", 
		"Rank":"A",
		"Cooldown":7,
		"Description ID":"Third Skill",
		"Effect":[
			{"Buffs":[
				{
					"Name":"Def Down on Attack",
					"Duration":3,
					"Trigger":"Success Attack",
					"Effect On Trigger":{
						"Buffs":[
							{
								"Name":"Def Down",
								"Duration":3,
								"Power":2
							}
						],
						"Cast":"Trigger Initiator"
					}
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

	"Class Skill 1":{
		"Type":"Item Creation",
		"Rank":"B",
		"Cooldown":10,
		"Description ID":"Item Creation",
		"Effect":[
			{
				"Choose Buff":{
					"Defensive Barricades":{
						"Description ID":"Summon Barriers",
						"Replace Value With Dice Result":[
							{
								"What To Replace":"UNIQ_VALUE",
								"Dice Name":"main_dice",
								"Description ID":"Replace Value With Dice Result for Summon Barriers",
								"Calculations":[
									{"Operation":"Add","Value":6},
									{"Operation":"Multiply","Value":1},
									{"Operation":"Substract","Value":0},
									{"Operation":"Divide","Value":1}
								],
								"Limit Minimum Value":0,
								"Limit Maximum Value":20
							}
						],
						"Buffs":[
							{
								"Name":"Summon",
								"Summon Name":"obstacle",#reqired
								"Disappear After Summoner Death":false,
								"Can Be Played":false,
								"Can Attack":false,
								"Can Evade":false,
								"Can Defence":false,
								"Can Parry":false,
								"Move Points":0,
								"Attack Points":0,
								"Limit":10,
								"Servant Data Location":"Sub",
								"Starting Buffs":[
									{
										"Name":"Maximum HP Set",
										"Power":"UNIQ_VALUE",
										"Type":"Status"
									}
								]
							}
						],
						"Cast":"Self"

					},
					"Mount":{
						"Description ID":"Summon Mount",
						"Replace Value With Dice Result":[
							{
								"What To Replace":"UNIQ_VALUE",
								"Dice Name":"main_dice",
								"Description ID":"Replace Value With Dice Result for Summon Mount",
								"Calculations":[
									{"Operation":"Add","Value":6},
									{"Operation":"Multiply","Value":1},
									{"Operation":"Substract","Value":0},
									{"Operation":"Divide","Value":1}
								],
								"Limit Minimum Value":0,
								"Limit Maximum Value":20
							}
						],
						"Buffs":[
							{#mount example
								"Name":"Summon",
								"Duration":3,
								"Summon Name":"horse",
								"Servant":false,
								"Skills Enabled":false,
								"One Time Skills":false,
								"Can Use Phantasm":false,
								"Disappear After Summoner Death":true,
								"Mount":true,
								"Require Riding Skill":false,
								"Can Be Played":false,
								"Can Attack":false,
								"Can Evade":true,
								"Can Defence":true,
								"Can Parry":false,
								"Move Points":2,
								"Attack Points":0,
								"Phantasm Points Farm":false,
								"Limit":3,
								"Servant Data Location":"Sub",
								"Starting Buffs":[
									{
										"Name":"Maximum HP Set",
										"Power":"UNIQ_VALUE",
										"Type":"Status"
									}
								]
							}
						],
						"Cast":"Self"

					},
					"Cell":{
						"Description ID":"Add Field Cell",
						"Buffs":[
							{
								"Name":"Create New Field Cell",
								#"Min Connections":2
							}
						],
						"Cast":"Self"

					},
					"Appearance Change":{
						"Description ID":"Appearance Change",
						"Buffs":[
							{
								"Name":"Appearance Change",
								"Duration":5
							}
						],
						"Cast":"Self"
					}
				}
			}
		]
	},

	"Class Skill 2":{
		"Type":"Buff Granting",
		"Rank":"D",
		"Cooldown":NAN,
		"Description ID":"Class Skill 2",
		"Effect":[
		{"Buffs":[
			{
				"Name":"Field Creation",
				"Amount":3,"Config":
				{
					"Unique ID":"Hokusai_Territory",
					"Ignore Magical Defence":true,
					"Additional":null}
				}
			],
		"Cast":"Self"}
		]
	},
	"Class Skill 3":{
		"Rank":"B",
		"Type":"Buff Granting",
		"Cooldown":10,
		"Description ID":"Class Skill 3",
		"Effect":[
			{"Buffs":[
				{
					"Name":"ATK Up",
					"Duration":2,
					"Power":3
				}
			],
			"Cast":"Self"}
		]
	},
}

var phantasms={
	"Thirty-Six Views of Mount Fuji":{
		"Rank":"B+",
		"Description ID":"Thirty-Six Views of Mount Fuji",
		"Overcharges":{
			"Default":{
				"Cost":6,
				"Attack Type":"All Enemies In Range",
				"Range":4,
				"Damage":6,
				"Effect Before Attack":[
					{"Buffs":[
						{
							"Name":"Def Down",
							"Duration":3,
							"Power":2
						}
					],
					"Cast":"targets"}
				],
				"Phantasm Buffs":[
					{
						"Name":"ATK Up Against Attribute",
						"Attribute":"Man", 
						"Power":4
					}
				]
			},
			"Overcharge":{
				"Cost":12,
				"Attack Type":"All Enemies In Range",
				"Range":4, 
				"Damage":12,
				"Effect Before Attack":[
					{"Buffs":[
						{
							"Name":"Def Down",
							"Duration":3,
							"Power":2
						}
					],
					"Cast":"targets"}
				],
				"Phantasm Buffs":[
					{
						"Name":"ATK Up Against Attribute",
						"Attribute":"Man",
						"Power":4
					}
				]
			}
		}
	}
}
var translation={
	"ru":{
		"First Skill":"Все в природе: A+ - Накладывает на себя уклонения до конца следующего хода, а так же заряжает свою шкалу фантазма на 2 очка (Кулдаун - 5)",
		"Second Skill":"Связь отца и дочери: A - Увеличивает свою силу на 3 очка на три хода, даёт иммунитет к снятию баффов и иммунитет к дебаффам на 3 хода (Кулдаун - 6)",
		"Third Skill":"Псевдоним: Внеземной осьминог: A - Накладывает на себя бафф на 3 хода при котором при каждой успешной атаке она накладывает понижение защиты на 2 на 3 хода и увеличивает свой шанс критических атак (1 и 6 на втором кубике считаются критическими атаками) на три хода. (Кулдаун - 7)",
		"Item Creation":"Создание Предметов (Картин): B - Хокусай может материализовывать вещи нарисованные ею. Хокусай Бросает кубик и призывает на поле один из вариантов на выбор:\nМаунт: Призывает коня с ХП равным 6 + значение кубика\nЗащитные баррикады: Призывает 4 столпа на расстоянии 3 клеток от себя, должны находится на одной линии с ХП равным 5 + значение кубика\nКлетка: Позволяет расширить игровое поле добавлением новой клетки с минимум двумя линиями к ней\nСмена облика: Позволяет изменить свой облик без смены эффекта ассеншена\n(Куллдаун - 10)",
		"Summon Barriers":"Защитные баррикады: Призывает 4 столпа на расстоянии 3 клеток от себя, должны находится на одной линии с ХП равным 5 + значение кубика (Куллдаун - 10)",
		"Replace Value With Dice Result for Summon Barriers":"Бросьте кубик и добавьте его значение к 5 чтобы получить ХП призываемых столпов.",
		"Summon Mount":"Маунт: Призывает коня с ХП равным 6 + значение кубика (Куллдаун - 10)",
		"Replace Value With Dice Result for Summon Mount":"Бросьте кубик и добавьте его значение к 6 чтобы получить ХП призываемого маунта.",
		"Add Field Cell":"Клетка: Позволяет расширить игровое поле добавлением новой клетки с минимум двумя линиями к ней (Куллдаун - 10)",
		"Appearance Change":"Смена облика: Позволяет изменить свой облик без смены эффекта ассеншена (Куллдаун - 10)",
		"Class Skill 2":"Создание Территории: Захватывает одну клетку и три клеток клетки вокруг неё. Все захваченные клетки становятся территорией на которой Магический урон никогда не понижается. Если при использовании создания предметов Хокусай стоит на поле то куллдаун будет 8, а не 10. Этот навык можно активировать лишь один раз",
		"Class Skill 3":"Божественность: B - Увеличивает свою силу на 3 очка на два хода (Куллдаун - 10)",
		"Thirty-Six Views of Mount Fuji":"Тридцать шесть видов горы Фудзи: - Понижает защиту всех противников в радиусе 4 клеток на 2 очка на три хода после чего наносит им всем 6 урона, наносит на 4 урона больше по противникам с атрибутом Man\nОверчардж: Понижает защиту всех противников в радиусе 4 клеток на 2 очка на три хода после чего наносит им всем 12 урона, наносит на 4 урона больше по противникам с атрибутом Man "
	},
	"en":{
		"First Skill":"All in Nature: A+ - Grants Evade until the end of the next turn and charges own Phantasm gauge by 2 points (Cooldown - 5)",
		"Second Skill":"Bond of Father and Daughter: A - Increases own Attack by 3 points for three turns, grants Buff Removal Immunity and Debuff Immunity for 3 turns (Cooldown - 6)",
		"Third Skill":"Alias: Extraterrestrial Octopus: A - Grants a buff for 3 turns that upon each successful attack applies Def Down by 2 for 3 turns and increases own Critical Hit Rate (1 and 6 on the second dice are considered critical hits) for three turns. (Cooldown - 7)",
		"Item Creation":"Item Creation (Paintings): B - Hokusai can materialize items she has drawn. Hokusai rolls a dice and summons one of the following options onto the field:\nMount: Summons a horse with HP equal to 6 + dice value\nDefensive Barricades: Summons 4 pillars at a distance of 3 cells from herself, must be in a line with HP equal to 5 + dice value\nCell: Allows to expand the playing field by adding a new cell with at least two connections to it\nAppearance Change: Allows to change her appearance without changing the ascension effect\n(Cooldown - 10)",
		"Summon Barriers":"Defensive Barricades: Summons 4 pillars at a distance of 3 cells from herself, must be in a line with HP equal to 5 + dice value (Cooldown - 10)",
		"Replace Value With Dice Result for Summon Barriers":"Roll a dice and add its value to 5 to get the HP of the summoned pillars.",
		"Summon Mount":"Mount: Summons a horse with HP equal to 6 + dice value (Cooldown - 10)",
		"Replace Value With Dice Result for Summon Mount":"Roll a dice and add its value to 6 to get the HP of the summoned mount.",
		"Add Field Cell":"Cell: Allows to expand the playing field by adding a new cell with at least two connections to it (Cooldown - 10)",
		"Appearance Change":"Appearance Change: Allows to change her appearance without changing the ascension effect (Cooldown - 10)",
		"Class Skill 2":"Territory Creation: Captures one cell and three cells around it. All captured cells become a territory where Magical damage is never reduced. If Hokusai is on the field when using Item Creation the cooldown will be 8 instead of 10. This skill can only be activated once",
		"Class Skill 3":"Divinity: B - Increases own Attack by 3 points for two turns (Cooldown - 10)",
		"Thirty-Six Views of Mount Fuji":"Thirty-Six Views of Mount Fuji: - Reduces the defense of all enemies within a radius of 4 cells by 2 points for three turns, then deals 6 damage to all of them, dealing 4 additional damage to enemies with the Man attribute\nOvercharge: Reduces the defense of all enemies within a radius of 4 cells by 2 points for three turns, then deals 12 damage to all of them, dealing 4 additional damage to enemies with the Man attribute"
	}
}
