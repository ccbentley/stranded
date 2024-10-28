extends Node2D
class_name Quest

@onready var quest_box: Panel = $QuestBox
@onready var quest_title_label: Label = $QuestTitle
@onready var quest_description_label: Label = $QuestDescription

@export var quest_data: QuestData


func start_quest() -> void:
	if quest_data.quest_status == quest_data.QuestStatus.AVAILABLE:
		# Update quest status
		quest_data.quest_status = quest_data.QuestStatus.STARTED
		# Update UI
		quest_box.visible = true
		quest_title_label.text = quest_data.quest_name
		quest_description_label.text = quest_data.quest_description


func reached_goal() -> void:
	if quest_data.quest_status == quest_data.QuestStatus.STARTED:
		# Update quest status
		quest_data.quest_status = quest_data.QuestStatus.REACHED_GOAL
		# Update UI
		quest_description_label.text = quest_data.reached_goal_text


func finish_quest() -> void:
	if quest_data.quest_status == quest_data.QuestStatus.REACHED_GOAL:
		# Update quest status
		quest_data.quest_status = quest_data.QuestStatus.FINISHED
		# Update UI
		quest_box.visible = false
		#TODO Reward player
