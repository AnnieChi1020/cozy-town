class_name DialogueChoice
extends Resource
## One option the player can pick at the end of a DialogueNode.

@export var text: String
## Node id to jump to. Empty = conversation ends.
@export var next: StringName
## Flag set to true when this option is picked (e.g. &"alex_quest_accepted").
@export var set_flag: StringName
