extends Area2D

var HitDuration = 1

#testtest

func _ready():
	set_process(true)

func _process(delta):
	DealDamage()
	if (HitDuration <= 0):
		queue_free()
	HitDuration -= 6*delta
	
func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Player")):
			if (not Hit.Invincible and not Hit.Dying):
				Hit.Take_Damage(25)
				Hit.Invincibility_Frames(60)
