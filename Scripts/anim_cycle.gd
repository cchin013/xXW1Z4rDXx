extends Node2D

export var sprite_name = "sprite"
var animator
var anim_list
var cur_anim = 0
var timer

func _ready():
	var sprite = self.find_node(sprite_name)
	animator = sprite.get_child(0)

#	anim_list = animator.get_animation_list()
#	timer = Timer.new()
#
#	add_child(timer)
#	timer.set_wait_time(animator.current_animation_length)
#	timer.connect("timeout", self, "_cycle")
#	timer.start()
#
#func _cycle():
#	if (cur_anim < anim_list.size()- 1):
#		cur_anim = cur_anim + 1
#	else:
#		cur_anim = 0
#
#	animator.play(anim_list[cur_anim])
#	timer.set_wait_time(animator.current_animation_length-0.1)
