extends Node2D

# Reponsible for spawning enemies

# Tracks enemies in scene to compare to prompts of enemies to what is being typed
var enemy_map : Dictionary[String, Enemy] = {}
var phrase_typed: String

const ENEMY = preload("uid://c02w5vdnu21bl")

@export var spawn_container: Node2D 

func spawn_enemy(difficulty: int): 
	var enemy_instance = ENEMY.instantiate()
	var spawns = spawn_container.get_children()
	var index: int = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	add_child(enemy_instance)
	enemy_map[enemy_instance.prompt_text] = enemy_instance
	enemy_instance.set_difficulty(difficulty)

# Logic for figuring out if what the player has typed matches the enemy prompt
func on_player_typed(key_typed: String):
	phrase_typed += key_typed
	print(phrase_typed)
	# If an enemy exists in the map whose key matches the phrase typed
	var partially_matched: bool = false
	
	# For every enemy we want to compare the phrase typed to the enemy_prompt.
	for enemy_prompt: String in enemy_map:
		# Colorize text
		enemy_map[enemy_prompt].colorize(phrase_typed)			
		# If we find a match destroy the enemy.
		if (phrase_typed == enemy_prompt):
			# Destroy node after we correctly type input
			enemy_map[enemy_prompt].destroyed.connect(get_tree().current_scene.increment_enemies_destroyed)
			enemy_map[enemy_prompt].destroy()
			# Erase dictionary after we are done with enemy
			enemy_map.erase(enemy_prompt)
		# If we see a partial match, keep looking. enemy prompt starts with what you've typed
		elif (enemy_prompt.begins_with(phrase_typed)):
			partially_matched = true

	# If not reset the phrase typed.
	if not partially_matched:
		phrase_typed = ""
