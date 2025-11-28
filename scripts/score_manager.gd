extends Node

## ScoreManager - Handles scoring and high score persistence

signal score_changed(new_score: int)
signal high_score_changed(new_high_score: int)

# Score values
var current_score: int = 0
var high_score: int = 0

# Save file path
const SAVE_PATH: String = "user://score_data.save"

func _ready() -> void:
	load_high_score()
	print("ScoreManager initialized. High score: ", high_score)

## Add score with optional perfect flag
func add_score(points: int, is_perfect: bool = false) -> void:
	current_score += points
	score_changed.emit(current_score)
	
	# Check for new high score during gameplay
	if current_score > high_score:
		high_score = current_score
		high_score_changed.emit(high_score)

## Reset score for new game
func reset_score() -> void:
	current_score = 0
	score_changed.emit(current_score)

## Save high score to local storage
func save_high_score() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file:
		var save_data = {
			"high_score": high_score
		}
		save_file.store_var(save_data)
		save_file.close()
		print("High score saved: ", high_score)
	else:
		print("Error saving high score!")

## Load high score from local storage
func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			if save_data is Dictionary:
				high_score = save_data.get("high_score", 0)
				print("High score loaded: ", high_score)
	else:
		high_score = 0

## Get formatted score string
func get_score_text() -> String:
	return str(current_score)

## Get formatted high score string
func get_high_score_text() -> String:
	return str(high_score)

## Check if current score is a new high score
func is_new_high_score() -> bool:
	return current_score >= high_score and current_score > 0
