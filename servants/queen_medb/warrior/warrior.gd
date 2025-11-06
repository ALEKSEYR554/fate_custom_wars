extends Node2D

@onready var players_handler = self.get_parent()

const default_stats={
	"hp":2,
	"servant_class":"Assasin",
	"ideology":["Lawful","Good"],
	"gender":"Male",
	"attribute":"Human",
	"attack_range":1,
	"attack_power":2,
	"strength":"D",
	"agility":"D",
	"endurance":"D",
	"luck":"D",
	"magic":{"Rank":"D","Power":0,"Resistance":0},
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
var ascension_stage
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
	traits=default_stats["traits"]
	attribute=default_stats["attribute"]
	gender=default_stats["gender"]
	strength=default_stats["strength"]
	for i in skills.size():
		skill_cooldowns.append(0)
	pass # Replace with function body.


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

