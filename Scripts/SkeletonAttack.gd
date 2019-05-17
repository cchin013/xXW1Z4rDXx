extends Area2D

var HitDuration = 1

func _ready():
	set_process(true)

func _process(delta):
	DealDamage()
	if (HitDuration <= 0):
		queue_free()
	HitDuration -= 30*delta
	
func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Player")):
			if (Hit.Invincible):
				Hit.Take_Damage(40)
				#Hit.Invincibility_Frames(42)
