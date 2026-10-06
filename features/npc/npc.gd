@tool
class_name NPC
extends StaticBody2D
## A townsperson. Pick a character sheet and a DialogueTree in the Inspector.

@export var display_name: String = ""
@export var sheet: Texture2D:
	set(value):
		sheet = value
		if is_node_ready():
			sprite.sheet = value
@export var dialogue: DialogueTree
@export_enum("down", "up", "left", "right") var facing: String = "down":
	set(value):
		facing = value
		if is_node_ready():
			sprite.play_state(&"idle", StringName(value))

@onready var sprite: CharacterSprite = %Sprite
@onready var interactable: Interactable = %Interactable


func _ready() -> void:
	sprite.sheet = sheet
	sprite.play_state(&"idle", StringName(facing))
	if Engine.is_editor_hint():
		return
	interactable.interacted.connect(_on_interacted)


func _on_interacted(by: Node2D) -> void:
	if dialogue == null:
		return
	_face_toward(by.global_position)
	Dialogue.start(dialogue, display_name)
	await Dialogue.ended
	sprite.play_state(&"idle", StringName(facing))


func _face_toward(point: Vector2) -> void:
	var d := point - global_position
	var dir: StringName
	if absf(d.x) > absf(d.y):
		dir = &"right" if d.x > 0 else &"left"
	else:
		dir = &"down" if d.y > 0 else &"up"
	sprite.play_state(&"idle", dir)
