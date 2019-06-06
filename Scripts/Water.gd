extends Sprite

export var LIFESPAN = 1

var RayNode
var RemainingLife


# Called when the node enters the scene tree for the first time.
func _ready():
	RayNode = get_node("WaterRotation")
	RemainingLife = LIFESPAN
	set_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (RemainingLife <= 0):
		free()
		return
	RemainingLife -= 2*delta
