extends Node2D

@onready var ground: TileMapLayer = %Ground
@onready var player: Player = %Player


func _ready() -> void:
	var used := ground.get_used_rect()
	var tile := ground.tile_set.tile_size
	player.set_camera_limits(Rect2i(used.position * tile, used.size * tile))
