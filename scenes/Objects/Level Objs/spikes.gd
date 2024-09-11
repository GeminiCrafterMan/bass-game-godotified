extends Enemy_Template

class_name Spikes

func _ready():
	pass

func _process(delta):
	pass

func _on_hitable_body_entered(weapon): # needs to be redefined because damage values
	pass

func _on_hurt_body_entered(body):
	body.DmgQueue = 80
