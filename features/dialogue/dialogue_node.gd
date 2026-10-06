class_name DialogueNode
extends Resource
## One beat of a conversation: a few pages of text, then choices or a jump to `next`.

@export var id: StringName
## Leave empty to use the NPC's display name.
@export var speaker: String
## Each entry is one text box; the player presses interact to advance.
@export_multiline var pages: PackedStringArray
## Shown after the last page. If empty, the conversation goes to `next`.
@export var choices: Array[DialogueChoice]
## Node id to continue to when there are no choices. Empty = conversation ends.
@export var next: StringName

@export_group("Flags")
## Set to true when this node is reached.
@export var set_flag: StringName
## If set and that flag is not true, this node is skipped and `fallback` is used instead.
## A node with only require_flag/next/fallback acts as an "if" branch.
@export var require_flag: StringName
@export var fallback: StringName
