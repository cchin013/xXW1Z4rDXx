extends Area2D

var HitDuration = 1
var Direction = Vector2(1,0)

func _ready():
	set_process(true)

func _process(delta):
	DealDamage()
	if (HitDuration <= 0):
		queue_free()
	HitDuration -= 15*delta
	
func DealDamage():
	var Overlaps = get_overlapping_bodies()
	for Hit in (Overlaps):
		if (Hit.is_in_group("Enemies")):
			if (Hit.Invincible == false and Hit.DeathCounter == 0):
				Hit.Take_Damage(30)
				Hit.Invincibility_Frames(30)
