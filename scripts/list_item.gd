extends Control

var loadRL
var slug


func _ready():
	# Get root ref and connect to selected signal
	loadRL = get_node("/root/loadRL")
	loadRL.connect("game_selected", self, "_on_game_selected")
	
	# Init size & text
	$btn.rect_size = Vector2(320, 10)
	$btn.text = loadRL.db[slug].name
	if loadRL.selected == slug:
		$btn.set("custom_colors/font_color", loadRL.COLOR_GREEN)
	else:
		set_idle_color()
	$btn.set("custom_colors/font_color_pressed", loadRL.COLOR_GREEN)


# Choose color
func set_idle_color():
	if loadRL.is_any_installed(slug):
		$btn.set("custom_colors/font_color", loadRL.COLOR_INSTALLED)
	else:
		$btn.set("custom_colors/font_color", loadRL.COLOR_NOT_INSTALLED)


# Handle click
func _on_item_gui_input(ev):
	if !loadRL.waiting:
		if ev is InputEventMouseButton:
			if ev.button_index == BUTTON_LEFT:
				if ev.pressed:
					$btn.set("custom_colors/font_color_hover", loadRL.COLOR_GREEN)
					if  ev.doubleclick:
						loadRL.set_selected(slug)
						if loadRL.is_installed(slug, loadRL.selected_ver):
							loadRL.run(slug)
					else:
						loadRL.set_selected(slug)


# Handle game selection
func _on_game_selected():
	# Set selected color if it's us
	if loadRL.selected == slug:
		$btn.set("custom_colors/font_color", loadRL.COLOR_GREEN)
	# or go back to idle color if we're the last selected
	if loadRL.selected_last == slug:  # replace by else: ???
		set_idle_color()


# Handle hovers
func _on_btn_mouse_entered():
	if loadRL.selected == slug:
		$btn.set("custom_colors/font_color_hover", loadRL.COLOR_GREEN)
	else:
		$btn.set("custom_colors/font_color_hover", loadRL.COLOR_HOVER)

func _on_btn_mouse_exited():
	$btn.set("custom_colors/font_color_hover", loadRL.COLOR_HOVER)
