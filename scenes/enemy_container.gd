extends Node2D

# Reponsible for spawning enemies

# Tracks enemies in scene to compare to prompts of enemies to what is being typed
var enemy_map : Dictionary[String, Enemy] = {}
const ENEMY = preload("uid://c02w5vdnu21bl")

@export var spawn_container: Node2D 

func spawn_enemy(difficulty: int): 
	var enemy_instance = ENEMY.instantiate()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	add_child(enemy_instance)
	enemy_map[enemy_instance.prompt_text] = enemy_instance
	enemy_instance.set_difficulty(difficulty)

# TODO Logic for figuring out if what the player has typed matches the enemy prompt
func on_player_typed(character: String):
	print(character, " ", enemy_map)
	
