extends Node2D

# export var sprite_name = "blue"
export var direction = Vector2()
export var motion_speed = 70
export var move_anim_name = "Left"
export var idle_anim_name = "Bounce"
export var walk_time = 0.5
export var idle_time = 2.0
export var flip_sprite = false

var timer
var moving
var sprite
var animator

func _ready():
	timer = Timer.new()
	direction = Vector2(-1,0)
	moving = false
	for child in self.get_children():
		if child is Sprite:
			sprite = child
	animator = sprite.get_child(0)
	sprite.flip_h = flip_sprite

	add_child(timer)
	timer.set_wait_time(walk_time)
	timer.connect("timeout", self, "_action")
	timer.start()

func _physics_process(delta):
	if(moving):
		self.global_translate(direction * delta * motion_speed)

func _action():
	moving = !moving

	if(moving):
		direction *= -1
		sprite.flip_h = !sprite.flip_h
		if(direction.x):
			animator.play(move_anim_name)
		timer.set_wait_time(idle_time)
	else:
		animator.play(idle_anim_name)
		timer.set_wait_time(walk_time)	
