extends Node2D

@onready var line_2d: Line2D = $Line2D
@onready var path_2d: Path2D = $Path2D
@onready var tween: Tween
@onready var player: Player = PlayerManager.player
const FISHING_ROD_HOOK = preload("res://entities/items/fishing_rod/fishing_rod_hook.tscn")
@onready var hook: Sprite2D
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
}
var state: int = State.NONE


func use(_index: int) -> void:
	if state == State.NONE:
		cast_line()
		rod_sprite.texture = FISHING_ROD_ART_CASTED
	elif state == State.CASTED:
		animate_fish_line_in()
		rod_sprite.texture = FISHING_ROD_ART_NORMAL
		hook.queue_free()


func draw_curve() -> void:
	var rod_pos: Vector2 = cast_point.position
	path_2d.curve.set_point_position(1, to_local(hook.position))
	var outX: float = abs(rod_pos.x / 0.75)
	path_2d.curve.set_point_out(0, Vector2(outX, -outX))
	path_2d.curve.set_point_position(0, rod_pos)
	path_2d.curve.set_point_in(1, Vector2(-outX, -outX))


func draw_fish_line() -> void:
	line_2d.clear_points()
	for point in path_2d.curve.get_baked_points():
		line_2d.add_point(point + path_2d.position)


func animate_fish_line_out() -> void:
	state = State.CASTING
	tween = get_tree().create_tween()
	line_2d.clear_points()
	for point in path_2d.curve.get_baked_points().size():
		tween.tween_property(line_2d, "points", path_2d.curve.get_baked_points().slice(0, point + 1), 0.01).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	hook.visible = true
	state = State.CASTED


func animate_fish_line_in() -> void:
	state = State.CASTING
	tween = get_tree().create_tween()
	state = State.NONE
	for point in path_2d.curve.get_baked_points().size():
		tween.tween_property(line_2d, "points", path_2d.curve.get_baked_points().slice(0, -point), 0.01).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	state = State.NONE


func cast_line() -> void:
	state = State.CASTING
	var distance: Vector2 = get_global_mouse_position() - player.global_position
	distance.x = clamp(distance.x, -max_line_cast_distance, max_line_cast_distance)
	distance.y = clamp(distance.y, -max_line_cast_distance, max_line_cast_distance)
	hook = FISHING_ROD_HOOK.instantiate()
	WorldManager.world.add_child(hook)
	hook.position = distance + player.position
	hook.visible = false
	AudioManager.play_sound(load("res://assets/sounds/freesound/fastwoosh.wav"))
	draw_curve()
	animate_fish_line_out()


func _physics_process(_delta: float) -> void:
	if state != State.NONE:
		draw_curve()
		draw_fish_line()
	if not player_out_of_range:
		if abs(player.global_position.x - self.global_position.x) > max_player_distance or abs(player.global_position.y - self.global_position.y) > max_player_distance:
			player_out_of_range = true
			rod_sprite.texture = FISHING_ROD_ART_NORMAL
			animate_fish_line_in()


func _on_tree_exiting() -> void:
	if is_instance_valid(hook):
		hook.queue_free()
