extends RigidBody2D

@export var speed: float = 400.0
var player: Node2D
var timer: Timer

func _ready():
	player = get_node("/root/Game/player")
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.start()

	if player:
		var direction = (player.global_position - global_position).normalized()
		linear_velocity = direction * speed

func _on_Bullet_collision(body: Node):
	queue_free()
		

func _on_Timer_timeout():
	queue_free()
