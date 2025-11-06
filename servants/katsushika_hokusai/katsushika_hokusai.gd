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
    "traits":["Divine", "Hominidae Servant", "Humanoid", "Servant", "Weak to Enuma Elish"]
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
var phantasm_charge=0
var attribute
var gender
var ascension_stage

var passive_skills=[
    {
        "Display Name":"Existence Outside the Domain",
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
        "Description":"Everything in Nature: A+ - Applies evasion until the end of the next turn, and charges NP gauge by 2 points (Cooldown - 5)",
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
        "Description":"Father-Daughter Bond: A - Increases own strength by 3 points for three turns, grants immunity to buff removal and debuff immunity for 3 turns (Cooldown - 6)",
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
        "Description":"Alias: Foreign Octopus: A - Applies a buff for 3 turns where each successful attack applies defense down by 2 for 3 turns and increases critical hit chance (1 and 6 on second die count as critical hits) for three turns (Cooldown - 7)",
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
        "Description":"Item Creation (Paintings): B - Can materialize things she has painted",
        "Effect":[
            {"Choose Buff":{
                "Mount":{
                    "Buffs":[
                        {
                            "Name":"Summon Mount",
                            "HP Formula":"6 + dice"
                        }
                    ],
                    "Cast":"Self"
                },
                "Defensive Barricades":{
                    "Buffs":[
                        {
                            "Name":"Summon Barriers",
                            "Count":4,
                            "Range":3,
                            "HP Formula":"5 + dice"
                        }
                    ],
                    "Cast":"Self"
                },
                "Cell":{
                    "Buffs":[
                        {
                            "Name":"Add Field Cell",
                            "Min Connections":2
                        }
                    ],
                    "Cast":"Self"
                },
                "Appearance Change":{
                    "Buffs":[
                        {
                            "Name":"Change Appearance"
                        }
                    ],
                    "Cast":"Self"
                }
            }}
        ]
    },

    "Class Skill 2":{
        "Type":"Buff Granting",
        "Rank":"B",
        "Cooldown":0,
        "Description":"Territory Creation: Captures one cell and three cells around it. All captured cells become territory where Magic damage is never reduced.",
        "Effect":[
            {"Buffs":[
                {
                    "Name":"Create Territory",
                    "Range":1,
                    "AOE_Range":1,
                    "Effect":"No Magic Reduction",
                    "Uses":1
                }
            ],
            "Cast":"Self"}
        ]
    },
    "Class Skill 3":{
        "Rank":"B",
        "Type":"Buff Granting",
        "Cooldown":10,
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
        "Description":"Thirty-Six Views of Mount Fuji - Reduces defense of all opponents within 4 cells radius by 2 points for three turns and then deals 6 damage to them all, deals 4 more damage to opponents with Man attribute",
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