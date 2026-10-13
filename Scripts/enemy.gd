extends CharacterBody2D

class_name Enemy

@export var blue: Color = Color("#4682b4")
@export var green: Color = Color("#639675")
@export var red: Color = Color("#a65455")

@export var speed: float = 0.5

@onready var prompt_label: RichTextLabel = $RichTextLabel
@onready var killed_value = get_node("/root/Main/CanvasLayer/VBoxContainer/TopRow2/TopRow/EnemiesKilledValue")
@onready var enemy_container = get_parent()

var active_enemy = null
var current_letter_index: int = -1
var enemies_killed = 0
var prompt_text: String = ""

func _ready() -> void:
	prompt_text= PromptList.get_prompt()
	prompt_label.parse_bbcode(set_center_tags(prompt_text))

func _physics_process(_delta: float) -> void:
	global_position.x -= speed

func set_difficulty(difficulty: int):
	handle_difficulty_increased(difficulty)
	
func handle_difficulty_increased(new_difficulty: int):
	var new_speed = speed + (0.125 * new_difficulty)
	speed = clamp(new_speed, speed, 3)

func get_prompt() -> String:
	return prompt_label.get_parsed_text()
	
	# Find a new active enemy, set index, set character, return to break out			
func find_new_active_enemy(typed_character: String):
	# Go through and if enemy's prompt_label is equal, set to enemy found
	for enemy in enemy_container.get_children():
		var prompt_label = enemy.get_prompt()		
		var next_character = prompt_label.substr(0, 1)

		print("next_character " + next_character)
		# Is the character is the same one that was typed?
		if next_character == typed_character:
			current_letter_index = 1
			print("Found new enemy that starts with %s" % next_character)
			active_enemy = enemy
			active_enemy.set_next_character(current_letter_index)
			return

func set_next_character(next_character_index: int):
	# Building up a ton of strings, will optimize later if needed
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var red_text = ""
	
	if next_character_index != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index + 1, prompt_text.length() - next_character_index + 1) + get_bbcode_end_color_tag()
		
	# build out the string
	prompt_label.parse_bbcode(set_center_tags(blue_text + green_text + red_text))
	print("prompt_label %s" % prompt_label.get_parsed_text())
		
func set_center_tags(string_to_center: String):
	return "[center]" + string_to_center + "[/center]"

func get_bbcode_color_tag(color: Color) -> String:
	# get HTML string so that it will return what is in the brackets. 
	return "[color=#" + color.to_html(false) + "]"
	
func get_bbcode_end_color_tag() -> String:
	return "[/color]"
