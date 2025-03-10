extends Node

var host_or_user="host"
var connected_players=[]
var self_servant_node
var self_peer_id:int
var self_field_color:Color
var nickname:String
# Called when the node enters the scene tree for the first time.


const buffs_types={
	#exclusive buffs
	"Attack Range Set":["Buff Positive Effect","Buff Range Change"],
	"Attack Range Add":["Buff Positive Effect","Buff Range Change"],
	"Discharge Enemies NP":[],#instant
	"Discharge NP":[],
	"Discharge Allies NP":[],
	"Discharge Everyone NP":[],
	"Heal":[],#instant
	"Ignore DEF Buffs":["Buff Positive Effect","Buff Increase Damage"],
	"Ignore Defence":["Buff Positive Effect","Buff Increase Damage"],
	"Maximum Hits Per Turn":["Buff Negative Effect","Buff Decrease Damage"],
	"Magical Damage Get + Attack":["Buff Positive Effect","Buff Increase Damage"],
	"pull enemies on attack":["Buff Positive Effect","Buff Increase Damage"],
	"Critical Remove":["Buff Negative Effect","Buff Decrease Damage"],
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
	"Debuff Immune":["Buff Positive Effect", "Buff Negative Effect Immunity"],
	"Nullify Buff":["Buff Negative Effect","Buff Nullify Buff"],
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
	"Strong Burn":["Buff Negative Effect", "Buff Burn"],
	"Strong Poison":["Buff Negative Effect", "Buff Poison"],
	"Strong Curse":["Buff Negative Effect", "Buff Curse", "Curse"],
	"NP Strength Up":["Buff Positive Effect", "Buff Increase Damage","Buff Np Damage Up"],
	"NP Strength Up X":["Buff Positive Effect", "Buff Increase Damage","Buff Np Damage Up"],
	"NP Strength Down":["Buff Negative Effect","Buff Decrease Damage","Buff Np Damage Down"],
	"NP Strength Down X":["Buff Negative Effect","Buff Decrease Damage","Buff Np Damage Down"],
	#"NP Gain Each Turn":["Buff Positive Effect", "Buff Np Per Turn"],
	"NP Gain Up":["Buff Positive Effect"],
	"NP Gain Up X":["Buff Positive Effect"],
	"NP Seal":["Buff Negative Effect", "Buff Np Seal"],
	"Skill Seal":["Buff Negative Effect","Skill Seal"]	
	
	
	
	
}
