extends Node

@onready var ip_entry:LineEdit = %IP
@onready var connect_button:Button = %connect
@onready var port_entry:LineEdit = %Port
@onready var nickname_edit:LineEdit = %nickname
@onready var back_button:Button = $"../Back_button"
@onready var main_menu = $".."
@onready var host_scene = $"../Host_scene"

var peer = ENetMultiplayerPeer.new()
var is_intentionally_disconnecting: bool = false
var connection_attempts: int = 0
var reconnect_timer: Timer

func _ready():
	nickname_edit.max_length = Globals.MAX_NICKNAME_SIZE
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(server_disconnect)
	Globals.reconnect_requested.connect(_attempt_reconnect)


func server_disconnect():
	connect_button.disabled=false
	Globals.connection_lost.emit(true)

func _attempt_reconnect(attempts:int=5):
	var ip = ip_entry.text
	var port:int = int(port_entry.text)
	
	
	for i in range(attempts):
		var error = peer.create_client(ip, port)
		if error != OK:
			#OS.alert("Failed to create client. Error: " + str(error), "Client Error")
			#connect_button.disabled = false
			#nickname_edit.editable=true
			#port_entry.editable=true
			#ip_entry.editable=true
			attempts+=1
			pass
		break
		
	if is_instance_valid(back_button): back_button.queue_free()
	multiplayer.multiplayer_peer = peer
	Globals.self_nickname=nickname_edit.text




func _on_connect_pressed() -> void:
	if nickname_edit.text.is_empty():
		nickname_edit.grab_focus()
		return
	
	var ip = ip_entry.text
	var port:int = int(port_entry.text)

	if ip.is_empty():
		ip_entry.grab_focus()
		return
	
	if port_entry.text.is_empty():
		port_entry.grab_focus()
		return
	
	connect_button.text="Connecting..."
	connect_button.disabled=true
	var error = peer.create_client(ip, port)
	
	if error != OK:
		#OS.alert("Failed to create client. Error: " + str(error), "Client Error")
		connect_button.disabled = false
		nickname_edit.editable=true
		port_entry.editable=true
		ip_entry.editable=true
		
		return
		
	if is_instance_valid(back_button): back_button.queue_free()
	multiplayer.multiplayer_peer = peer
	Globals.self_nickname=nickname_edit.text
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ENTER and event.pressed:
			_on_connect_pressed()
	
func connection_failed()->void:
	connect_button.disabled=false
	connect_button.text="Connection Failed"
	pass

func connected_to_server()->void:
	connect_button.text="Connected"
	connect_button.disabled=true
	nickname_edit.editable=false
	host_scene.rpc("user_requested_registration",Globals.self_pu_id,nickname_edit.text)
	pass

@rpc("authority","call_local","reliable")
func registration_complete(pu_id:String,pu_id_info:Dictionary)->void:
	Globals.pu_id_player_info[pu_id]=pu_id_info.duplicate()
	pass
