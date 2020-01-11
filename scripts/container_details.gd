extends Control

const LINK = preload("res://scenes/link.tscn")

var loadRL
var rdy_to_play = false


func _ready():
	self.hide()
	
	# Get root ref
	loadRL = get_node("/root/loadRL")
	
	# Signals
	loadRL.connect("state_updated", self, "_update_details")
	loadRL.connect("game_selected", self, "_update_details")
	loadRL.connect("game_installed", self, "_update_details")
	loadRL.connect("ver_selected", self, "_update_details")
	
	# Styles
	$details_header/title_name.set("custom_colors/default_color", loadRL.COLOR_INSTALLED)
	$details_content.set("custom_colors/default_color", loadRL.COLOR_PARAGRAPH)
	$details_links/title_links.set("custom_colors/default_color", loadRL.COLOR_INSTALLED)
	$versions/label.set("custom_colors/default_color", loadRL.COLOR_INSTALLED)
	
	# Versions popup
	get_popup($versions).connect("index_pressed", self, "_on_popup_index_pressed")
	get_popup($versions).set("custom_constants/vseparation", 10)


# Update Game Details
func _update_details():
	if loadRL.selected:
		var slug = loadRL.selected
		# Game name
		$details_header/title_name.text = loadRL.make_ascii_title(loadRL.db[slug].name) + "\n\nby " + loadRL.db[slug].dev
		
		# Versions title
		if loadRL.selected_ver == loadRL.db[slug].versions.keys()[0]:
			$versions/label.text = ">> Set Version\n___________________"
		else:
			$versions/label.text = ">> Set Version (U!)\n___________________"	
		
		
		# Versions
		get_popup($versions).clear()
		for ver in loadRL.db[slug].versions:
			var text = ver
			if loadRL.is_installed(slug, ver):
				text += " (installed)"
				
			get_popup($versions).add_item(text)
		
		# Details
		$details_content.text = loadRL.db[slug].desc
		
		# Go btn
		_update_btn_go()
		
		# Links title
		$details_links/title_links.text = loadRL.make_ascii_title("Links")
		
		# Links
		loadRL.delete_children($details_links/container_links/vbox_links)
		if loadRL.db[slug].has("links"):
			var links = loadRL.db[slug].links.keys()
			for l in links:
				var new_link = LINK.instance()
				new_link.text = l.capitalize()
				new_link.url = loadRL.db[slug].links[l]
				$details_links/container_links/vbox_links.add_child(new_link)
		
		self.show()
	else: 
		self.hide()

func _update_btn_go():
	if loadRL.selected and loadRL.selected_ver:
		# Check if installed 
		if loadRL.is_installed(loadRL.selected, loadRL.selected_ver):
			rdy_to_play = true
			$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_GREEN)
			$details_header/btn_go/label.text = ">> PLAY\n"
		else:
			rdy_to_play = false
			$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_YELLOW)
			$details_header/btn_go/label.text = ">> INSTALL\n"
			
		$details_header/btn_go/label.text += "___________________\n\n"
		$details_header/btn_go/label.text += "v." + loadRL.selected_ver


# Helper to get the MenuButton popup created automatically
func get_popup(menu_button):
	for child in menu_button.get_children():
		if child is PopupMenu:
			return child


# Handle version selection
func _on_popup_index_pressed(index):
	var version = loadRL.db[loadRL.selected].versions.keys()[index]
	loadRL.set_default_ver(loadRL.selected, version)


# Hover
func _on_versions_mouse_entered():
	$versions/label.set("custom_colors/default_color", loadRL.COLOR_YELLOW)

func _on_versions_mouse_exited():
	$versions/label.set("custom_colors/default_color", loadRL.COLOR_INSTALLED)


func _on_btn_go_pressed():
	if loadRL.selected != null:
		if rdy_to_play:
			loadRL.run(loadRL.selected)
		else:
			loadRL.download_and_extract(loadRL.selected)


func _on_btn_go_mouse_entered():
	if rdy_to_play:
		$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_GREEN_HOVER)
	else:
		$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_YELLOW_HOVER)


func _on_btn_go_mouse_exited():
	if rdy_to_play:
		$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_GREEN)
	else:
		$details_header/btn_go/label.set("custom_colors/default_color", loadRL.COLOR_YELLOW)
