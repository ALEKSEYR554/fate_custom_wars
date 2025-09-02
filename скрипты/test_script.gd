@tool
extends EditorScript


func _run():
	pass
	
	var summon_buff_info={
				"Name":"Summon",
				"Duration":3,
				"Summon Name":"Rama",
				"Skills Enabled":false,
				"One Time Skills":false,
				"Can Use Phantasm":false,
				"Disappear After Summoner Death":true,
				"Mount":false,
				"Can Attack":true,
				"Can Evade":true,
				"Can Defence":true,
				"Move Points":1,
				"Attack Points":1,
				"Phantasm Points Farm":false,
				"Limit":4,
				"Servant Data Location":"Main"
			}
	
	var buff_info_stringify=str(summon_buff_info)
	var ctx = HashingContext.new()
	var buffer = buff_info_stringify.to_utf8_buffer()
	ctx.start(HashingContext.HASH_MD5)
	ctx.update(buffer)
	var unique_id_trait = ctx.finish()
	print(str(unique_id_trait.hex_encode()))
	#print("1acbd156-6b30-439e-a6d1-b97f298ac0e7")
	
