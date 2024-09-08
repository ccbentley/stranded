extends QuestManager
class_name Quest

func start_quest() -> void:
	if quest_status == QuestStatus.AVAILABLE:
		# Update quest status
		quest_status = QuestStatus.STARTED
		# Update UI
		quest_box.visible = true
		quest_title_label.text = quest_name
		quest_description_label.text = quest_description

func reached_goal() -> void:
	if quest_status == QuestStatus.STARTED:
		# Update quest status
		quest_status = QuestStatus.REACHED_GOAL
		# Update UI
		quest_description_label.text = reached_goal_text

func finish_quest() -> void:
	if quest_status == QuestStatus.REACHED_GOAL:
		# Update quest status
		quest_status = QuestStatus.FINISHED
		# Update UI
		quest_box.visible = false
		#TODO Reward player
