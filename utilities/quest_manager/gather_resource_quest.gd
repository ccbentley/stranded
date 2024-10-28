extends Quest
class_name GatherResourceQuest

@onready var player: Player = PlayerManager.player

@export_group("Goal Settings")
@export var goals: Array


func _ready() -> void:
	player.inventory_data.inventory_updated.connect(update_goal)


func update_goal() -> void:
	if quest_data.quest_status == quest_data.QuestStatus.STARTED:
		var goal = quest_data.goal
		var current = player.inventory_data.get_item_count(goal.item_name)
		if current >= goal.amount:
			reached_goal()
