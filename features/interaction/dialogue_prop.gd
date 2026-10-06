class_name DialogueProp
extends Node2D
## Anything that isn't a person but still "talks" when inspected: animals, signs, objects.
## Needs an Interactable child named Interactable (unique name).

## Shown as the speaker. Leave empty for narration (no name tag).
@export var display_name: String = ""
@export var dialogue: DialogueTree


func _ready() -> void:
	(%Interactable as Interactable).interacted.connect(_on_interacted)


func _on_interacted(_by: Node2D) -> void:
	Dialogue.start(dialogue, display_name)
