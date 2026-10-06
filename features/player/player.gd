class_name Player
extends CharacterBody2D

@export var speed: float = 80.0

## Set false while dialogue is open so the player can't walk away mid-conversation.
var can_move: bool = true

@onready var sprite: CharacterSprite = %Sprite
@onready var camera: Camera2D = %Camera


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
