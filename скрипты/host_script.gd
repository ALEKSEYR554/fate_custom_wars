extends Node

var peer = ENetMultiplayerPeer.new()
const PORT = 9999
@onready var back_button = $"../Back_button"
@onready var button = $Button
@onready var game_start_button = $game_start_button
var game_field
@onready var nickname = $nickname
@onready var main_menu = $".."



func _ready():
	#game_field = load("res://game_field.tscn")
	pass

func _on_peer_connected(peer_id):
	print("%s just connected!" % peer_id)
	Globals.connected_players.append(peer_id)



func _on_button_button_up():
	if nickname.text=="":
		nickname.grab_focus()
		return
	Globals.nickname=nickname.text
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	back_button.free()
	button.disabled=true
	Globals.host_or_user="host"
	Globals.connected_players.append(1)
	pass # Replace with function body.


func _on_game_start_button_button_up():
	rpc("hide_main_menu")
	rpc("game_initiate")
	
	pass # Replace with function body.

@rpc("call_local")
func hide_main_menu():
	for i in get_tree().root.get_children():
		if i.name=="Main Menu":
			i.visible=false
	self.visible=false

@rpc("call_local")
func game_initiate():
	main_menu.game_initiate()
	return
	print("FUCK")
	var game_field_instanse=game_field.instantiate()
	get_tree().root.add_child(game_field_instanse)
	pass
