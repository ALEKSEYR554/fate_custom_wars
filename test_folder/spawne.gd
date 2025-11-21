extends Node2D

var peer = ENetMultiplayerPeer.new()

const BASE_SERVANT = preload("res://scenes/base_servant.tscn")
func _on_host_button_2_pressed() -> void:
	var error = peer.create_server(9999)
	
	if error != OK:
		return
	$Control/VBoxContainer/host_Button2.disabled=true
	multiplayer.multiplayer_peer = peer
	
	var player=BASE_SERVANT.instantiate()
	player.set_script(load("res://scripts/base_servant.gd"))
	#var text=bun.get_node("%servant_sprite_textRect")
	add_child(player)
	player.image_path="bunyan/sprite_stage_1_costume_1.png"
	player.script_path="bunyan/bunyan.gd"
	
	var servant_script_to_get_stats=load(Globals.user_folder+'/servants/'+player.script_path).new()

	player.default_stats=servant_script_to_get_stats.default_stats.duplicate(true)


	player.servant_class=player.default_stats["servant_class"]
	player.ideology=player.default_stats["ideology"]
	player.attack_range=player.default_stats["attack_range"]
	player.attack_power=player.default_stats["attack_power"]
	player.agility=player.default_stats["agility"]
	player.endurance=player.default_stats["endurance"]
	player.hp=player.default_stats["hp"]
	player.magic=player.default_stats["magic"]
	player.luck=player.default_stats["luck"]
	player.traits=player.default_stats["traits"]
	player.attribute=player.default_stats["attribute"]
	player.gender=player.default_stats["gender"]
	player.strength=player.default_stats["strength"]
	
	
	
	player.position=Vector2(300,300)
	pass # Replace with function body.


func _on_connect_button_pressed() -> void:
	var ip = "127.0.0.1"
	var port:int = 9999
	
	
	var error = peer.create_client(ip, port)
	if error != OK:
			#OS.alert("Failed to create client. Error: " + str(error), "Client Error")
			#connect_button.disabled = false
			#nickname_edit.editable=true
			#port_entry.editable=true
			#ip_entry.editable=true
		return
	multiplayer.multiplayer_peer = peer
	$Control/VBoxContainer/connect_Button.disabled=true
	
