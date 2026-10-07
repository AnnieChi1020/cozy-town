extends CanvasLayer
## Autoload "Dialogue". Runs a DialogueTree: typewriter text, choices, flag updates.
## Anyone can call Dialogue.start(tree); listen to started/ended to react (e.g. freeze the player).

signal started
signal ended

const CHARS_PER_SECOND := 30.0
## Guards against require_flag/fallback loops in badly authored trees.
const MAX_BRANCH_HOPS := 32

var is_active: bool = false

var _tree: DialogueTree
var _node: DialogueNode
var _page: int = 0
var _default_speaker: String = ""
var _typing: Tween

@onready var _name_label: Label = %NameLabel
@onready var _text_label: Label = %TextLabel
@onready var _next_hint: Control = %NextHint
@onready var _choice_panel: Control = %ChoicePanel
@onready var _choice_list: VBoxContainer = %ChoiceList


func _ready() -> void:
	visible = false


func start(tree: DialogueTree, default_speaker: String = "") -> void:
	if is_active or tree == null:
		return
	_tree = tree
	_default_speaker = default_speaker
	is_active = true
	visible = true
	started.emit()
	_go_to(tree.start_id())


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if _choice_panel.visible:
		if event.is_action_pressed(&"move_up"):
			_move_choice_focus(-1)
		elif event.is_action_pressed(&"move_down"):
			_move_choice_focus(1)
		elif event.is_action_pressed(&"interact"):
			# Enter/Space already press the focused Button via ui_accept; this covers E.
			var focused := get_viewport().gui_get_focus_owner() as Button
			if focused and focused.get_parent() == _choice_list:
				focused.pressed.emit()
		else:
			return
		get_viewport().set_input_as_handled()
		return

	if not event.is_action_pressed(&"interact"):
		return
	get_viewport().set_input_as_handled()

	if _typing and _typing.is_running():
		_typing.kill()
		_text_label.visible_ratio = 1.0
		_next_hint.visible = true
		return

	_page += 1
	if _page < _node.pages.size():
		_show_page()
	else:
		_after_pages()


func _go_to(id: StringName) -> void:
	_node = _resolve(id)
	if _node == null:
		_finish()
		return
	_page = 0
	if _node.set_flag != &"":
		GameState.set_flag(_node.set_flag)
	if _node.pages.is_empty():
		_after_pages()
	else:
		_show_page()


## Follows require_flag/fallback until it reaches a node whose condition passes.
func _resolve(id: StringName) -> DialogueNode:
	var node := _tree.find(id)
	var hops := 0
	while node and node.require_flag != &"" and not GameState.get_flag(node.require_flag):
		hops += 1
		if hops > MAX_BRANCH_HOPS:
			push_error("Dialogue: branch loop near node '%s'" % node.id)
			return null
		node = _tree.find(node.fallback)
	return node


func _show_page() -> void:
	_choice_panel.visible = false
	_next_hint.visible = false
	var speaker := _node.speaker if _node.speaker != "" else _default_speaker
	_name_label.text = speaker
	_name_label.visible = speaker != ""
	_text_label.text = _node.pages[_page]
	_text_label.visible_characters = 0

	var length := _text_label.get_total_character_count()
	if _typing:
		_typing.kill()
	_typing = create_tween()
	_typing.tween_property(_text_label, ^"visible_characters", length, length / CHARS_PER_SECOND)
	_typing.finished.connect(func() -> void: _next_hint.visible = true)


func _after_pages() -> void:
	if not _node.choices.is_empty():
		_show_choices()
	elif _node.next != &"":
		_go_to(_node.next)
	else:
		_finish()


func _show_choices() -> void:
	_next_hint.visible = false
	# Detach first: queue_free alone leaves old buttons in the list until frame end,
	# and focus would land on a dying button.
	for child in _choice_list.get_children():
		_choice_list.remove_child(child)
		child.queue_free()
	for choice in _node.choices:
		var button := Button.new()
		button.text = choice.text
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_choice_picked.bind(choice))
		_choice_list.add_child(button)
	_choice_panel.visible = true
	(_choice_list.get_child(0) as Button).grab_focus.call_deferred()


func _move_choice_focus(step: int) -> void:
	var buttons := _choice_list.get_children()
	var focused := get_viewport().gui_get_focus_owner()
	var index := buttons.find(focused)
	index = wrapi(index + step, 0, buttons.size())
	(buttons[index] as Button).grab_focus()


func _on_choice_picked(choice: DialogueChoice) -> void:
	_choice_panel.visible = false
	if choice.set_flag != &"":
		GameState.set_flag(choice.set_flag)
	if choice.next == &"":
		_finish()
	else:
		_go_to(choice.next)


func _finish() -> void:
	if _typing:
		_typing.kill()
	is_active = false
	visible = false
	_choice_panel.visible = false
	_tree = null
	_node = null
	ended.emit()
