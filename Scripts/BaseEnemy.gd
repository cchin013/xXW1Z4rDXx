extends KinematicBody2D
 
#testtest
 
export var Health = 50
export var MaxDetection = 100
export var FOV = 40
 
var Invincible = false
var IFrames = 0
var Dying = false
var DistToPlayer
var Player
var Facing = Vector2(1,0)
var DetectPlayer = false
 
func _ready():
    Player = get_node("/root/Bigmap/Player")
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