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


func _run():
	var script_full_path="res://servants/bunyan/bunyan.gd"
	#FileAccess.open(script_full_path, FileAccess.READ)
	var sc=load(script_full_path)
	#print(sc.source_code)
	var n=sc.new()
	n.skills={}
	print(n.skills)
	print(n.script.source_code)
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
