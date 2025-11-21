@tool
extends EditorScript

# Массив всех возможных рангов в порядке убывания силы.
# Он используется только для тестового цикла в _ready().
const RANKS = [
	"EX", "A+++", "A++", "A+", "A", "A-",
	"B+++", "B++", "B+", "B", "B-",
	"C+++", "C++", "C+", "C", "C-",
	"D+++", "D++", "D+", "D", "D-",
	"E+++", "E++", "E+", "E", "E-"
]

func split_array(array,amount_of_arrays)->Array:
	if amount_of_arrays>=array.size():
		return [array]
	var out_array=[]
	out_array.resize(amount_of_arrays)
	for i in amount_of_arrays:
		out_array[i]=[]
	for i in array.size():
		out_array[i%amount_of_arrays].append(array[i])
	return out_array
	
	
const BASE_SERVANT = preload("res://scenes/base_servant.tscn")
func _run():
	const TEXTURE_SIZE:int=200
	#print("--- Запуск проверки всех комбинаций ловкости (версия для Godot 4) ---")
	#for self_rank in RANKS:
#		for attacker_rank in RANKS:
#			var bonus = calculate_agility_bonus(self_rank, attacker_rank)
#			if bonus > 0:
#				print("Я: %-4s против Враг: %-4s -> Бонус: %d" % [self_rank, attacker_rank, bonus])
#	print("--- Проверка завершена ---")
	var ch=load("res://command_spells/ass 1.png1")
	if ch:
		print("ch=loaded")
	else:
		print("ch=error")
	#var servant=Node2D.new()
	##servant.set_script(load("res://servants/katsushika_hokusai/katsushika_hokusai.gd"))
	#print(servant.default_stats)
	##print(servant.default_stats.get("hp"))
	pass


# Основная функция для расчета прибавки к ловкости
func calculate_agility_bonus(self_agility_rank: String, attacker_agility_rank: String) -> int:
	var parse_rank = func(rank_str: String) -> Dictionary:
		if rank_str == "EX":
			return {"letter": "EX", "value": 5, "pluses": 0}
			
		var letter: String = rank_str[0]
		var value: int = 0
		
		match letter:
			"A": value = 4
			"B": value = 3
			"C": value = 2
			"D": value = 1
			"E": value = 0
			
		var pluses = rank_str.count("+")
		return {"letter": letter, "value": value, "pluses": pluses}
	# ==========================================================

	var self_data = parse_rank.call(self_agility_rank)
	var attacker_data = parse_rank.call(attacker_agility_rank)
	
	var bonus: int = 0
	
	if self_data.value > attacker_data.value:
		match self_data.letter:
			"EX":
				match attacker_data.letter:
					"A": bonus = 1
					"B": bonus = 2
					_: bonus = 3 # Против C, D, E
			"A":
				match attacker_data.letter:
					"B": bonus = 1
					_: bonus = 2 # Против C, D, E
			"B":
				bonus = 1 # Против C, D, E
				
	elif self_data.value == attacker_data.value:
		bonus = max(0, self_data.pluses - attacker_data.pluses)
	return bonus
