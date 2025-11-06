extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":15,
	"servant_class":"Rider",
	"ideology":["Horse"],
	"gender":"Male",
	"attribute":"Horse",
	"attack_range":0,
	"attack_power":0,
	"strength":"C",
	"agility":"C",
	"endurance":"C",
	"luck":"C",
	"magic":{"Rank":"C","Power":0,"Resistance":0},
	"traits":["Mount"]
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



var skills={
"First Skill":{

},

"Second Skill":{

},

"Third Skill":{

}

}
var phantasms={

}


