extends TileMap

var Skelenode = 0
var dead = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if (has_node("/root/Bigmap/Enemies/SuperSkeleton")):
		print("this node exists bruh")
		Skelenode = get_node("/root/Bigmap/Enemies/SuperSkeleton").DeathCounter
		print(Skelenode)
		if (Skelenode == 90):
			dead = true
		print(dead)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.