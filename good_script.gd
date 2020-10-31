extends KinematicBody2D


# Member constants
const GRAVITY = 400.0 # pixels/second/second
const PUSH_FORCE = 6600
const JUMP_FORCE = 200
const MIN_SPEED = 10
const MAX_SPEED = 500
const SLOW_FORCE = 5
const STOP_FORCE = 400
const ELAPSED_TIME = .2
const ELAPSED_TIME_J = .1

# Member variables
var velocity = Vector2()
var prev_push_pressed = false
var prev_jump_pressed = false
var time_passed = 0
var time_passed_J = 0
var should_push = false
var air_time = 0
var jumping = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_passed > 50000000:
		time_passed = 2
	
	# Create force due to gravity
	var force = Vector2(0, GRAVITY)
	
	
	# Takes in inputs
	var stop = Input.is_action_pressed("left")
	var jump = Input.is_action_pressed("up")
	var push = Input.is_action_pressed("space")
	
	
	# default states
	if not push and not stop and not jumping:
		print("default")
		$Sprite.play("default")
	if is_on_floor():
		air_time = 0	
	var slow = true
	
	# code for pushing
	if velocity.x >= -MIN_SPEED and velocity.x < MAX_SPEED:
		if should_push:
			time_passed = 0
		if time_passed >= ELAPSED_TIME and time_passed <= 1:
			force.x += PUSH_FORCE
			time_passed = 2
			slow = false
	if push and is_on_floor():
		print("push")
		$Sprite.play("push_anim")
	
	
	#code for friction/stopping
	if slow:
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= SLOW_FORCE * delta
		# code for stopping
		if stop and is_on_floor():
			vlen -= STOP_FORCE * delta
			print("stop")
			$Sprite.play("stop_anim")
		if vlen < 0:
			vlen = 0
		
		velocity.x = vlen * vsign
	
	
	# applies forces
	velocity += force * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if jumping and velocity.y > 0:
		# If falling, no longer jumping
		jumping = false
	
	if air_time < ELAPSED_TIME_J and jump and not prev_jump_pressed and not jumping:
		time_passed_J = 0
	if time_passed_J >= ELAPSED_TIME_J and time_passed_J <= 1:
		velocity.y = -JUMP_FORCE
		jumping = true
		time_passed_J = 2
	if air_time > 0:
		print("ollie")
		$Sprite.play("ollie")
	
	if velocity.y > .1:
		print("fall")
		$Sprite.play("fall")
	
	# determines if push is valid
	should_push = false
	if is_on_floor() and push and abs(velocity.x) < MAX_SPEED and not prev_push_pressed:
		should_push = true
	
	prev_push_pressed = push
	time_passed += delta
	air_time += delta
	time_passed_J += delta
	prev_jump_pressed = jump
	
	
	
