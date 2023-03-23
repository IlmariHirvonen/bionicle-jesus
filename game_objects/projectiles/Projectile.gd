extends Spatial

export var speed:float = 80.0
var launch_direction:Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	var velocity: Vector3 = launch_direction.normalized() * speed * delta
	global_translate(velocity)


func _on_Lifetime_timeout():
	queue_free()


func _on_Area_body_entered(body):
	if body.is_in_group("enemy"):
		if body.has_node("HealthSystem"):
			body.get_node("HealthSystem").set_health(rand_range(-10.0,-15.0))
		queue_free()
