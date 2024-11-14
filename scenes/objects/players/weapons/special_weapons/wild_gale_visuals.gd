extends CanvasLayer

var wait : int
var direction : int
@onready var projectile

# Called when the node enters the scene tree for the first time.
func _ready():
	projectile = preload("res://scenes/objects/players/weapons/special_weapons/wild_gale_vfx.tscn").instantiate()
	get_parent().add_child(projectile)
	projectile.position.y = offset.y
	
	
	if direction == 0:
		projectile.position.x = offset.x-2
		
	if direction == 1:
		projectile.position.x = offset.x+2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if wait > 30:
		queue_free()
	wait = wait + 1
