extends Node2D

@onready var enemy_container = $EnemyContainer

# var to "lock in" to the desired enemy
var active_enemy = null
var current_letter_index: int = -1

func find_new_active_enemy(typed_character: String):
	# Go through and if enemy's prompt is equal, set to enemy found
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0, 1).to_lower()
		# var next_character = prompt.substr(0, 1)
		# Is the character is the same one that was typed?
		#if prompt.substr(0, 1).to_lower() == typed_character.to_lower():
			#print("Found new enemy that starts with %s" % next_character)
			#active_enemy = enemy
		if next_character == typed_character.to_lower():
			current_letter_index = 1
			print("Found new enemy that starts with %s" % next_character)
			active_enemy = enemy
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
				# Resets our enemy
				if current_letter_index == prompt.length():
					print("DONE!")
					active_enemy.queue_free()
					active_enemy = null
			else:
				print("Incorrectly typed %s instead of %s" % [key_typed, next_character])
