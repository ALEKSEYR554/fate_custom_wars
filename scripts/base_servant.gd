extends Node2D

@onready var servant_sprite_text_rect: TextureRect = %servant_sprite_textRect
@onready var buff_name_label: Label = %buff_name_label
@onready var effect_layer_text_rect: TextureRect = %effect_layer_textRect

const BASE_SERVANT = preload("res://scenes/base_servant.tscn")

#region servant stats
var default_stats

var servant_class
var ideology
var attack_range
var attack_power
var agility#ловкость
var endurance#вынослиость
var hp
var luck
var magic 
var buffs=[]
var skill_cooldowns=[]# 0,1,2 - личные навыки, все далее это классовые
var additional_moves=0
var additional_attack=0
var traits
var strength
var phantasm_charge=0
var attribute
var gender
var ascension_stage

var skills
var phantasms
var translation
var passive_skills
#endregion

#region summon stats
var servant:bool = true

var skills_enabled:bool=true
var one_time_skills:bool = false
var can_use_phantasm:bool = true
var disappear_after_summoner_death:bool = false
var mount:bool = false
var require_riding_skill:bool = false
var can_attack:bool = true
var can_evade:bool = true
var can_parry:bool = true
var can_defence:bool = true
var move_points:int = 0
var attack_points:int = 0
var phantasm_points_farm:bool = false
var can_be_played:bool = true

var summoner_char_infodic:Dictionary={}

var skill_uniq_summon_id = ""
var summon_check = false
#endregion

#region useful
var unit_id = -1
var owner_pu_id = "pu_id"
var pu_id = "pu_id"

var CharInfoDic = {}

var unit_unique_id = "get_id_from_hostt"

var servant_path = ""

var servant_name = "servant_name"

var servant_name_just_name = ""
var total_dead = true
var mounted_by_uniq_ids_array =[]
var mounts_uniq_id_array=[]

#endregion

signal image_got(image_data)

var image_path:String="":#"bunyan/sprite.png"
	set(value):
		image_path=value
		on_image_path_set()
	get:
		return image_path

var script_path:String="":#"bunyan/bunyan.png"
	set(value):
		script_path=value
		on_script_path_set()
	get:
		return script_path

signal script_get(script_code)

func on_script_path_set():
	print("\n\n---on_script_path_set---")
	
	var full_path=Globals.user_folder+'/servants/'+script_path
	print("script_path=",script_path," full_path=",full_path)
	
	var script:GDScript=load(full_path)
	if script:
		pass
	else:
		rpc("request_script_from_host",full_path)
		var script_source = await script_get
		script = GDScript.new()
		script.set_source_code(script_source)
	
	var temp_servant=script.new()
	
	skills=temp_servant.skills.duplicate(true)
	phantasms=temp_servant.phantasms.duplicate(true)
	if "passive_skills" in temp_servant:
		passive_skills=temp_servant.passive_skills.duplicate(true)
	translation=temp_servant.translation.duplicate(true)

	
	if self.get_parent():
		var players_handler = get_parent()
		if players_handler.name=="players_handler":
		
			players_handler.add_servants_translations_for_servant_name(self,servant_path,servant_name_just_name)
			players_handler.apply_all_translation_codes(self)

	print("---on_script_path_set ENDED---\n\n")

@rpc("any_peer","call_local","reliable")
func request_script_from_host(path):
	var script=load(path)
	rpc("get_script_to_client",script.source_code)
	pass

@rpc("authority","call_local","reliable")
func get_script_to_client(script_text):
	await get_tree().create_timer(0.1).timeout
	script_get.emit(script_text)

func on_image_path_set():
	var img:Image
	print("Globals.local_path_to_servant_sprite=",Globals.local_path_to_servant_sprite," image_path=",image_path)
	if Globals.local_path_to_servant_sprite.has(image_path):
		img = Globals.local_path_to_servant_sprite[image_path]
	else:
		rpc("request_image_from_host",image_path)
		img = await image_got
		img = Image.create_from_data(img["width"], img["height"], img["mipmaps"], img["format"], img["data"])
		Globals.local_path_to_servant_sprite[image_path]=img
	
	if is_instance_valid(servant_sprite_text_rect):
		servant_sprite_text_rect.texture=ImageTexture.create_from_image(img)


@rpc("any_peer","call_local","reliable")
func request_image_from_host(image_path_to_request)->void:
	var full_path=Globals.user_folder+'/servants/'+image_path_to_request
	
	var image = Image.new()
	image.load(full_path)

	var imageData = image.data
	imageData["format"] = image.get_format()
	
	rpc("get_image_to_client",imageData)
	pass


@rpc("authority","call_local","reliable")
func get_image_to_client(image_data):
	await get_tree().create_timer(0.1).timeout
	image_got.emit(image_data)



func _init() -> void:
	var ch=""
	
