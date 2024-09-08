extends Node
class_name QuestManager

@onready var quest_box: Panel = $QuestBox
@onready var quest_title_label: Label = $QuestTitle
@onready var quest_description_label: Label = $QuestDescription

@export_group("Quest Settings")
@export var quest_name: String # Name of quest
@export var quest_description: String # UI description text
@export var reached_goal_text: String # Ui description text after reaching goal

# Quest statuses
enum QuestStatus {
	AVAILABLE,
	STARTED,
	REACHED_GOAL,
	FINISHED,
}

# Quest status
@export var quest_status: QuestStatus = QuestStatus.AVAILABLE

@export_group("Reward Settings")
@export var reward_items: Array[SlotData]
