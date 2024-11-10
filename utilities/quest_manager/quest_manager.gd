extends Control

@onready var active_container: VBoxContainer = $MarginContainer/Panel/VBoxContainer/TabContainer/Active/VBoxContainer/ScrollContainer/VBoxContainer
@onready var finished_container: VBoxContainer = $MarginContainer/Panel/VBoxContainer/TabContainer/Finished/VBoxContainer/ScrollContainer/VBoxContainer
const QUEST = preload("res://utilities/quest_manager/quest.tscn")


func load_quests(quests: Array[QuestData]) -> void:
	for quest in quests:
		print(quest.quest_status)
		var quest_scene: Quest = QUEST.instantiate()
		quest_scene.quest_data = quest
		active_container.add_child(quest_scene)
		quest_scene.custom_minimum_size = Vector2(350, 100)
		quest_scene.load_quest()


func save_quests() -> Array[QuestData]:
	var quests: Array[QuestData] = []
	for quest in finished_container.get_children():
		quests.append(quest.quest_data)
	for quest in active_container.get_children():
		quests.append(quest.quest_data)
	return quests


func new_quest(quest_data: QuestData) -> bool:
	for quest in finished_container.get_children():
		if quest.quest_data == quest_data:
			print("Quest already finished")
			return false
	for quest in active_container.get_children():
		if quest.quest_data == quest_data:
			print("Quest already started")
			return false

	var quest_scene: Quest = QUEST.instantiate()
	quest_scene.quest_data = quest_data
	active_container.add_child(quest_scene)
	quest_scene.custom_minimum_size = Vector2(350, 100)
	quest_scene.start_quest()
	print("Quest Started")
	return true
