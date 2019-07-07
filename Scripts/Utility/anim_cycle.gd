extends Node2D

var animator
var anim_list
var cur_anim = 0
var timer
var animator_exists = false

func _ready():
	for child in self.get_children():
		if child is Sprite:
			for sprite_child in child.get_children():
				if sprite_child is AnimationPlayer:
					animator = sprite_child
					animator_exists = true
					break
	
	if not animator_exists:
		return
	
	anim_list = animator.get_animation_list()
	timer = Timer.new()

	add_child(timer)
	timer.set_wait_time(animator.current_animation_length)
	timer.connect("timeout", self, "_cycle")
	timer.start()

func _cycle():
	if (cur_anim < anim_list.size()- 1):
		cur_anim = cur_anim + 1
	else:
		cur_anim = 0

	animator.play(anim_list[cur_anim])
	timer.set_wait_time(animator.current_animation_length-0.1)
