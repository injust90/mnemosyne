extends Node2D

var Enemy = preload("res://scenes/enemy.tscn")

@onready var enemy_container = $EnemyContainer
@onready var spawn_container = $SpawnContainer
@onready var spawn_timer = $SpawnTimer
@onready var difficulty_timer = $DifficultyTimer

@onready var difficulty_value = $CanvasLayer/VBoxContainer/BottomRow/HBoxContainer/DifficultyLabel
@onready var killed_value = $CanvasLayer/VBoxContainer/TopRow2/TopRow/EnemiesKilledValue
@onready var game_over_screen = $CanvasLayer/GameOverScreen

# var to "lock in" to the desired enemy
var active_enemy = null
var current_letter_index: int = -1

var difficulty: int = 1
var enemies_killed = 0

func _ready() -> void:
	start_game()
	

# Find a new active enemy, set index, set character, return to break out			
func find_new_active_enemy(typed_character: String):
	# Go through and if enemy's prompt is equal, set to enemy found
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()		
		var next_character = prompt.substr(0, 1)
		# var next_character = prompt.substr(0, 1).to_lower()
		print("next_character " + next_character)
		# Is the character is the same one that was typed?
		if next_character == typed_character:
			current_letter_index = 1
			print("Found new enemy that starts with %s" % next_character)
			active_enemy = enemy
			active_enemy.set_next_character(current_letter_index)
			return
			
func _unhandled_input(event: InputEvent) -> void:
	# only fires when we get input and the key is pressed to prevent held down keystrokes
	if event is InputEventKey and not event.is_pressed():
		# use this variable for better autocompletion
		var typed_event = event as InputEventKey
		# get the letter the user types
		var key_typed: String = typed_event.as_text_keycode().to_lower()
		
		# find an active enemy 
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
				print("successfully typed %s" % key_typed)
				current_letter_index += 1	
				active_enemy.set_next_character(current_letter_index)
				# Resets our enemy
				if current_letter_index == prompt.length():
					print("DONE!")
					active_enemy.queue_free()
					active_enemy = null
					enemies_killed += 1
					killed_value.text = str(enemies_killed)
			else:
				print("Incorrectly typed %s instead of %s" % [key_typed, next_character])

func _on_spawn_timer_timeout() -> void:
	spawn_enemy()
	
func spawn_enemy(): 
	var enemy_instance = Enemy.instantiate()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)


func _on_difficulty_timer_timeout() -> void:
	print("Timer fired!")
	# TODO Difficulty is set but the signal is declared and won't be used
	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	print("Difficulty increased to %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)


func _on_lose_area_body_entered(body: Node2D) -> void:
	game_over()
	
func game_over():
	game_over_screen.show()
	spawn_timer.stop()
	difficulty_timer.stop()
	active_enemy = null
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()

func start_game():
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	difficulty_value.text = str(0)
	killed_value.text = str(0)
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	spawn_enemy()

func _on_restart_button_pressed() -> void:
	start_game()
