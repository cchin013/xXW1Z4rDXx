extends Sprite

var timer

func _ready():
	if(!self.is_visible()):
		return
		
	timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(1)
	timer.connect("timeout", self, "_timeout")	
	timer.start()
	print("Timer started")
	

func _timeout():
	modulate = (Color( randf(), randf(), randf() ))
	timer.start()
