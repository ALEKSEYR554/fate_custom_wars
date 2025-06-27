extends Node
#self peer unique id

var menu_left:bool=false

var self_pu_id: String = ""

var self_nickname: String = "Player"

const PUID_SAVE_PATH = "user://persistent_game_id.dat"

var is_game_started:bool=false

# Информация обо всех игроках. Ключ: persistent_id
# Значение: Словарь {"nickname": str, "current_peer_id": int, "is_connected": bool, "servant_name": str, "servant_node": Node, "servant_node_name":str, "disconnected_more_than_timeout":bool}
var pu_id_player_info: Dictionary = {}

var peer_to_persistent_id: Dictionary = {}

var peer_id_to_kletka_number={}

var characters:Array=[]

var DEFAULT_PORT = 9999
const RECONNECT_ATTEMPT_DELAY: float = 2.0 # секунды
const MAX_RECONNECT_ATTEMPTS: int = 5
const PLAYER_DISCONNECT_TIMEOUT: float = 30.0

const UUID = preload("res://скрипты/uuid/uuid.gd")
signal player_list_changed # Сигнал для UI и других систем о том, что список игроков обновился
signal connection_status_changed(is_connected: bool) # Для клиента, чтобы знать статус соединения


signal someone_status_changed(puid:String,disconnected:bool,full_timeout:bool)

signal reconnect_requested

signal disconnection_request

func get_connected_persistent_ids() -> Array:
	var connected_puids: Array = []
	for puid in pu_id_player_info:
		if pu_id_player_info[puid].is_connected:
			connected_puids.append(puid)
	return connected_puids

func get_self_peer_id() -> int:
	if self_pu_id in pu_id_player_info and pu_id_player_info[self_pu_id].is_connected:
		return pu_id_player_info[self_pu_id].current_peer_id
	return multiplayer.get_unique_id()

func _ready():
	self_pu_id=self_pu_id
	someone_status_changed.connect(status_changed)
	_load_or_generate_persistent_id()
	print("My Persistent ID (PUID): ", self_pu_id)
	preload_all_servant_sprites()


func preload_all_servant_sprites():
	print(str("\n\n\n EDITOR=",OS.has_feature("editor")," \n\n"))
	#$FileDialog.root_subfolder = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	if !OS.has_feature("editor"):
		print("servant selection type Compiled")
		var count=1
		characters =[]
		var dir = DirAccess.open(Globals.user_folder+"servants/")
		print(OS.get_user_data_dir())
		for folder in dir.get_directories():
			print("appending characters\n")
			#var img = Image.new()
			var img=ResourceLoader.load(Globals.user_folder+"servants/"+str(folder)+"/sprite.png").get_image()
			#img=ImageTexture.create_from_image(img)
			characters.append({"Name":folder,"image":img, "Text": "Character "+str(count)+" Description "})
			print("characters="+str(characters))
	else:
		#editor
		characters=[]
		print("servant selection type Editor")
		for folder in ["bunyan","el_melloy","gray","hakuno_female","summer_bb","tamamo","ereshkigal_lancer","jaguar_man"]:
			#var img = Image.new()
			print("folder=","res://servants/"+str(folder)+"/sprite.png")
			var img=ResourceLoader.load("res://servants/"+str(folder)+"/sprite.png").get_image()
			print(img)
			#img=ImageTexture.create_from_image(img)
			characters.append({"Name":folder,"image":img, "Text": "Character "+str(folder)+" Description "})
	pass

func status_changed(puid:String,status:bool):
	pass
	var string_of_timed_out=""

	for pu_id in pu_id_player_info:
		var connected_status=pu_id_player_info[pu_id]["is_connected"]
		var time_out=pu_id_player_info[pu_id]["disconnected_more_than_timeout"]
		if not connected_status:
			if not time_out:
				string_of_timed_out+=str("\nwaiting for ", pu_id_player_info[pu_id]["nickname"])
	var field_node:Node=get_tree().get_root().find_child("game_field")
	if field_node!=null:
		field_node.call_deferred("disconnect_alert_show",puid,status,string_of_timed_out)
		field_node.call_deferred("set_pause",not status)


func _generate_new_puid() -> String:
	return UUID.v4() # Для Godot 4


func _load_or_generate_persistent_id():
	print("_load_or_generate_persistent_id\n\n")
	var file = FileAccess.open(PUID_SAVE_PATH, FileAccess.READ)

	print(file)
	if file:
		self_pu_id = file.get_line().strip_edges()
		print("self_pu_id=",self_pu_id)
		file.close()
		if not self_pu_id.is_empty() and not OS.has_feature("editor"):
			print("Loaded Persistent ID: ", self_pu_id)
			return

	# Если файл не существует, пуст, или ID некорректен, генерируем новый
	self_pu_id = _generate_new_puid()
	file = FileAccess.open(PUID_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(self_pu_id)
		file.close()
		print("Generated and saved new Persistent ID: ", self_pu_id)
	else:
		push_error("Failed to save Persistent ID to: " + PUID_SAVE_PATH)

		if self_pu_id.is_empty(): # Если генерация выше тоже дала пустую строку
			self_pu_id = "temp_puid_" + str(Time.get_ticks_msec())


var host_or_user:String="user"
var connected_players:Array=[]#array of peer_id s
var self_servant_node:Node2D
var self_peer_id:int
var self_field_color:Color
var nickname:String
var debug_mode:bool=false
var pu_id_to_nickname:Dictionary={}

var user_folder="user://"
# Called when the node enters the scene tree for the first time.

const ranks:Array = [
	"EX",
	"A+++", "A++", "A+", "A", "A-",
	"B+++", "B++", "B+", "B","B-",
	"C+++", "C++", "C+", "C","C-",
	"D+++", "D++", "D+", "D","D-",
	"E+++",  "E++", "E+", "E", "E-"
]

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
	"NP Discharge":["Instant","NP Discharge"],#instant
	"Absorb Buffs":["Buff Positive Effect","Absorb Buffs"],
	"Heal":["Instant","Heal"],#instant
	"HP Drain":["Instant","HP Drain"],
	"Debuff Removal":["Instant","Debuff Removal"],
	"NP Charge":["Instant","NP Charge"],#instant
	"Reduce Skills Cooldown":["Instant"],
	"Multiply NP":["Instant","Multiply NP"],
	"Buff Removal":["Instant"],
	"Madness Enhancement":[],
	"Presence Concealment":["Instant","Presence Concealment"],

	"Ignore DEF Buffs":["Buff Positive Effect","Buff Increase Damage"],
	"Ignore Defence":["Buff Positive Effect","Buff Increase Damage"],
	"Ignore Evade":["Buff Positive Effect","Buff Increase Damage"],

	"Maximum Hits Per Turn":["Buff Negative Effect","Buff Decrease Damage"],
	"Magical Damage Get + Attack":["Buff Positive Effect","Buff Increase Damage"],
	"pull enemies on attack":["Buff Positive Effect","Buff Increase Damage"],
	"Critical Remove":["Buff Negative Effect","Buff Decrease Damage","Crit Block"],
	
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

	"ATK Up X Against Gender":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Up Against Gender":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],

	"ATK Up X Against Attribute":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],
	"ATK Up Against Attribute":["Buff Positive Effect","Buff Increase Damage","Buff Atk Up"],


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
	
	"Blessing of Kur":["Buff Positive Effect"],
	"Instant-Kill Immunity":["Buff Positive Effect"],
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
