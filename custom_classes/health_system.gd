extends Node
class_name HealthSystem

signal enemy_is_dead
export var health:float = 100 setget set_health

func set_health(value:float):
	health += value
	if health <= 0.0:
		emit_signal("enemy_is_dead")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass