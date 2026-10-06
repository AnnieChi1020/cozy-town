extends Node
## Global story state. Dialogue choices write flags here; NPCs and endings read them.

signal flag_changed(flag: StringName, value: Variant)

var _flags: Dictionary[StringName, Variant] = {}


func set_flag(flag: StringName, value: Variant = true) -> void:
	if _flags.get(flag) == value:
		return
	_flags[flag] = value
	flag_changed.emit(flag, value)


func get_flag(flag: StringName, default: Variant = false) -> Variant:
	return _flags.get(flag, default)


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


## Plain Dictionary snapshot for the save system.
func to_save_data() -> Dictionary:
	return _flags.duplicate()


func load_save_data(data: Dictionary) -> void:
	_flags.clear()
	for flag: Variant in data:
		_flags[StringName(flag)] = data[flag]
