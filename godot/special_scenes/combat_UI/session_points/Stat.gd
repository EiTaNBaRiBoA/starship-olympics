@tool
extends VBoxContainer

@export var key: String: set = set_key
@export var stats_value: String= str(0): set = set_stats_value

func set_stats_value(value: String):
	stats_value = value
	$Value.text = stats_value
	
func set_key(value: String):
	key = value
	$Key.text = key
	
