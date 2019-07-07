extends Label

onready var text_label = $message_text/

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()

func _on_SuperSkeleton_display_text(message):
	self.text = str(message)
	self.show()	
	
