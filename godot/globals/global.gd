extends Node

# single truth point
var local_multiplayer 

const SETTINGS_FILENAME = "res://export.cfg"
const E = 2.71828

const isometric_offset = Vector2(0,32)

var enable_analytics : bool = false setget _set_analytics
signal send_statistics

func _set_analytics(new_value):
	enable_analytics = new_value
	GameAnalytics.build_version = version
	GameAnalytics.enabled = enable_analytics
	connect("send_statistics", GameAnalytics, "add_event")

var array_device = ["kb1", "kb2", "joy1", "joy2", "joy3", "joy4"]
onready var device 

var available_languages = {
	"english": "en",
	"español": "es",
	"italiano": "it",
	"euskara": "eu",
	"français": "fr",
	"deutsch": "de"
	}
onready var language: String setget _set_language, _get_language
var array_language: Array = ["english", "italiano", "español", "euskara", "français", "deutsch"]
var full_screen = true setget _set_full_screen

func _set_full_screen(value: bool):
	full_screen = value
	OS.window_fullscreen = full_screen
	OS.move_window_to_foreground()
	if full_screen:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _set_language(value:String):
	language = value
	TranslationServer.set_locale(available_languages[language])

func _get_language():
	return language

var version = "0.6.4" setget set_version
var first_time = true

func set_version(value):
	print("Version is and will be {v}".format({"v": version}))


# OPTIONS need a min and a MAX
const min_win = 1
var win = 3
const max_win = 5

var campaign_win = win

var custom_win = win setget set_custom_win

func set_custom_win(value):
	custom_win = value
	win = custom_win

# levels
var level
var array_level

var audio_on : bool setget _audio_on

var demo : bool = false

func _audio_on(new_value):
	audio_on = new_value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), audio_on)

var master_volume : int = 50 setget _set_master_volume
var min_master_volume : int = 0
var max_master_volume: int = 100

var rumbling: bool = true

func _set_master_volume(new_value): 
	master_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Master"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)

var music_volume : int = 50 setget _set_music_volume
var min_music_volume : int = 0
var max_music_volume: int = 100

func _set_music_volume(new_value): 
	music_volume = new_value
	var db_volume = linear2db(float(new_value)/100)
	var bus_name = "Music"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)
	
var sfx_volume : int = 50 setget _set_sfx_volume
var min_sfx_volume : int = 0
var max_sfx_volume: int = 100

func _set_sfx_volume(new_value): 
	sfx_volume = new_value
	var db_volume = linear2db(float(sfx_volume)/100)
	var bus_name = "SFX"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db_volume)

# templates
var templates : Dictionary # {int : Resources}

# DEBUG
var debug : bool = false

# Soundtrack
onready var bgm = Soundtrack
# Controls
enum Controls {KB1, KB2, JOY1, JOY2, JOY3, JOY4, NO, CPU}

const CONTROLSMAP = {
	Controls.NO : "no",
	Controls.CPU : "cpu",
	Controls.KB1 : "kb1",
	Controls.KB2 : "kb2",
	Controls.JOY1 : "joy1",
	Controls.JOY2 : "joy2",
	Controls.JOY3 : "joy3",
	Controls.JOY4 : "joy4"
}

const CONTROLSMAP_TO_KEY = {
	"no" : Controls.NO,
	"cpu" : Controls.CPU,
	"kb1" : Controls.KB1,
	"kb2" : Controls.KB2,
	"joy1" : Controls.JOY1,
	"joy2" : Controls.JOY2,
	"joy3" : Controls.JOY3,
	"joy4" : Controls.JOY4
}

const MAX_PLAYERS = 4

# Species handler
const SPECIES_PATH = "res://selection/characters"
var ALL_SPECIES = {
	SPECIES0 = "mantiacs_1",
	SPECIES1 = "robolords_1",
	SPECIES2 = "trixens_1",
	SPECIES3 = "takonauts_1",
	SPECIES4 = "pentagonions_1",
	SPECIES5 = "toriels_1",
	SPECIES6 = "robolords_2",
	SPECIES7 = "trixens_2",
	SPECIES8 = "toriels_2",
	SPECIES9 = "takonauts_2",
	SPECIES10 = 'mantiacs_2'
}
# dictionary of SPECIES with some values (like a bool unlocked)
var unlocked_species = {
	ALL_SPECIES.SPECIES0: true,
	ALL_SPECIES.SPECIES1: true,
	ALL_SPECIES.SPECIES2: true,
	ALL_SPECIES.SPECIES3 : true,
	ALL_SPECIES.SPECIES4 : true,
	ALL_SPECIES.SPECIES5: true,
	ALL_SPECIES.SPECIES6: false,
	ALL_SPECIES.SPECIES7: false,
	ALL_SPECIES.SPECIES8 : false,
	ALL_SPECIES.SPECIES9 : false,
	ALL_SPECIES.SPECIES10 : false
}

func get_ordered_species():
	var ordered_species = get_unlocked().values()
	ordered_species.sort_custom(self, 'compare_by_id')
	return ordered_species

func compare_by_id(a,b):
	return a.id < b.id

var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}

var scores
var campaign_mode : bool = false setget set_campaign_mode

func set_campaign_mode(value):
	campaign_mode = value
	if campaign_mode:
		win = campaign_win
	else:
		win = custom_win
	
# 'from_scene' will have the reference to the previous scene (main scene at the beginning)
var from_scene = "res://special_scenes/title_screen/MainScreen.tscn"

func _input(event):
	if event.is_action_pressed("fullscreen"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		OS.window_fullscreen = not OS.window_fullscreen
	
	if demo and event.is_action_pressed("force_reset"):
		get_tree().change_scene("res://local_multiplayer/LocalMultiplayer.tscn")
		get_tree().paused = false
		
func _ready():
	print("Starting game...")
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_to_group("persist")
	
	# setup language and add if not exists
	var generic_locale = TranslationServer.get_locale().split("_")[0]
	# language = TranslationServer.get_locale_name(generic_locale).to_lower()
	for lang in available_languages:
		if generic_locale == available_languages[lang]:
			language = lang
	
	templates = get_species_templates()
	var saved_data = persistance.get_saved_data()
	var k = get_path()
	var global_key = String(get_path())
	
	if not saved_data or not "version" in saved_data[global_key] or check_version(saved_data[global_key]["version"], version):
		print("We need to update the saved game")
		first_time = true
		persistance.save_game()
	else:
		first_time = false
	if persistance.load_game():
		print("Successfully load the game")
	else:
		print("Something went wrong while loading the game data")
	

func end_game():
	print("Thanks for playing")
	GameAnalytics.end_session()
	if enable_analytics:
		yield(GameAnalytics, "message_sent")
	get_tree().quit()

func get_unlocked() -> Dictionary:
	"""
	Get all available unlocked species. 
	@return: Dictionary [enum : resource] that has as keys the enum of the species
	"""
	var available : Dictionary  = {}
	for species in unlocked_species:
		if unlocked_species[species]:
			available[species] = templates[species]
			
	return available


func get_species_templates() -> Dictionary:
	var species_templates = {}
	var resources = dir_contents(SPECIES_PATH, "", ".tres")
	var i = 0
	for species in ALL_SPECIES:
		if i > len(resources) -1:
			pass
			# print("This species: " + species.to_lower(), " is not available")
		else:
			var filename : String = ALL_SPECIES[species] + ".tres"
			species_templates[str(ALL_SPECIES[species])] = load(SPECIES_PATH.plus_file(filename))
			i+=1
	return species_templates


func _unlock_species(species : String):
	unlocked_species[species] = true

const INPUT_ACTIONS = ["kb1", "kb2"]
var input_mapping : Dictionary setget _set_input_mapping, _get_input_mapping
var default_input :=  {"kb1_accept":"M", "kb1_down":"Down", "kb1_fire":"M", "kb1_left":"Left", "kb1_right":"Right", "kb1_up":"Up", "kb2_accept":"1", "kb2_down":"S", "kb2_fire":"1", "kb2_left":"A", "kb2_right":"D", "kb2_up":"W"}

var default_joy_input := {
	"fire": ["button down", "button up", "button left", "button right"], 
	"up":["dpad up", "analog left up"],
	"left": ["dpad left", "analog left left"], 
	"right": ["dpad right", "analog left right"],
	"down": ["dpad down", "analog left down"]
	}
	
var array_joylayout = ["default", "setup1", "setup2", "setup3", "custom"]
onready var joylayout: String = array_joylayout[0] setget _set_joylayout, _get_joylayout

func _set_joylayout(value):
	joylayout = value

func _get_joylayout():
	return joylayout
	
	
func set_default_mapping(device:String):
	for action in default_input:
		if device in action:
			var event = InputEventKey.new()
			event.scancode = OS.find_scancode_from_string(default_input[action])
			remap_action_to(action, event)

func check_input_event(action_: String, event:InputEvent):
	return event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion

	
func remap_action_to(action: String, new_event: InputEvent, ui_flag=true) -> String:
	var current_key = ""
	var new_event_key = global.event_to_text(action, new_event)
	if ui_flag:
		var acts = action.split("_")
		var id = acts[len(acts)-1]
		if id == "fire":
			id = "accept"
		var ui_action = "ui_"+id
		for event in InputMap.get_action_list(action):
			print("For "+ ui_action + " removing: " + event_to_text(ui_action, event))
			InputMap.action_erase_event(ui_action, event)
		InputMap.action_add_event("ui_"+id, new_event)
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_event)
	return new_event_key
	
func remove_event_from_action(action, event) -> String:
	if not check_input_event(action, event):
		print(action+" it's nothing: " + event_to_text(action, event))
		return ""
	var current_key = global.event_to_text(action, event)
	var e : InputEvent
	if "kb" in action:
		e = InputEventKey.new()
		e.scancode = OS.find_scancode_from_string(current_key)
	elif "joy" in action:
		var device = int(action.split("_")[0].replace("joy", ""))-1
		if "analog" in current_key:
			var inverted_joy_map = invert_map(joy_input_map)[current_key]
			e = InputEventJoypadMotion.new()
			e.axis = int(inverted_joy_map.split("_")[1])
			e.axis_value = int(inverted_joy_map.split("_")[2])
		else:
			e = InputEventJoypadButton.new()
			e.button_index = int(current_key)
		e.device = device
	return event_to_text(action, e)
	
func _set_input_mapping(value_):
	input_mapping=value_
	for action in input_mapping:
		var event = InputEventKey.new()
		event.scancode = OS.find_scancode_from_string(input_mapping[action])
		remap_action_to(action, event)
	
func _get_input_mapping():
	var ret = {}
	for action_name in INPUT_ACTIONS:
		for action in InputMap.get_actions():
			if action_name in action:
				var event = InputMap.get_action_list(action)
				var keyboard = OS.get_scancode_string(event[0].scancode)
				ret[action] = keyboard
				
	return ret
		

# utils
func get_state():
	"""
	get_state will return everything we need to be persistent in the game
	"""
	var save_dict = {
		custom_win=custom_win,
		unlocked_species=unlocked_species,
		enable_analytics=enable_analytics,
		language=language,
		version=version,
		music_volume=music_volume,
		master_volume=master_volume,
		sfx_volume=sfx_volume,
		demo=demo,
		full_screen=full_screen,
		rumbling=rumbling,
		input_mapping=self.input_mapping,
		glow_enable=glow_enable
	}
	return save_dict

func load_state(data:Dictionary):
	"""
	Set back everything we need to load
	"""
	for attribute in data:
		set(attribute, data[attribute])

func dir_contents(path:String, starts_with:String = "", extension:String = ".tscn"):
	"""
	@param path:String given the path 
	@return a list of filename
	"""
		
	var dir = Directory.new()
	var list_files = []
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(extension):
					if not starts_with or file_name.find(starts_with) == 0: 
						list_files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return list_files

func mod(a,b):
	"""
	Modulus: Maybe fposmod and fmod will do the trick by its own
	"""
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

func shake_node_backwards(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position - Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position - Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")

func shake_node(node, tween):
	var actual_d_pos = node.rect_position
	tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position + Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.interpolate_method(node, "set_position", node.rect_position + Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	tween.start()
	yield(tween,"tween_completed")
	
func get_base_entity(node : Node):
	if node is Entity:
		return node
	if node == get_node("/root"):
		return null
	if not node:
		return null
	return get_base_entity(node.get_parent())
	
func check_version(saved_version: String, version: String) -> bool:
	# Will check if the version of the saved data is smaller the current
	var saved_minor = saved_version.split(".")[1]
	var saved_patch = saved_version.split(".")[2]
	var minor = version.split(".")[1]
	var patch = version.split(".")[2]
	
	return int(saved_patch) < int(patch)

func send_stats(category: String, stats: Dictionary):
	emit_signal("send_statistics", category, stats)
		
func sigmoid(x, width):
	return 1-1/(1+pow(E, -10*(x/width-0.5)))
	
func join_str(array, sep=","):
	var ret = ""
	for e in array:
		ret += e+sep
	return ret.rstrip(sep)
	return ret

func calculate_center(rect: Rect2) -> Vector2:
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

var joy_input_map = {
	"analog_1_1": "analog left down",
	"analog_1_-1": "analog left up",
	"analog_0_1": "analog left right",
	"analog_0_-1": "analog left left",
	"analog_2_1": "analog right right",
	"analog_2_-1": "analog right left",
	"analog_3_1": "analog right up",
	"analog_3_-1": "analog right down",
	"0": "button down",
	"1": "button right",
	"2": "button left",
	"3": "button up",
	"4": "L1",
	"5": "R1",
	"6": "L2",
	"7": "R2",
	"8": "LS",
	"9": "RS",
	"10": "select",
	"11": "start",
	"12": "dpad up",
	"13": "dpad down",
	"14": "dpad left",
	"15": "dpad right"
}



func event_to_text(action: String, event: InputEvent):
	"""
	event: @type InputEvent
	"""
	if event is InputEventKey:
		return event.as_text()
	elif event is InputEventJoypadButton:
		return str(event.button_index)
	elif event is InputEventJoypadMotion:
		if event.axis_value > 0:
			event.axis_value = 1
		else:
			event.axis_value = -1
		return "analog_"+str((event as InputEventJoypadMotion).axis) + "_" + str((event as InputEventJoypadMotion).axis_value)
	

func invert_map(map:Dictionary):
	"""
	works on one level map
	"""
	var ret = {}
	for k in map:
		ret[map[k]] = k
	return ret


var glow_enable = true setget _set_glow

func _set_glow(value):
	glow_enable = value
	
