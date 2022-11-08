extends CPUBrain

export var go_to_center_p := 0.2

var random_preference : int

func _ready():
	random_preference = randi()
	think()
	
func think():
	var targets
	
	set_stance('quiet')
	log_strategy('')
	
	targets = get_tree().get_nodes_in_group('Diamond')
	if len(targets) > 0:
		go_to(targets[random_preference%len(targets)].global_position)
		log_strategy('chase diamond')
		return
	
	if randf() < go_to_center_p:
		go_to(Vector2(0,0))
	else:
		forget_current_target_location()
