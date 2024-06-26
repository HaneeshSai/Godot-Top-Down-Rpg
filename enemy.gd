extends CharacterBody2D

@export var speed: float = 35.0
@export var chase_radius: float = 200.0
@export var attack_radius: float = 70.0
@export var bullet_scene: PackedScene

enum State {
	IDLE,
	CHASE,
	ATTACK
}

var state: State = State.IDLE

var player: Node2D

var animated_sprite: AnimatedSprite2D
var bullet_timer: Timer
var reset_color_timer: Timer

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var current_direction: Direction = Direction.DOWN

var original_color: Color = Color(1, 1, 1)
var hit_color: Color = Color(219.0 / 255.0, 70.0 / 255.0, 70.0 / 255.0)


func _ready():
	animated_sprite = $AnimatedSprite2D
	player = get_node("/root/Game/player")
	bullet_timer = $BulletTimer
	reset_color_timer = $ResetColorTimer
	original_color = animated_sprite.modulate

func _process(delta: float):
	match state:
		State.IDLE:
			_play_idle_animation()
			if player and player.global_position.distance_to(global_position) < chase_radius:
				state = State.CHASE
		State.CHASE:
			_play_move_animation()
			if player:
				var direction = (player.global_position - global_position).normalized()
				_update_direction(direction)
				velocity = direction * speed
				move_and_slide()
				if player.global_position.distance_to(global_position) < attack_radius:
					state = State.ATTACK
					bullet_timer.start(1.0) 
				elif player.global_position.distance_to(global_position) > chase_radius:
					state = State.IDLE
		State.ATTACK:
			_play_attack_animation()
			if player:
				if player.global_position.distance_to(global_position) > attack_radius:
					state = State.CHASE
					bullet_timer.stop() 

func _play_idle_animation():
	match current_direction:
		Direction.UP:
			animated_sprite.play("idle_up")
		Direction.DOWN:
			animated_sprite.play("idle_down")
		Direction.LEFT:
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = true
		Direction.RIGHT:
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = false

func _play_move_animation():
	match current_direction:
		Direction.UP:
			animated_sprite.play("move_up")
		Direction.DOWN:
			animated_sprite.play("move_down")
		Direction.LEFT:
			animated_sprite.play("move_side")
			animated_sprite.flip_h = true
		Direction.RIGHT:
			animated_sprite.play("move_side")
			animated_sprite.flip_h = false

func _play_attack_animation():
	match current_direction:
		Direction.UP:
			animated_sprite.play("idle_up")
		Direction.DOWN:
			animated_sprite.play("idle_down")
		Direction.LEFT:
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = true
		Direction.RIGHT:
			animated_sprite.play("idle_side")
			animated_sprite.flip_h = false

func _update_direction(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		if direction.x < 0:
			current_direction = Direction.LEFT
		elif direction.x > 0:
			current_direction = Direction.RIGHT
	else:
		if direction.y < 0:
			current_direction = Direction.UP
		elif direction.y > 0:
			current_direction = Direction.DOWN

func _on_BulletTimer_timeout():
	shoot_bullet()

func shoot_bullet():
	if bullet_scene:
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.global_position = global_position
		get_parent().add_child(bullet_instance)

func take_damage(direction: Vector2):
	print("taking damage")
	global_position += direction.normalized() * 10  
	animated_sprite.modulate = hit_color
	reset_color_timer.start(0.05) 

func _on_ResetColorTimer_timeout():
	animated_sprite.modulate = original_color
