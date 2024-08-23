extends Node2D
class_name FishingRodHook

@onready var area_2d: Area2D = $Area2D
@onready var catch_timer: Timer = $CatchTimer
@onready var fish_minigame: CanvasLayer = $FishMinigame
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var fishing_rod: Node2D = null

signal casted
signal reeled_in

enum State {
	NONE,
	IDLE,
	ATTACHED,
	CAUGHT,
}
var state: int = State.NONE:
	set(value):
		if value != state:
			state = value
			if state == State.IDLE:
				animation_player.play("idle")
				catch_timer.wait_time = randi_range(10, 20)
				catch_timer.start()
			elif state == State.CAUGHT:
				animation_player.play("caught")
			else:
				animation_player.play("RESET")
				animation_player.stop()

enum TileType {
	WATER,
	LAND,
}
var tile_type: int = TileType.WATER

var hooked_object: Node2D = null


func _ready() -> void:
	casted.connect(on_casted)
	reeled_in.connect(on_reeled_in)
	fish_minigame.caught_fish.connect(on_caught_fish)
	fish_minigame.lost_fish.connect(on_lost_fish)


func on_casted() -> void:
	state = State.IDLE


func on_reeled_in() -> void:
	state = State.NONE
	hooked_object = null


func cast(target_position: Vector2) -> void:
	var max_parabola_height: int = 60
	var control_point: Vector2 = (position + target_position) / 2
	control_point.y -= 100  # Adjust this value to change the height of the parabola
	control_point.y = min(position.y - max_parabola_height, control_point.y)
	control_point.y = max(target_position.y - max_parabola_height, control_point.y)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", control_point, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_position, 0.4).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: casted.emit())


func reel_in(start_position: Vector2) -> void:
	var max_parabola_height: int = 10
	var control_point: Vector2 = (position + start_position) / 2
	control_point.y -= 10  # Adjust this value to change the height of the parabola
	control_point.y = min(position.y - max_parabola_height, control_point.y)
	control_point.y = max(start_position.y - max_parabola_height, control_point.y)

	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "position", control_point, 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", start_position, 0.3).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: reeled_in.emit())


func _physics_process(_delta: float) -> void:
	if is_on_land():
		tile_type = TileType.LAND
	else:
		tile_type = TileType.WATER

	if state == State.IDLE:
		for area in area_2d.get_overlapping_areas():
			if area.is_in_group("fishable"):
				state = State.ATTACHED
				hooked_object = area.owner
				position = hooked_object.position
				break

	if state == State.ATTACHED and hooked_object:
		hooked_object.position = position


func is_on_land() -> bool:
	var tile_map: Node2D = WorldManager.world.tile_map
	var sand_tile_data: TileData = tile_map.ground_1_layer.get_cell_tile_data(tile_map.local_to_map(position))
	var grass_tile_data: TileData = tile_map.ground_2_layer.get_cell_tile_data(tile_map.local_to_map(position))
	if sand_tile_data or grass_tile_data:
		return true
	return false


func _on_catch_timer_timeout() -> void:
	if state == State.IDLE:
		state = State.CAUGHT
		fish_minigame.visible = true
		fish_minigame.start_minigame()


func on_caught_fish() -> void:
	fish_minigame.visible = false
	fish_minigame.end_minigame()
	fishing_rod.reel_in()


func on_lost_fish() -> void:
	fish_minigame.visible = false
	fish_minigame.end_minigame()
	state = State.IDLE
