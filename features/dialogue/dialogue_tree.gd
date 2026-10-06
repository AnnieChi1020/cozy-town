class_name DialogueTree
extends Resource
## A whole conversation. Starts at the node with id "start" (or the first node).

const START_ID := &"start"

@export var nodes: Array[DialogueNode]


func find(id: StringName) -> DialogueNode:
	if id == &"":
		return null
	for node in nodes:
		if node.id == id:
			return node
	push_error("DialogueTree %s: no node with id '%s'" % [resource_path, id])
	return null


func start_id() -> StringName:
	for node in nodes:
		if node.id == START_ID:
			return START_ID
	return nodes[0].id if not nodes.is_empty() else &""
