extends Node2D

# var to "lock in" to the desired enemy
var active_enemy = null
var current_letter_index: int = -1

func find_new_active_enemy(typed_character: String):
	var prompt = $Enemy.get_prompt()
	# print(prompt.substr(0, 1), " ", typed_character)
	# is the character is the same one that was typed
	if prompt.substr(0, 1).to_lower() == typed_character.to_lower():
		active_enemy = $Enemy
		print("NEW ENEMY!")

func _unhandled_input(event: InputEvent) -> void:
	# only fires when we get input and the key is pressed to prevent held down keystrokes
	if event is InputEventKey and not event.is_pressed():
		# use this variable for better autocompletion
		var typed_event = event as InputEventKey
		# get the letter the user types
		# PackedByteArray is an array designed to hold bytes to encode/decode various types to/from bytes.
		var key_typed = typed_event.as_text_key_label()
		
		# find an active enemy 
		if active_enemy == null:
			find_new_active_enemy(key_typed)
