extends Area2D

var HitDuration = 1

func _ready():
	set_process(true)

func _process(delta):
	var Hits = get_overlapping_bodies()
	for Enemy in (Hits):
		if (Enemy.is_in_group("Enemies")):
			if (Enemy.Invincible == false):
				Enemy.Take_Damage(50)
				Enemy.Invincibility_Frames(30)
		#free()
	if (HitDuration <= 0):
		queue_free()
	HitDuration -= 30*delta