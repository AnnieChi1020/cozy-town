class_name Player
extends CharacterBody2D

@export var speed: float = 80.0

## False while dialogue is open so the player can't walk away mid-conversation.
var can_move: bool = true

## The interactable currently showing a prompt bubble (nearest in reach).
var _focused: Interactable

@onready var sprite: CharacterSprite = %Sprite
@onready var camera: Camera2D = %Camera
@onready var interaction_area: Area2D = %InteractionArea


func _ready() -> void:
	Dialogue.started.connect(func() -> void: can_move = false)
	Dialogue.ended.connect(func() -> void: can_move = true)


func _physics_process(_delta: float) -> void:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if not can_move:
		input = Vector2.ZERO

	velocity = input * speed
	move_and_slide()

	if input == Vector2.ZERO:
		sprite.play_state(&"idle")
	else:
		sprite.play_state(&"walk", _dir_name(input))

	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not can_move or not event.is_action_pressed(&"interact"):
		return
	var target := _focused
	if is_instance_valid(target):
		# Mark handled so the same key press doesn't also advance the dialogue it opens.
		get_viewport().set_input_as_handled()
		target.interact(self)


func _update_prompt() -> void:
	# No prompt mid-conversation; it reappears when dialogue ends.
	var nearest := _nearest_interactable() if can_move else null
	if nearest == _focused:
		return
	if is_instance_valid(_focused):
		_focused.set_prompt_visible(false)
	_focused = nearest
	if _focused:
		_focused.set_prompt_visible(true)


func _nearest_interactable() -> Interactable:
	var best: Interactable = null
	var best_dist := INF
	for area in interaction_area.get_overlapping_areas():
		if area is Interactable:
			var dist := global_position.distance_squared_to(area.global_position)
			if dist < best_dist:
				best = area
				best_dist = dist
	return best


## Sheet only has 4 directions; diagonal movement faces the dominant axis.
func _dir_name(v: Vector2) -> StringName:
	if absf(v.x) > absf(v.y):
		return &"right" if v.x > 0 else &"left"
	return &"down" if v.y > 0 else &"up"


func set_camera_limits(rect: Rect2i) -> void:
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
