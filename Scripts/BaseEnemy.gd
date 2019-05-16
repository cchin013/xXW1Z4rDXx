extends KinematicBody2D

export var Health = 50

var Invincible = false
var IFrames = 0
var Dying = false

func _ready():
	set_process(true)

func _process(delta):
	if (Health <= 0 and not Dying):
		Die()
		Dying = true
	if (IFrames > 0):
		if (IFrames % 6 == 0):
			self.modulate.a = 0
		else:
			self.modulate.a = 1
		IFrames -= 1
	else :
		Invincible = false

#Damage Taking Function
func Take_Damage(damage):
	Health -= damage

func Invincibility_Frames(numFrames):
	Invincible = true
	IFrames = numFrames
	
func Die():
	queue_free()