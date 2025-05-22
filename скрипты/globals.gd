extends Node

var host_or_user:String="host"
var connected_players:Array=[]#array of peer_id s
var self_servant_node:Node2D
var self_peer_id:int
var self_field_color:Color
var nickname:String
var debug_mode:bool=false
var peer_id_to_nickname:Dictionary={}
# Called when the node enters the scene tree for the first time.

const SKILL_COST_TYPES={NP="NP"}
const CLASS_NAMES:Array=[
	"Saber",
	"Archer",
	"Lancer",
	"Rider",
	"Caster",
	"Assassin",
	"Berserker",
	"Ruler",
	"Avenger",
	"Moon Cancer",
	"Alter Ego",
	"Foreigner",
	"Pretender",
	"Shielder",
	"Beast"
]
const buffs_types:Dictionary={
	#exclusive buffs
	"Attack Range Set":["Buff Positive Effect","Buff Increase Stat","Buff Range Change"],
	"Attack Range Add":["Buff Positive Effect","Buff Increase Stat","Buff Range Change"],
	"NP Discharge":["Instant"],#instant
	"Heal":["Instant"],#instant
	"HP Drain":["Instant"],
	"Debuff Removal":["Instant"],
	"NP Charge":["Instant"],#instant
	"Reduce Skills Cooldown":["Instant"],
	"Multiply NP":["Instant"],
	"Buff Removal":["Instant"],
	"Ignore DEF Buffs":["Buff Positive Effect","Buff Increase Damage"],
	"Ignore Defence":["Buff Positive Effect","Buff Increase Damage"],
	"Maximum Hits Per Turn":["Buff Negative Effect","Buff Decrease Damage"],
	"Magical Damage Get + Attack":["Buff Positive Effect","Buff Increase Damage"],
	"pull enemies on attack":["Buff Positive Effect","Buff Increase Damage"],
	"Critical Remove":["Buff Negative Effect","Buff Decrease Damage"],
	
	"Agility Add":["Buff Positive Effect","Buff Increase Stat"],
	"Agility Set":["Buff Positive Effect","Buff Increase Stat"],

	"Magical Attack Add":["Buff Positive Effect","Buff Increase Stat"],
	"Magical Attack Set":["Buff Positive Effect","Buff Increase Stat"],

	"Magical Defence Add":["Buff Positive Effect","Buff Increase Stat"],
	"Magical Defence Set":["Buff Positive Effect","Buff Increase Stat"],

	"Luck Add":["Buff Positive Effect","Buff Increase Stat"],
	"Luck Set":["Buff Positive Effect","Buff Increase Stat"],

	"Endurance Add":["Buff Positive Effect","Buff Increase Stat"],
	"Endurance Set":["Buff Positive Effect","Buff Increase Stat"],

	"Maximum HP Add":["Buff Positive Effect","Buff Increase Stat"],
	"Maximum HP Set":["Buff Positive Effect","Buff Increase Stat"],

	"Magic ATK Up":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"Magic ATK Up X":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	
	"ATK Up X Against Class":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Up Against Class":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],

	"ATK Up X Against Alignment":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Up Against Alignment":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],

	"Dice +":["Buff Positive Effect"],
	"Maximum Skills Per Turn":["Buff Positive Effect"],

	#FGO type buffs	
		
	"Def Up":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"Def Up X":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"Def Down":["Buff Negative Effect", "Buff Decrease Defence", "Buff Defence Down"],
	"Def Down X":["Buff Negative Effect", "Buff Decrease Defence", "Buff Defence Down"],
	"Def Up Against Trait":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"Def Up X Against Trait":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"Def Down Against Trait":["Buff Negative Effect", "Buff Decrease Defence", "Buff Defence Down"],
	"Def Down X Against Trait":["Buff Negative Effect", "Buff Decrease Defence", "Buff Defence Down"],
	"Invincible":["Buff Positive Effect","Buff Evade And Invincible","Buff Invincible","Buff Increase Defence"],
	"Evade":["Buff Positive Effect", "Buff Evade And Invincible","Buff Evade"],
	"Critical Hit Rate Up":["Buff Positive Effect", "Buff Increase Damage", "Buff Crit Rate Up"],
	# "Crit Chances":[1,3,6]
	
	"Critical Strength Up":["Buff Positive Effect", "Buff Increase Damage", "Buff Crit Damage Up"],
	"Critical Strength Up X":["Buff Positive Effect", "Buff Increase Damage", "Buff Crit Damage Up"],
	"Guts":["Buff Positive Effect", "Buff Guts"],
	"ATK Up":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Down":["Buff Negative Effect", "Buff Decrease Damage", "Buff Atk Down"],
	"ATK Up X":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Down X":["Buff Negative Effect", "Buff Decrease Damage", "Buff Atk Down"],
	"ATK Up Against Trait":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Up X Against Trait":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Down Against Trait":["Buff Negative Effect", "Buff Decrease Damage", "Buff Atk Down"],
	"ATK Down X Against Trait":["Buff Negative Effect", "Buff Decrease Damage", "Buff Atk Down"],
	"HP Recovery Up":["Buff Positive Effect","Buff Hp Recovery Per Turn"],
	"HP Recovery Up X":["Buff Positive Effect","Buff Hp Recovery Per Turn"],
	#"Restore HP Each Turn":["Buff Positive Effect"],
	"Poison":["Buff Negative Effect", "Buff Poison"],
	"Burn":["Buff Negative Effect", "Buff Burn"],
	"Curse":["Buff Negative Effect", "Buff Curse", "Curse"],
	"Stun":["Buff Negative Effect", "Buff Stun", "Buff Immobilize"],
	"NP Strength Up":["Buff Positive Effect", "Buff Increase Damage","Buff Np Damage Up"],
	"NP Strength Up X":["Buff Positive Effect", "Buff Increase Damage","Buff Np Damage Up"],
	"NP Strength Down":["Buff Negative Effect","Buff Decrease Damage","Buff Np Damage Down"],
	"NP Strength Down X":["Buff Negative Effect","Buff Decrease Damage","Buff Np Damage Down"],
	#"NP Gain Each Turn":["Buff Positive Effect", "Buff Np Per Turn"],
	"NP Gain Up":["Buff Positive Effect"],
	"NP Gain Up X":["Buff Positive Effect"],
	"NP Seal":["Buff Negative Effect", "Buff Np Seal"],
	"Skill Seal":["Buff Negative Effect","Skill Seal"],
	
	
	"Buff Block":["Buff Negative Effect", "Buff Nullify Buff"],
	"Restore HP Each Turn":["Buff Positive Effect","Buff Hp Recovery Per Turn"],
	"Class Change":["Buff Positive Effect"],
	"Nullify Buff":["Buff Negative Effect","Buff Nullify Buff"],
	"Nullify Debuff":["Buff Positive Effect", "Buff Negative Effect Immunity"],
	"Trait Set":["Buff Positive Effect"],
	"Faceless Moon":["Buff Positive Effect","Buff Lock Cards Deck"],
	"Ignore Defense":["Buff Positive Effect" ,"Buff Increase Damage"],
	"Ignore Invincible":["Buff Positive Effect", "Buff Invincible Pierce" ,"Buff Increase Damage"],
	"Max HP Plus":["Buff Positive Effect","Buff Max Hp Up"],
	"NP Gain When Damaged":["Buff Positive Effect"],
	"Overcharge Up":["Buff Positive Effect"],
	"NP Damage Def Up":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"NP Damage Def Up X":["Buff Positive Effect", "Buff Increase Defence", "Buff Defence Up", "Buff Def Up"],
	"NP Gain Each Turn":["Buff Positive Effect", "Buff Np Per Turn"],
	"Buff Removal Resist":["Buff Positive Effect"],
	"Paralysis":["Buff Negative Effect","Buff Paralysis", "Buff Immobilize"],
	"Sure Hit":["Buff Positive Effect","Buff Sure Hit","Buff Increase Damage"]
	
}
