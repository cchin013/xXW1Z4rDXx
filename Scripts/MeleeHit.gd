extends KinematicBody2D


var HitTimer = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (HitTimer <= 0):
		queue_free()
	HitTimer -= 30*delta