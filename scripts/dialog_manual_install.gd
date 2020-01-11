extends Node2D

var loadRL
var message = "This is a dialog"
var bttn1_text = "OK"
var bttn1_action 

var bttn2_text = "Cancel"
var bttn_action

func _ready():
	loadRL = get_node("/root/loadRL")

	$box/msg.text = message
	$box/bttn1/label.text = bttn1_text
	$box/bttn2/label.text = bttn2_text
	$box/msg.set("custom_colors/font_color", loadRL.COLOR_RED)
	$box/bttn1/label.set("custom_colors/font_color", loadRL.COLOR_YELLOW)
	$box/bttn2/label.set("custom_colors/font_color", loadRL.COLOR_YELLOW)

func _on_bttn1_pressed():
	self.queue_free()

func _on_bttn1_mouse_entered():
	$box/bttn1/label.set("custom_colors/font_color", loadRL.COLOR_NOT_INSTALLED)

func _on_bttn1_mouse_exited():
	$box/bttn1/label.set("custom_colors/font_color", loadRL.COLOR_YELLOW)

func _on_bttn2_pressed():
	self.queue_free()

func _on_bttn2_mouse_entered():
	$box/bttn2/label.set("custom_colors/font_color", loadRL.COLOR_GREEN)

func _on_bttn2_mouse_exited():
	$box/bttn2/label.set("custom_colors/font_color", loadRL.COLOR_YELLOW)