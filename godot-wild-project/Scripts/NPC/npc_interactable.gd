class_name NPCInteractable
extends CharacterBody3D


signal talked_to(npc: NPCInteractable)


@export var display_name: String = "NPC"


func interact() -> void:
	
	## Todo: Add more stuff here
	print("Talking to: ", display_name)

	talked_to.emit(self)
