extends Node2D
class_name FishingRodHook

@onready var line_2d: Line2D = $Line2D
@onready var path_2d: Path2D = $Path2D
@onready var tween: Tween
@onready var player: Player = PlayerManager.player
@onready var sprite_2d: Sprite2D = $Sprite2D

var animated: bool = false

var max_player_distance: float = 200
var player_out_of_range: bool = false

const FISHING_ROD_ART_NORMAL = preload("res://entities/items/fishing_rod/art/fishing_rod.png")
const FISHING_ROD_ART_CASTED = preload("res://entities/items/fishing_rod/art/fishing_rod_casted.png")


func draw_curve() -> void:
	var hand_pos: Vector2 = player.on_hand.global_position - self.position
	if player.is_facing_right:
		hand_pos += Vector2(8, -8)
	else:
		hand_pos += Vector2(-8, -8)
	path_2d.curve.set_point_position(1, Vector2(0, 0))
	var outX: float = abs(hand_pos.x / 4)
	path_2d.curve.set_point_out(0, Vector2(outX, -outX))
	path_2d.curve.set_point_position(0, hand_pos)
	path_2d.curve.set_point_in(1, Vector2(-outX, -outX))


func draw_fish_line() -> void:
	line_2d.clear_points()
	for point in path_2d.curve.get_baked_points():
		line_2d.add_point(point + path_2d.position)


func animate_fish_line_out() -> void:
	tween = get_tree().create_tween()
	var points: PackedVector2Array = path_2d.curve.get_baked_points()
	line_2d.clear_points()
	for point in points.size():
		tween.tween_property(line_2d, "points", points.slice(0, point + 1), 0.015).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	sprite_2d.visible = true
	animated = true


func animate_fish_line_in() -> void:
	tween = get_tree().create_tween()
	var points: PackedVector2Array = path_2d.curve.get_baked_points()
	animated = false
	sprite_2d.visible = false
	for point in points.size():
		tween.tween_property(line_2d, "points", points.slice(0, -point), 0.01).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()


func _ready() -> void:
	sprite_2d.visible = false
	draw_curve()
	animate_fish_line_out()


func _physics_process(_delta: float) -> void:
	draw_curve()
	if animated:
		draw_fish_line()
	if not player_out_of_range:
		if abs(player.global_position.x - self.global_position.x) > max_player_distance or abs(player.global_position.y - self.global_position.y) > max_player_distance:
			player_out_of_range = true
			player.on_hand.texture = FISHING_ROD_ART_NORMAL
			animate_fish_line_in()
