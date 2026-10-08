extends Node2D

var Enemy = preload("res://scenes/enemy.tscn")

@onready var spawn_container = $SpawnContainer
@onready var spawn_timer = $SpawnTimer
@onready var difficulty_timer = $DifficultyTimer

@onready var enemy_container = $EnemyContainer
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
