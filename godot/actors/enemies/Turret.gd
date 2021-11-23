tool
extends StaticBody2D

export var weapon : PackedScene
export var speed = 400
export var rate = 1.0 setget set_rate
export var rotation_speed = 0.4
export var rays = 4
export var spread = 90
export var offset = 45
export var radius = 125
export var active := true setget set_active

var ccw = +1
var direction = Vector2(1,0)

func fire():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("Fire")
	for r in range(rays):
		fire_angled(r*deg2rad(spread)+deg2rad(offset))
	
func fire_angled(angle):
	var bullet = weapon.instance()
	
	bullet.position = radius*direction.rotated(angle)
	bullet.linear_velocity = direction.rotated(angle)*speed
	
	# ugly
	get_parent().add_child(bullet)
	
func _process(delta):
	if active and not Engine.editor_hint:
		direction = direction.rotated(rotation_speed*delta*ccw)
		set_rotation_and_stuff(rotation + rotation_speed*delta*ccw)

func set_rate(v):
	rate = v
	$Timer.wait_time = 1.0/rate
	$AnimationPlayer.playback_speed = rate
	
func set_active(v: bool):
	active = v
	$Sprite.visible = active
	$SpriteOff.visible = not active
	$Entity/Deadly.set_enabled(active)
	
func _on_Timer_timeout():
	fire()
	
func _ready():
	if active:
		ccw = +1 if randf() > 0.5 else -1
		var random_angle = randf()*2*PI
		direction = direction.rotated(random_angle)
		set_rotation_and_stuff(random_angle)
		set_process(false)
	
func start():
	set_process(true)
	$Timer.start(1.0/rate)
	fire()
	
func set_rotation_and_stuff(angle):
	rotation = angle
	$SpriteOff/Eye.rotation = -rotation
