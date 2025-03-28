extends Node

var player_score = 0
var enemy_score = 0

func _progress_bar(p_score, e_score) -> void:
	var total_score = p_score + e_score
	if p_score != 0 && e_score != 0: 
		$ProgressBar.value = (p_score / total_score) * 100
		print("test")
