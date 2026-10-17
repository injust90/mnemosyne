extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var enemy_container = $EnemyContainer
@onready var difficulty_timer = $DifficultyTimer

@onready var difficulty_value = $CanvasLayer/VBoxContainer/BottomRow/HBoxContainer/DifficultyValue
@onready var killed_value = $CanvasLayer/VBoxContainer/TopRow2/TopRow/EnemiesKilledValue
@onready var game_over_screen = $CanvasLayer/GameOverScreen

# var to "lock in" to the desired enemy
var current_letter_index: int = -1

var difficulty: int = 1
var enemies_killed = 0
var active_enemy = null

func _ready() -> void:
	start_game()

func _on_spawn_timer_timeout() -> void:
	active_enemy = enemy_container.spawn_enemy(difficulty)

func _on_difficulty_timer_timeout() -> void:
	# TODO Difficulty is set but the signal is declared and won't be used
	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)

func _unhandled_input(event: InputEvent) -> void:
# only fires when we get input and the key is pressed to prevent held down keystrokes
	if event is InputEventKey and not event.is_pressed():
		# use this variable for better autocompletion
		var typed_event = event as InputEventKey
		# get the letter the user types
		var key_typed: String = typed_event.as_text_keycode().to_lower()
		enemy_container.on_player_typed(key_typed)

func _on_lose_area_body_entered(_body: Node2D) -> void:
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
	enemy_container.spawn_enemy(difficulty)

func _on_restart_button_pressed() -> void:
	start_game()
