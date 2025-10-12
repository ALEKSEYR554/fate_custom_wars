extends Node2D

@onready var players_handler = self.get_parent()

"""
5S-058
(Вавилон)
Мировоззрение: Хаотично-Злая
Класс: Лансер
Имя: Эрешкигаль
Сила: А (5 очков урона)
Выносливость: В (Очки Жизни: 28)
Ловкость: D
Удача: В (+1 к выпавшему результату при активации Мгновенной Смерти)
Магия: В (Магическая Защита - 4)
Н.Фантазм: А
Классовые Навыки: 
Ядро Богини: Повышает свою силу на 3 очка на три хода. (Куллдаун - 9),
Создание Территории: Захватывает одну клетку и пять клеток вокруг неё. А также стоя на этих клетках Лансер поднимает свою шкалу фантазма на одну единицу раз в два хода. Этот навык можно активировать лишь один раз.,
Личные Навыки:
1) Скрытая Корона Величия: А - Даёт себе иммунитет к любым дебаффам до конца следующего хода, иммунитет к Мгновенной Смерти до конца следующего хода, и даёт неуязвимость до конца следующего хода (Куллдаун - 6)
2) Всплеск Маны: А+ - Увеличивает свою силу на 3 очка на один ход и увеличивает свою Шкалу Фантазма на 3 очка (Куллдаун - 7)
3) Защита Подземного Мира: ЕХ - Даёт себе и союзникам бафф Благословение Кур на три хода. А так же даёт следующие баффы:
Защита увеличивается вдвое,
Увеличивается накопление Шкалы Фантазма (При успешной атаке получаете 2 очка фантазма вместо 1),
Предел максимального здоровья увеличивается на 10,
(Куллдаун - 8)
Небесный Фантазм:
Kur Ki Gal Irkalla: Наносит 7 урона всем противникам в радиусе трёх клеток, после чего даёт всем союзникам с благословлением Кур следующие баффы на 3 хода: 
Иммунитет к дебаффам,
Иммунитет к мгновенной смерти,
Увеличивает силу на 3 очка,
Оверчардж: Наносит 14 урона всем противникам в радиусе трёх клеток, после чего даёт себе и союзникам следующие дебаффы на пять хода: 
Иммунитет к дебаффам,
Иммунитет к мгновенной смерти,
Увеличивает силу на 5 очков,


"""



const default_stats={
	"hp":28,
	"servant_class":"Lancer",
	"ideology":["Chaotic","Good"],
	"gender":"Female",
	"attribute":"Earth",
	"attack_range":2,#most lancers has range=2
	"attack_power":5,#check table info
	"strength":"A",
	"agility":"D",
	"endurance":"B",
	"luck":"B",
	"magic":{"Rank":"B","Power":0,"Resistance":4},#check table info
	"traits":["Costume-Owning", "Divinity", "Female", "Hominidae Servant", "Humanoid", "Immune to Pigify", "King", "Pseudo-Servant", "Servant", "Seven Knights Servant", "Weak to Enuma Elish"]
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
	"Cooldown":6,
	"Description ID":"First Skill",
	"Effect":[
		{"Buffs":[
			{
                "Name":"Nullify Buff",
                "Duration":1.5,
            },
            {
                "Name":"Instant-Kill Immunity",
                "Duration":1.5
            },
            {
                "Name":"Invincible",
                "Duration":1.5
            }
			],
			"Cast":"Self"}
		]
},

"Second Skill":{
	"Type":"Buff Granting",
	"Rank":"A+",
	"Cooldown":6,
	"Description ID":"Second Skill",
	
	"Effect":[
		{
            "Buffs":[
                {
                    "Name":"NP Charge",
                    "Power":3
                },
                {
                    "Name":"ATK Up",
                    "Power":3,
                    "Duration":1
                },
                {
                    "Name":"Reduce Skills Cooldown",
                    "Power":1
                }
            ],
		"Cast":"Self"}
		]
},

"Third Skill":{
	"Type":"Buff Granting",
	"Rank":"EX",
	"Cooldown":8,
	"Description ID":"Third Skill",
	
	"Effect":[
		{"Buffs":[
            {
                "Name":"Blessing of Kur",
                "Duration":3
            },
			{
                "Name":"Def Up X",
				"Duration":3,
				"Power":2
            },
            {
                "Name":"NP Gain Up",
                "Duration":3,
                "Power":1
            },
            {
                "Name":"Max HP Plus",
                "Duration":3,
                "Power":10
            }
			],
			"Cast":"all allies"}
		]
},
"Class Skill 1":{
	"Type":"Buff Granting",
	"Rank":"B",
	"Cooldown":9,
	"Description ID":"Class Skill 1",
	"Effect":[
		{"Buffs":
			[
				{
					"Name":"ATK Up",
					"Power":3,
					"Duration":3
				}
			],
		"Cast":"Self"}
		]
	}
}

var phantasms={
	"Kur Ki Gal Irkalla":{
		"Type":"Buff Granting",
		"Rank":"A",
		"Description ID":"Kur Ki Gal Irkalla",
		"Overcharges":{
		"Default":
			{"Cost":6,"Attack Type":"All Enemies In Range","Range":3,"Damage":7,
				"effect_after_attack":[
					{
						"Buffs":[
							{
								"Name":"ATK Up",
								"Duration":3,
								"Power":3
							},
							{
								"Name":"Nullify Debuff",
								"Duration":3,
							},
							{
								"Name":"Instant-Kill Immunity",
								"Duration":3
							},
						],
						"Cast":"all allies",
						"Cast Condition":{
							"Condition":"All",
							"Buff":["Blessing of Kur"]
						}
					}
                ]
            },
		"Overcharge":
			{"Cost":12,"Attack Type":"All Enemies In Range","Range":3,"Damage":14,
				"effect_after_attack":[
					{
						"Buffs":[
							{
								"Name":"ATK Up",
								"Duration":5,
								"Power":3
							},
							{
								"Name":"Nullify Debuff",
								"Duration":5,
							},
							{
								"Name":"Instant-Kill Immunity",
								"Duration":5
							},
						],
						"Cast":"all allies",
						"Cast Condition":{
							"Condition":"All",
							"Buff":["Blessing of Kur"]
						}
					}
                ]
            },
		}
	}
}





var translation={
	"en":{
		"First Skill":"Grants self immunity to all debuffs until end of next turn, immunity to Instant Death until end of next turn, and grants invinsibility until end of next turn (Cooldown - 6)",
		"Second Skill":"Increases your power by 3 points for one turn and increases your Phantasm Gauge by 3 points. Reduce skills cooldown for self (Cooldown - 6)",
		"Third Skill":"Grants herself and allies the Blessing of Kur buff for three turns. Also grants the following buffs:
		Doubles defence,
		Increase NP Gain (Upon a successful attack, you gain 2 phantasm points instead of 1),
		Increase Maximum HP by 10,
		(Cooldown - 8)",
		"Class Skill 1":"Goddess' Essence: Increases own power by 3 points for three turns. (Cooldown - 9)",
		"Kur Ki Gal Irkalla":"Kur Ki Gal Irkalla - Deals 7 damage to all enemies within a three-cell radius, then grants all allies with the Blessing of Kur the following buffs for 3 turns:
		Debuff Immunity,
		Instant Death Immunity,
		Increases Strength by 3 points,
		Overcharge: Deals 14 damage to all enemies within a three-cell radius, then grants itself and allies the following debuffs for 5 turns:
		Debuff Immunity,
		Instant Death Immunity,
		Increases Strength by 5 points"
	},
	"ru":{
		"First Skill":"Дает себе иммунитет ко всем дебаффам до конца следующего хода, иммунитет к Мгновенной Смерти до конца следующего хода и дает неуязвимость до конца следующего хода (Куллдаун - 6)",
		"Second Skill":"Увеличивает вашу силу на 3 очка на один ход и увеличивает вашу Шкалу Фантазма на 3 очка. Сокращает время перезарядки навыков для себя (Куллдаун - 6)",
		"Third Skill":"Дарует себе и союзникам бафф Благословения Кур на три хода. Также дарует следующие баффы:
		Удваивает защиту,
		Увеличивает Прирост Фантазма (При успешной атаке вы получаете 2 очка фантазма вместо 1),
		Увеличивает Максимальное Здоровье на 10,
		(Куллдаун - 8)",
		"Class Skill 1":"Сущность Богини: Увеличивает собственную силу на 3 очка на три хода. (Куллдаун - 9)",
		"Kur Ki Gal Irkalla":"Kur Ki Gal Irkalla - Наносит 7 урона всем врагам в радиусе трех клеток, затем дарует всем союзникам с Благословением Кур следующие баффы на 3 хода:
		Иммунитет к Дебаффам,
		Иммунитет к Мгновенной Смерти,
		Увеличивает Силу на 3 очка,
		Оверчардж: Наносит 14 урона всем врагам в радиусе трех клеток, затем дарует себе и союзникам следующие дебаффы на 5 ходов:
		Иммунитет к Дебаффам,
		Иммунитет к Мгновенной Смерти,
		Увеличивает Силу на 5 очков"
	}
}