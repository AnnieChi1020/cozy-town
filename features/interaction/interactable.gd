class_name Interactable
extends Area2D
## Drop this on anything the player can press interact on (NPCs, signs, doors).
## The player's InteractionArea finds it; the owner listens to `interacted`.

signal interacted(by: Node2D)

## Physics layer 3 is reserved for interactables (player's InteractionArea scans it).
const LAYER := 1 << 2
const BUBBLE := preload("res://assets/ui/talk_bubble.png")
const BOB_HEIGHT := 2.0

## Where the prompt bubble floats, relative to the Interactable. Character art is ~22px tall.
@export var prompt_offset: Vector2 = Vector2(0, -28)

var _bubble: Sprite2D
var _bob: Tween


func _init() -> void:
	collision_layer = LAYER
	collision_mask = 0
	monitoring = false


func _ready() -> void:
	_bubble = Sprite2D.new()
	_bubble.texture = BUBBLE
	_bubble.position = prompt_offset
	_bubble.visible = false
	_bubble.z_index = 10  # above y-sorted characters
	add_child(_bubble)


func interact(by: Node2D) -> void:
	interacted.emit(by)


## Called by the player when this becomes (or stops being) the nearest interactable.
func set_prompt_visible(shown: bool) -> void:
	if _bubble.visible == shown:
		return
	_bubble.visible = shown
	if _bob:
		_bob.kill()
	if shown:
		_bubble.position = prompt_offset
		_bob = create_tween().set_loops()
		_bob.tween_property(_bubble, ^"position:y", prompt_offset.y - BOB_HEIGHT, 0.4).set_trans(Tween.TRANS_SINE)
		_bob.tween_property(_bubble, ^"position:y", prompt_offset.y, 0.4).set_trans(Tween.TRANS_SINE)
