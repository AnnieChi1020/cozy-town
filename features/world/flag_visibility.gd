class_name FlagVisibility
extends Node
## Add as a child to make the parent appear/disappear based on story flags.
## Hidden parents are also disabled, so their collisions and Interactables stop working.

## Parent only shows once this flag is true. Empty = no requirement.
@export var show_if: StringName
## Parent hides once this flag is true. Empty = never hides.
@export var hide_if: StringName


func _ready() -> void:
	GameState.flag_changed.connect(func(_flag: StringName, _value: Variant) -> void: _refresh())
	_refresh()


func _refresh() -> void:
	var shown := true
	if show_if != &"" and not GameState.get_flag(show_if):
		shown = false
	if hide_if != &"" and GameState.get_flag(hide_if):
		shown = false

	var target := get_parent() as CanvasItem
	target.visible = shown
	# Disabling also removes child CollisionObjects (incl. Interactable) from physics.
	target.set_deferred(&"process_mode", Node.PROCESS_MODE_INHERIT if shown else Node.PROCESS_MODE_DISABLED)
