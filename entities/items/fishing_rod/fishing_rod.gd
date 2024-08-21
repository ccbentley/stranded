extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var path_2d: Path2D = $Path2D
@onready var tween: Tween
@onready var player: Player = PlayerManager.player
const FISHING_ROD_HOOK = preload("res://entities/items/fishing_rod/fishing_rod_hook.tscn")
@onready var hook: FishingRodHook
@onready var rod_sprite: Sprite2D = $RodSprite
@onready var cast_point: Node2D = $CastPoint

var max_player_distance: float = 200
var player_out_of_range: bool = false
var max_line_cast_distance: float = 150

const FISHING_ROD_ART_NORMAL = preload("res://entities/items/fishing_rod/art/fishing_rod.png")
const FISHING_ROD_ART_CASTED = preload("res://entities/items/fishing_rod/art/fishing_rod_casted.png")

enum State {
	NONE,
	CASTING,
	CASTED,
	REELING,
}
var state: int = State.NONE


func use(_index: int) -> void:
	if state == State.NONE:
		cast_line()
	elif state == State.CASTED:
		reel_in()


func draw_curve() -> void:
	var rod_pos: Vector2 = cast_point.position
	path_2d.curve.set_point_position(1, to_local(hook.position))
	var outX: float = rod_pos.x / 0.75
	path_2d.curve.set_point_out(0, Vector2(outX, -outX))
	path_2d.curve.set_point_position(0, rod_pos)
	path_2d.curve.set_point_in(1, Vector2(-outX, -outX))


func draw_fish_line() -> void:
	line_2d.clear_points()
	for point in path_2d.curve.get_baked_points():
		line_2d.add_point(point + path_2d.position)


func cast_line() -> void:
	state = State.CASTING
	rod_sprite.texture = FISHING_ROD_ART_CASTED
	var distance: Vector2 = get_global_mouse_position() - player.global_position
	distance.x = clamp(distance.x, -max_line_cast_distance, max_line_cast_distance)
	distance.y = clamp(distance.y, -max_line_cast_distance, max_line_cast_distance)
	# Adjust distance based on player's facing direction
	if player.is_facing_right:
		distance.x = abs(distance.x)
	else:
		distance.x = abs(distance.x)
	hook = FISHING_ROD_HOOK.instantiate()
	WorldManager.world.add_child(hook)
	hook.position = cast_point.global_position
	hook.cast(to_global(distance))
	AudioManager.play_sound(load("res://assets/sounds/freesound/fastwoosh.wav"))
	await hook.casted
	state = State.CASTED


func reel_in() -> void:
	hook.reel_in(cast_point.global_position)
	state = State.REELING
	await hook.reeled_in
	state = State.NONE
	hook.queue_free()
	rod_sprite.texture = FISHING_ROD_ART_NORMAL
	line_2d.clear_points()
	player_out_of_range = false


func _physics_process(_delta: float) -> void:
	if state != State.NONE:
		draw_curve()
		draw_fish_line()
		if not player_out_of_range:
			if abs(player.global_position.x - hook.global_position.x) > max_player_distance or abs(player.global_position.y - hook.global_position.y) > max_player_distance:
				player_out_of_range = true
				reel_in()


func _on_tree_exiting() -> void:
	if is_instance_valid(hook):
		hook.queue_free()
