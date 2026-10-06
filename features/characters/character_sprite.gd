@tool
class_name CharacterSprite
extends AnimatedSprite2D
## Builds idle/walk animations from a LimeZu 16x16 character sheet.
## Sheet layout: 16x32 frames; row 1 = idle, row 2 = walk; 6 frames per direction,
## directions ordered right, up, left, down. Works for every Characters_16x16 sheet,
## so the player and all NPCs share this node.

const FRAME_SIZE := Vector2i(16, 32)
const FRAMES_PER_DIR := 6
const DIRECTIONS: Array[StringName] = [&"right", &"up", &"left", &"down"]
const ROWS: Dictionary[StringName, int] = {&"idle": 1, &"walk": 2}
const FPS: Dictionary[StringName, float] = {&"idle": 8.0, &"walk": 10.0}

@export var sheet: Texture2D:
	set(value):
		sheet = value
		_build_frames()

var facing: StringName = &"down"


func _ready() -> void:
	# Feet sit at the node origin so y-sorting and collision line up.
	centered = true
	offset = Vector2(0, -FRAME_SIZE.y / 2.0)
	if sprite_frames == null:
		_build_frames()
	play_state(&"idle")


## state: &"idle" or &"walk". dir: one of DIRECTIONS, or empty to keep current facing.
func play_state(state: StringName, dir: StringName = &"") -> void:
	if dir != &"":
		facing = dir
	var anim := StringName("%s_%s" % [state, facing])
	if sprite_frames and sprite_frames.has_animation(anim) and animation != anim:
		play(anim)


func _build_frames() -> void:
	if sheet == null:
		sprite_frames = null
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for state: StringName in ROWS:
		for d in DIRECTIONS.size():
			var anim := StringName("%s_%s" % [state, DIRECTIONS[d]])
			frames.add_animation(anim)
			frames.set_animation_speed(anim, FPS[state])
			for i in FRAMES_PER_DIR:
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				var col := d * FRAMES_PER_DIR + i
				atlas.region = Rect2(Vector2(col * FRAME_SIZE.x, ROWS[state] * FRAME_SIZE.y), FRAME_SIZE)
				frames.add_frame(anim, atlas)
	sprite_frames = frames
	play(StringName("idle_%s" % facing))
