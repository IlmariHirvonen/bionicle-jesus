extends Node
class_name HealthSystem

signal update_health(value)
signal enemy_is_dead
export var health:float = 100 setget set_health

func set_health(value:float):
	health += value
	if get_parent() != null:
		if get_parent().name == "Player":
			Fmod.play_one_shot("event:/hurt", self)
		else:
			Fmod.play_one_shot("event:/hit", self)
		
	
	emit_signal("update_health", health)
	if health <= 0.0:
		emit_signal("enemy_is_dead")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("update_health", health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
