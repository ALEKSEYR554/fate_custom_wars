extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":2,
	"servant_class":"Caster",
	"ideology":["Lawful","Good"],
	"gender":"Male",
	"attribute":"Human",
	"attack_range":1,
	"attack_power":1,
	"strength":"D",
	"agility":"D",
	"endurance":"D",
	"luck":"D",
	"magic":{"Rank":"D","Power":3,"Resistance":1},
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
	
},

"Second Skill":{
	
},

"Third Skill":{
	
},

}
var phantasms={

}

