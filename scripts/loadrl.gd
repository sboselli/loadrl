extends Node2D

# Preload scenes
const DIALOG_WAIT = preload("res://scenes/dialog.tscn")

# Paths
const GAMES_DIR = "games"

# Colors
const COLOR_PARAGRAPH = Color(0.6, 0.6, 0.6, 1)
const COLOR_NOT_INSTALLED = Color(0.5, 0.5, 0.5, 1)
const COLOR_INSTALLED = Color(0.8, 0.8, 0.8, 1)
const COLOR_HOVER = Color(1, 1, 1, 1)
const COLOR_YELLOW = Color(0.8, 0.8, 0, 1)
const COLOR_YELLOW_HOVER = Color(1, 1, 0, 1)
const COLOR_GREEN = Color(0, 0.8, 0, 1)
const COLOR_GREEN_HOVER = Color(0, 1, 0, 1)
const COLOR_RED = Color(1, 0, 0, 1)

# Config & DB (to be filled from json)
const DB_FILE = "res://db.json"
var db_local = {}

const DB_URL = "https://gist.github.com/sboselli/68b9aba55232c9aabc2982013dc99019/raw/0b0f670972ce2351318539f565dfd9ca91177b5d/loadrl-db-191229.json"
var db_online = {}

var db = {}

const CONFIG_FILE = "res://config.json"
var config = {}

# Signals
signal config_loaded
signal db_loaded
signal state_updated
signal game_selected
signal ver_selected
signal game_selected_kb
signal game_installed
signal game_run

# Flow control
var downloading
var waiting = false
var wait_instance

# (games) State
var state = {
	"total_games": 0,
	"total_games_installed": 0,
	"total_versions_installed": 0
}
var selected = ""
var selected_last = ""
var selected_ver = ""

# Window drag
var window_drag = false
var drag_status = 0
var drag_offset = Vector2()

# Debug
const debug = true
var time_start = 0
var time_now = 0

# Home
const README_FILE = "res://README.txt"


func _ready():
	# Check dir & load files
	check_make_games_dir()
	load_config_from_file()
	
	# Home screen
	$main/home.set("custom_colors/default_color", COLOR_PARAGRAPH)
	$main/home.text = load_text_from_file(README_FILE)
	
	# Init db & update state
	load_db_from_file()
	if config.use_online_db and get_db_from_url():
		db = db_online
		print("Using Online DB.")
	else:
		db = db_local
		print("Using Local DB.")
		
	emit_signal("db_loaded")
	update_state()

	# Window drag signals
	$main/container_header.connect("mouse_entered", self, "_enable_window_drag")
	$main/container_header.connect("mouse_exited", self, "_disable_window_drag")
	$main/container_status_bar.connect("mouse_entered", self, "_enable_window_drag")
	$main/container_status_bar.connect("mouse_exited", self, "_disable_window_drag")


### Data & State
# Games dir
func check_make_games_dir():
	var base_dir = ""
	if !is_f5():
		base_dir = OS.get_executable_path().get_base_dir() + "\\"
		
	# Create games folder if it doesn't exist
	if !Directory.new().dir_exists(base_dir + GAMES_DIR):
		OS.execute( "cmd", ["/C mkdir " + GAMES_DIR], true)


# Load text from file (non json)
func load_text_from_file(file):
	# Open file 
	var data_file = File.new()
	if data_file.open(file, File.READ) != OK:
		print("Error opening text file.")
#		get_tree().quit()
	
	var text = data_file.get_as_text()
	data_file.close()
	return text


# Config
func load_config_from_file():
	# Open file 
	var data_file = File.new()
	if data_file.open(CONFIG_FILE, File.READ) != OK:
		print("Error opening config file.")
		get_tree().quit()
	
	# Parse text to JSON
	var data = JSON.parse(data_file.get_as_text())
	if data.error != OK:
		print("Error parsing config file.")
		get_tree().quit()
	
	data_file.close()
	
	# Save config and emit signal
	config = data.result
	emit_signal("config_loaded")
	
#	# Implementation using Godot's ConfigFile (not in use)
#	# since it always reads from file making it super slow
#	config = ConfigFile.new()
#	var err = config.load(CONFIG_FILE)
#	if err != OK:
#		print("Error opening config file.")
#		get_tree().quit()


func save_config():
	# Open file 
	var config_file = File.new()
	if config_file.open(CONFIG_FILE, File.WRITE) != OK:
		print("Error opening config file.")
		get_tree().quit()
		
	# Store data & close
	config_file.store_line(to_json(config))
	config_file.close()


# DB
func get_db_from_url():
	var output = []
	OS.execute("tools\\curl", ["-k", "-L", DB_URL], true, output)
	var data = JSON.parse(output[0])
	if data.error != OK:
		print("Error parsing online DB file.")
		return false
	
	# Store in `db`, skip disabled
	for slug in data.result.keys():
		if data.result[slug].get("disabled"):
			continue
		db_online[slug] = data.result[slug]
	
	return true


func load_db_from_file():
	# Open file 
	var data_file = File.new()
	if data_file.open(DB_FILE, File.READ) != OK:
		print("Error opening db file.")
		get_tree().quit()
	
	# Parse text to JSON
	var data = JSON.parse(data_file.get_as_text())
	if data.error != OK:
		print("Error parsing db file.")
		get_tree().quit()
		
	data_file.close()
	
	# Store in `db`, skip disabled
	for slug in data.result.keys():
		if data.result[slug].get("disabled"):
			continue
		db_local[slug] = data.result[slug]


# State
func update_state():
	state.total_games = 0
	state.total_games_installed = 0
	state.total_versions_installed = 0
	for slug in db:
		### Init game state 
		state.total_games += 1
		state[slug] = {
			"installed": []
		}
		
		### Update install status
		# Get list of installed versions
		var installed_versions = []
		if Directory.new().dir_exists(game_base_path(slug)):
			for version in db[slug].versions:
				if Directory.new().dir_exists(game_base_path(slug) + "\\" + slug + "-" + version):
					installed_versions.append(version)
					state.total_versions_installed += 1
		
		# Store in state
		if installed_versions.size() > 0:
			state[slug].installed = installed_versions
			state.total_games_installed += 1
	
	# Update state & emit
	update_state_default_ver()
	emit_signal("state_updated")


func update_state_default_ver():
	for slug in db:
		# Use preference set from config if available
		if config.default_versions.has(slug):
			state[slug].default_ver = config.default_versions[slug]
		else:
			# No config, use latest in db
			state[slug].default_ver = db[slug].versions.keys()[0]
			
			# Override if any older version is installed
			if state[slug].installed.size() > 0:
				state[slug].default_ver = state[slug].installed[0]
	
	emit_signal("state_updated")


# Currently selected game
func set_selected(slug, kb=false):
	# Show home screen if deselecting (through '> loadRL' btn)
	if slug == "":
		selected = ""
		selected_ver = ""
		emit_signal("game_selected")
		return
	
	# Do nothing if nothing changed
	if selected == slug:
		return
	
	# Store previous, set selected, ver & emit signal
	selected_last = selected
	selected = slug
	selected_ver = state[slug].default_ver
	
	emit_signal("game_selected")
	if kb:
		emit_signal("game_selected_kb")


# Set default version
func set_default_ver(slug, ver):
	selected_ver = ver
	config.default_versions[slug] = ver
	save_config()
	update_state_default_ver()
	emit_signal("ver_selected")
	
#	# Implementation using Godot's ConfigFile (not in use)
#	selected_ver = ver
#	config.set_value("default_versions", slug, ver)
##	config.save(CONFIG_FILE)
#	save_config()
#	update_default_ver()


### Downloading & extracting
# "Public" method that other nodes call (go button)
func download_and_extract(slug):
	if is_installed(slug, selected_ver):
		if debug: print("Game already installed. Delete folder first.")
		return
	
	# Set current dl and show wait screen
	self.downloading = slug
	wait("downloading... please wait...")
	
	# Check if failed/partially downloaded
	var file_exists = File.new().file_exists(dl_fname(slug))
	if file_exists:
		OS.execute("cmd", ["/C del " + dl_fname(slug)], true)
	
	download(slug)


# Download wrapper to use curl if available 
# (Godot's httpRequeust seems to be 4x slower)
func download(slug):
	# Check if curl is available
	var curl_exists = File.new().file_exists("tools\\curl.exe")
	if curl_exists:
		download_curl()
	else:
		download_godot(slug)


# Download using Curl
func download_curl():
	# The use of this timer is required to prevent 
	# the blocking of the dl cmd coming before the wait screen
	var timer_dl = Timer.new()
	add_child(timer_dl) 
	timer_dl.connect("timeout",self,"_on_timer_dl_timeout") 
	timer_dl.wait_time = 0.1
	timer_dl.one_shot = true
	timer_dl.start() 

func _on_timer_dl_timeout():
	run_curl(self.downloading)

func run_curl(slug):
	OS.execute("tools\\curl", ["-k", "-L", db[slug].versions[selected_ver].url, "-o" + dl_fname(slug)], true)
	extract(slug)


# Download using Godot 
func download_godot(slug):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.set_download_file(dl_fname(slug))
	http_request.connect("request_completed", self, "_http_request_completed")
	
	var http_error = http_request.request(db[slug].versions[selected_ver].url)
	if http_error != OK:
		print("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Download failed.")
		return
	extract(selected)


# Extract
func extract(slug):
	# Check/create game slug folder
	if !Directory.new().dir_exists(game_base_path(slug)):
		OS.execute( "cmd", ["/C mkdir " + game_base_path(slug)], true)
		
	# Extract
	OS.execute("tools\\7z", ["x", dl_fname(slug), "-o" + game_version_path(slug)], true)
	
	# Special cases ugh...
	if db[slug].versions[selected_ver].has("flags"):
		if db[slug].versions[selected_ver].flags.has("double_extract"):
			OS.execute("tools\\7z", ["x", game_version_path(slug) + "\\*.exe", "-o" + game_version_path(slug)], true)
		if db[slug].versions[selected_ver].flags.has("copy_files"):
			var files_data = db[slug].versions[selected_ver].get("copy_files")
			OS.execute( "cmd", ["/C robocopy " + game_version_path(slug) + "\\" + files_data[0] + " " + game_version_path(slug) + "\\" + files_data[1] + " /e"], true)
	
	# Delete dowloaded file
	OS.execute("cmd", ["/C del " + dl_fname(slug)], true)
	
	update_state()
	emit_signal("game_installed")
	wait_stop()


### Run game
func run(slug):
	if db[slug].versions[selected_ver].has("flags") and db[slug].versions[selected_ver].flags.has("dos"):
		OS.execute("tools\\DOSBox\\DOSBox.exe", [game_run_path(slug) + "\\" + db[slug].versions[selected_ver].exec + ".exe", "-noconsole"], false)
	else:
		OS.execute("cmd", ["/C cd " + game_run_path(slug) + " && " + db[slug].versions[selected_ver].exec], false)
	emit_signal("game_run")


### Input
func _input(ev):
	# Quit at all times
	if ev is InputEventKey:
		if ev.is_action_pressed("ui_cancel"):
			get_tree().quit()
	
	# TESTING
	if ev is InputEventKey:
		if ev.is_action_pressed("test"):
			print("is_f55: ", is_f5())
	
	# Do nothing if waiting
	if waiting:
		return
	
	# Keystrokes
	if ev is InputEventKey:
		# Run game
		if ev.is_action_pressed("ui_accept"):
			if selected:
				run(selected)
		
		# Arrows UP & DOWN
		if ev.is_action_pressed("ui_up"):
			var slugs = db.keys()
			if selected:
				var idx = slugs.find(selected)
				if idx <= 0:
					set_selected(slugs[slugs.size() - 1], true)
				else:
					set_selected(slugs[idx - 1], true)
			else:
				set_selected(slugs[slugs.size() - 1], true)
		
		if ev.is_action_pressed("ui_down"):
			var slugs = db.keys()
			if selected:
				var idx = slugs.find(selected)
				if idx >= slugs.size() - 1:
					set_selected(slugs[0], true)
				else:
					set_selected(slugs[idx + 1], true)
			else:
				set_selected(slugs[0], true)
	
	# OS Window drag
	if window_drag:
		# OS Window Drag
		if ev is InputEventMouseButton:
			if ev.button_index == BUTTON_LEFT:
				if ev.pressed:
					if drag_status == 0:
						drag_status = 1
						drag_offset = OS.window_position - (ev.global_position + OS.window_position)
		if drag_status == 1:
			if ev is InputEventMouseMotion:
				drag_status = 2
		if drag_status == 2:
			OS.window_position = (get_viewport().get_mouse_position() + OS.window_position) + drag_offset
			if ev is InputEventMouse:
				if ev.get_button_mask() != BUTTON_LEFT:
					drag_status = 0



### Helpers
# Dialog: Wait screen
func wait(msg):
	waiting = true
	wait_instance = DIALOG_WAIT.instance()
	wait_instance.msg = msg
	$main.add_child(wait_instance)
	
	wait_instance.position = Vector2(0, 120)

func wait_stop():
	waiting = false
	wait_instance.queue_free()


# Window drag control
func _enable_window_drag():
	window_drag = true
	
func _disable_window_drag():
	window_drag = false


# Install status
func is_installed(slug, ver):
	return ver in state[slug].installed

func is_any_installed(slug):
	return state[slug].installed.size() > 0


### Paths & filenames
# GAMES_DIR			-> games
# version_slug		-> slug-ver
# game_base_path	-> games/slug/
# game_version_path	-> games/slug/slug-ver
# game_run_path		-> games/slug/slug-ver/path

func v_slug(slug):
	# Ex: 'slug-ver'
	return slug + "-" + selected_ver

func dl_fname(slug):
	# Ex: 'dl-slug-ver'
	return "dl-" + v_slug(slug)

func game_base_path(slug):
	var base_dir = ""
	if !is_f5():
		base_dir = OS.get_executable_path().get_base_dir() + "\\"
	# Ex: 'games\\slug'
	return base_dir + GAMES_DIR + "\\" + slug 

func game_version_path(slug):
	# Ex: 'games\\slug\\slug-ver'
	return game_base_path(slug) + "\\" + v_slug(slug)

func game_run_path(slug):
	if db[slug].versions[selected_ver].path != "":
		# Ex: 'games\\slug\\slug-ver\\path'
		return game_version_path(slug) + "\\" + db[slug].versions[selected_ver].path
	else:
		# Ex: 'games\\slug\\slug-ver'
		return game_version_path(slug)


# Util
func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func make_ascii_title(string):
	var title = "> " + string +"\n"
	for i in string.length() + 2:
		title += "_"
	return title


# Debug
func debug_timer_start():
	time_start = OS.get_unix_time()

func debug_timer_stop():
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	var minutes = elapsed / 60
	var seconds = elapsed % 60
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	print("elapsed : ", str_elapsed)

func is_f5():
	return OS.get_executable_path().get_file() != "loadRL.exe"


