extends Area2D

export var LIFESPAN = 1
var RemainingLife

func _ready():
	RemainingLife = LIFESPAN
	set_process(true)


func _process(delta):
	if (RemainingLife <= 0):
		queue_free()
		return
	DealDamage()
	RemainingLife -= 4*delta

func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false and Hit.DeathCounter == 0):
				Hit.Take_Damage(35)
				Hit.Invincibility_Frames(30)
