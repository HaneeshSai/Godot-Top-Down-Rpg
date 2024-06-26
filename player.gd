extends CharacterBody2D

var speed = 100  
@onready var animated_sprite = $AnimatedSprite2D
@onready var top_slash = $AttackArea/topSlash
@onready var left_slash = $AttackArea/leftSlash
@onready var right_slash = $AttackArea/rightSlash
@onready var down_slash = $AttackArea/downSlash
var last_direction = Vector2.ZERO
var is_attacking = false
var show_attack_gizmo = false  

var attack_duration = 0.5 
var attack_timer = 0.0

func _ready():
	top_slash.disabled = true  
	left_slash.disabled = true
	right_slash.disabled = true
	down_slash.disabled = true

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if is_attacking:
		velocity = Vector2.ZERO  
	else:
		velocity = direction * speed
		if direction != Vector2.ZERO:
			last_direction = direction  

	move_and_slide()

	if is_attacking:
		return 

	if Input.is_action_just_pressed("attack"):
		handle_attack(direction)
	else:
		handle_animations(direction)

func handle_attack(direction):
	is_attacking = true 

	top_slash.disabled = true
	left_slash.disabled = true
	right_slash.disabled = true
	down_slash.disabled = true

	if direction.y != 0:
		if direction.y > 0:
			animated_sprite.play("attack_down")
			down_slash.disabled = false  
		elif direction.y < 0:
			animated_sprite.play("attack_up")
			top_slash.disabled = false  
	else:
		if direction.x > 0:
			animated_sprite.play("attack_side")
			animated_sprite.flip_h = false
			right_slash.disabled = false 
		elif direction.x < 0:
			animated_sprite.play("attack_side")
			animated_sprite.flip_h = true
			left_slash.disabled = false 
		else:
			if last_direction.x > 0:
				animated_sprite.play("attack_side")
				animated_sprite.flip_h = false
				right_slash.disabled = false 
				
			elif last_direction.x < 0:
				animated_sprite.play("attack_side")
				animated_sprite.flip_h = true
				left_slash.disabled = false  
				
			elif last_direction.y > 0:
				animated_sprite.play("attack_down")
				down_slash.disabled = false  
				
			elif last_direction.y < 0:
				animated_sprite.play("attack_up")
				top_slash.disabled = false  

	attack_timer = attack_duration 

func handle_animations(direction):
	if direction == Vector2.ZERO:
		play_idle_animation()
	elif direction.x != 0:
		animated_sprite.play("walk_x")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y > 0:
		animated_sprite.play("walk_down")
	elif direction.y < 0:
		animated_sprite.play("walk_up")

func play_idle_animation():
	if last_direction.y > 0:
		animated_sprite.play("idle_down")
	elif last_direction.y < 0:
		animated_sprite.play("idle_up")
	elif last_direction.x != 0:
		animated_sprite.play("idle_side")
		animated_sprite.flip_h = last_direction.x < 0

func _process(delta):
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
			top_slash.disabled = true
			left_slash.disabled = true
			right_slash.disabled = true
			down_slash.disabled = true

func _on_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		var direction = last_direction if last_direction != Vector2.ZERO else Vector2(0, 1)
		body.take_damage(direction)
