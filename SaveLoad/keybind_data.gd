extends Resource
class_name KeybindData

const MOVE_LEFT: String = "move_left"
const MOVE_RIGHT: String = "move_right"
const MOVE_UP: String = "move_up"
const MOVE_DOWN: String = "move_down"
const INVENTORY: String = "inventory"
const INTERACT: String = "interact"

@export var move_left_key: InputEventKey = InputEventKey.new()
@export var move_right_key: InputEventKey = InputEventKey.new()
@export var move_up_key: InputEventKey = InputEventKey.new()
@export var move_down_key: InputEventKey = InputEventKey.new()
@export var inventory_key: InputEventKey = InputEventKey.new()
@export var interact_key: InputEventKey = InputEventKey.new()
