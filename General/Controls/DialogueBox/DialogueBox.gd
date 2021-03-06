extends Control

signal signal_dialogue_completed
signal signal__dialogbox__finished_dialog

onready var dialogueRichTextLabel = $NinePatchRect/DialogueRichTextLabel
onready var dialogueTween = $DialogueTween

onready var portraitPopupRoot = get_parent().get_node("PortraitPopupRoot")

var active: bool = false

var connection_status: bool = true

var interaction_yes_or_no_selection: String = ""

func _ready():
	
	self.hide()
	
	Singleton_Game_GlobalCommonVariables.dialogue_box_node = self
	
	# Singleton_Game_GlobalBattleVariables.dialogue_box_node = self
	
	dialogueTween.connect("tween_completed", self, "s_battle_message_complete")
	dialogueTween.connect("tween_completed", self, "_on_Tween_tween_completed")
	connection_status = true
	
	# wait till all the children are loaded and an idle frame starts maybe not the best idea????
	# yield(get_tree(), "idle_frame")
	
	# self.connect("signal_texture_action", 
	# node, 
	# "_toggle_texture_visibility")
	
	# self.connect("signal__dialogbox__finished_dialog", 
	# node, 
	# "_finished_dialog")
	
	_process_new_resource_file()
	
	pass


func battle_message_play(str_arg = "") -> void:
	dialogueTween.connect("tween_completed", self, "s_battle_message_complete")
	Singleton_Game_GlobalBattleVariables.dialogue_box_node.rect_position = Vector2(72, 160)
	dialogueRichTextLabel.percent_visible = 0
	dialogueRichTextLabel.show()
	
	dialogueRichTextLabel.bbcode_text = str_arg
	
	dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible",
	0, 1, 
	GetTweenTimeForText(str_arg), 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	dialogueTween.start()


func s_battle_message_complete(_node_arg, _property_arg) -> void: 
	# dialogueTween.connect("tween_completed", self, "s_battle_message_complete")
	# print("Tween completed ", node_arg, " ", property_arg)
	# yield(get_tree().create_timer(1.5), "timeout")
	
	# Singleton_Game_GlobalBattleVariables.dialogue_box_node.rect_position = Vector2(72, 262)
	# dialogueRichTextLabel.hide()
	
	emit_signal("signal_dialogue_completed")


func play_message(str_arg = "") -> void:
	Clean()
	
	# dialogueTween.disconnect("tween_completed", self, "s_battle_message_complete")
	connection_status = true
	
	dialogueRichTextLabel.percent_visible = 0
	dialogueRichTextLabel.bbcode_text = ""
	
	visible = true
	dialogue_box_is_visible = visible
	Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active = true
	active = true
	
	# dialogue_index = 999999999999
	
	# Singleton_Game_GlobalBattleVariables.dialogue_box_node.rect_position = Vector2(72, 160)
	
	dialogueRichTextLabel.show()
	dialogueRichTextLabel.bbcode_text = str_arg
	
	dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible",
	0, 1, 
	GetTweenTimeForText(str_arg), 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	dialogueTween.start()
	
	# yield(get_tree().create_timer(0.5), "timeout")
	# get_tree().paused = true




func play_message_none_interactable(str_arg = "") -> void:
	Clean()
	
	# dialogueTween.disconnect("tween_completed", self, "s_battle_message_complete")
	# dialogueTween.disconnect("tween_completed", self, "_on_Tween_tween_completed")
	connection_status = false
	
	dialogueRichTextLabel.percent_visible = 0
	dialogueRichTextLabel.bbcode_text = ""
	
	visible = true
	dialogue_box_is_visible = visible
	Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active = false
	active = false
	
	# Singleton_Game_GlobalBattleVariables.dialogue_box_node.rect_position = Vector2(72, 160)
	
	dialogueRichTextLabel.show()
	dialogueRichTextLabel.bbcode_text = str_arg
	
	dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible",
	0, 1, 
	GetTweenTimeForText(str_arg), 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	dialogueTween.start()
	
	# yield(get_tree().create_timer(0.5), "timeout")
	# get_tree().paused = true


# signal signal__dialoguebox__finished_dialog

export(Dictionary) var ON_END_DICT = {}

export(String, FILE, '*.json') var external_file = ''
var parsed_external_file = {}

var dialogue = {}

var dialogue_index = 0
var finished = false

var dialogue_box_is_visible = true

var wait_for_user_input_end = false


func Clean() -> void: 
	dialogue = {}
	dialogue_index = 0

func _process_new_resource_file():
	var file = File.new()
	print(external_file)
	if external_file != "":
		file.open(external_file, file.READ)
		parsed_external_file = JSON.parse(file.get_as_text())
	
		if parsed_external_file.error == OK:
			var data = parsed_external_file.result
			dialogue_index = 0
			dialogue = data.script
		else:
			print("Error: ", parsed_external_file.error)
			print("\tError Line: ", parsed_external_file.error_line)
			print("\tError String: ", parsed_external_file.error_string)
	
		file.close()
		
		connection_status = true
		
		visible = true
		dialogue_box_is_visible = visible
		Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active = true
		load_dialog()
	else:
		dialogueRichTextLabel.bbcode_text = "Add script file - (file a bug report)"
		finished = true


func _process(_delta):
	if !active:
		return
	
	if visible == false:
		# dont process dialog if the dialog is hidden
		return
		
	# if (Input.is_action_just_pressed("ui_a_key") || Input.is_action_just_pressed("ui_accept")) and !wait_for_user_input_end:
	if (Input.is_action_just_pressed("ui_a_key") || Input.is_action_just_pressed("ui_accept")):
		# yield(get_tree().create_timer(0.1), "timeout")
		if finished:
			load_dialog()
		else:
			dialogueTween.stop(dialogueRichTextLabel, "percent_visible")
			dialogueTween.emit_signal("tween_completed", self, "DialogueLineRevealComplete")
			dialogueRichTextLabel.percent_visible = 1
			finished = true
			Singleton_Game_AudioManager.stop_dialogue_sfx()


func _input(event):
	if(event.is_action_pressed("ui_hide")) and !wait_for_user_input_end:
		if Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active:
			visible = !dialogue_box_is_visible
			dialogue_box_is_visible = visible


func load_dialog():
	print("Here")
	active = true
	
		
	# dialogueTween.connect("tween_completed", self, "s_battle_message_complete")
	# dialogueTween.connect("tween_completed", self, "_on_Tween_tween_completed")
	
	if dialogue_index < dialogue.size():
		finished = false
		Singleton_Game_AudioManager.play_dialogue_sfx()
		
		var itkeys = dialogue[dialogue_index].keys()
		# print(ikeys)
		
		for key in dialogue[dialogue_index]:
			print("Inner Loop key - ", key + " - value is - " + str(dialogue[dialogue_index][key]))
			if key == "Text":
				dialogueRichTextLabel.bbcode_text = check_and_replace_text_sub_points(dialogue[dialogue_index][key])
				# continue
				
				print(itkeys.size())
				
				portraitPopupRoot.PlayTalkingAnimation()
				
				if itkeys.size() >= 2:
					dialogueRichTextLabel.percent_visible = 0
					dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 
					GetTweenTimeForText(dialogueRichTextLabel.bbcode_text), 
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					dialogueTween.start()
					continue
				else:
					dialogueRichTextLabel.percent_visible = 0
					dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 
					GetTweenTimeForText(dialogueRichTextLabel.bbcode_text), 
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					dialogueTween.start()
				
#				if itkeys.size() <= 1:
#					# dialogue_index += 1
#					dialogueRichTextLabel.percent_visible = 0
#					dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#					dialogueTween.start()
#					continue
#				else:
#					dialogue_index += 1
#					# dialogueRichTextLabel.percent_visible = 0
#					# dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#					# dialogueTween.start()
#
#					pass
#				pass
				
			elif key == "Expression":
				var expression := Expression.new()
				for command in dialogue[dialogue_index][key]:
					var command_split = command.split(" -|- ")
					#print(str(command_split))
					print(command)
					var error = expression.parse(str(command_split[1]), [])
					
					if error != OK:
						print(expression.get_error_text())
						break
					var result = expression.execute([], get_node(str(command_split[0])), true)
					if expression.has_execute_failed():
						print("Failed to execute expression", result)
					else:
						print("Success", result)
						
				dialogue_index += 1
				load_dialog()
				return
			elif key == "Sound":
				var sound_to_play = dialogue[dialogue_index][key].split(" | ")
				# sound to play 0 is type fx for sound effect and eventually music to change background music
				Singleton_Game_AudioManager.play_sfx(sound_to_play[1])
				
				print(sound_to_play[2])
				
				if sound_to_play[2] == "yield":
					active = false
					Singleton_Game_AudioManager.pause_all_music()
					yield(Singleton_Game_AudioManager, "signal__audio_manager__soundeffect__finished")
					Singleton_Game_AudioManager.pause_all_sfx()
					Singleton_Game_AudioManager.resume_all_music()
				
				dialogue_index += 1
				active = true
				load_dialog()
				return
			elif key == "ShowPortrait":
				#var portrait_args = dialogue[dialogue_index][key].split(" | ")
				var portrait_args = dialogue[dialogue_index][key]
				print(dialogue[dialogue_index][key])
				
				# sound to play 0 is type fx for sound effect and eventually music to change background music
				
				portraitPopupRoot.show()
				portraitPopupRoot.load_portrait(portrait_args)
				portraitPopupRoot.PlayDefaultAnimation()
				dialogue_index += 1
				load_dialog()
				return
			elif key == "HidePortrait":
				#var portrait_args = dialogue[dialogue_index][key].split(" | ")
				
				portraitPopupRoot.hide()
				
				dialogue_index += 1
				load_dialog()
				return
			elif key == "ShowMenu":
				
				ShowMenu(dialogue[dialogue_index][key])
				
				finished = true
				Singleton_Game_AudioManager.stop_dialogue_sfx()
				visible = false
				active = false
				emit_signal("signal__dialogbox__finished_dialog")
				Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active = false
				
				# if Singleton_Game_GlobalCommonVariables.interaction_node_reference != null:
				# 	Singleton_Game_GlobalCommonVariables.interaction_node_reference.interaction_completed()
					
				return
			elif key == "InteractionPrompt":
				
				print("hereeee")
				yield(dialogueTween, "tween_completed")
				
				active = false
				Singleton_Game_GlobalCommonVariables.menus_root_node.UserInteractionPromptsRoot.s_show__yes_or_no_prompt()
			
				# 
				# dialogueRichTextLabel.percent_visible = 0
				# dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				# dialogueTween.start()
				
				# var display_str = "I'm very sorry!\nI'm out of stock!\nDo you want anything else?"
				# Singleton_Game_GlobalCommonVariables.dialogue_box_node.play_message_none_interactable(display_str)
				
				# dialogue_index += 1
				
				
				Singleton_Game_GlobalCommonVariables.menus_root_node.UserInteractionPromptsRoot.s_show__yes_or_no_prompt()
				var result = yield(Singleton_Game_GlobalCommonVariables.menus_root_node.UserInteractionPromptsRoot.YesOrNoPromptRoot, "signal__yes_or_no_prompt__choice")
				if result == "NO":
					Singleton_Game_GlobalCommonVariables.interaction_yes_or_no_selection = "NO"
					print("No")
					
					var remaining_lines = dialogue.size() - dialogue_index
					for _x in remaining_lines:
						
						var ikeys = dialogue[dialogue_index].keys()
						print(ikeys)
						
						if ikeys.size() <= 1:
							continue
						
						# for ikey in dialogue[dialogue_index]:
						# print(ikey)
						print(dialogue[dialogue_index])
						print(dialogue[dialogue_index][ikeys[1]])
						if ikeys[0] == "InteractionAnswer":
							if dialogue[dialogue_index][ikeys[0]] == "NO":
								# print(dialogue[dialogue_index][ikey])
								print(dialogue[dialogue_index][ikeys[1]])
								
								Singleton_Game_GlobalCommonVariables.dialogue_box_node.external_file = dialogue[dialogue_index][ikeys[1]]
								Singleton_Game_GlobalCommonVariables.dialogue_box_node._process_new_resource_file()
								return
							else:
								dialogue_index += 1
						else:
							dialogue_index += 1
					pass
				elif result == "YES":
					Singleton_Game_GlobalCommonVariables.interaction_yes_or_no_selection = "YES"
					print("Yes")
					
					var remaining_lines = dialogue.size() - dialogue_index
					for _x in remaining_lines:
						
						var ikeys = dialogue[dialogue_index].keys()
						print(ikeys)
						
						if ikeys.size() <= 1:
							continue
						
						# for ikey in dialogue[dialogue_index]:
						# print(ikey)
						print(dialogue[dialogue_index])
						print(dialogue[dialogue_index][ikeys[1]])
						if ikeys[0] == "InteractionAnswer":
							if dialogue[dialogue_index][ikeys[0]] == "YES":
								# print(dialogue[dialogue_index][ikey])
								print(dialogue[dialogue_index][ikeys[1]])
								
								Singleton_Game_GlobalCommonVariables.dialogue_box_node.external_file = dialogue[dialogue_index][ikeys[1]]
								Singleton_Game_GlobalCommonVariables.dialogue_box_node._process_new_resource_file()
								return
							else:
								dialogue_index += 1
						else:
							dialogue_index += 1
					
					pass
				
				# dialogue_index += 1
				# load_dialog()
				
				return
			
			
			
			dialogue_index += 1
			# dialogueRichTextLabel.percent_visible = 0
			# dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			# dialogueTween.start()
				
#			dialogue_index += 1
#			dialogueRichTextLabel.percent_visible = 0
#			dialogueTween.interpolate_property(dialogueRichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#			dialogueTween.start()
	else:
		finished = true
		Singleton_Game_AudioManager.stop_dialogue_sfx()
		visible = false
		active = false
		emit_signal("signal__dialogbox__finished_dialog")
		Singleton_Game_GlobalCommonVariables.dialogue_box_is_currently_active = false
		interaction_yes_or_no_selection = ""
		# Singleton_Game_GlobalCommonVariables.dialogue_box_node.external_file = ""
		# dialogue_index = 0
		# dialogue = null
		get_parent().get_node("PortraitPopupRoot").hide()
		
		portraitPopupRoot.StopAnimation()
		
		if Singleton_Game_GlobalCommonVariables.interaction_node_reference != null:
			Singleton_Game_GlobalCommonVariables.interaction_node_reference.interaction_completed()


func _on_Tween_tween_completed(_object, _key):
	if !connection_status:
		return
	
	portraitPopupRoot.PlayDefaultAnimation()
	Singleton_Game_AudioManager.stop_dialogue_sfx()
	
	print("Tween complete Dialgoue")
	finished = true


func check_and_replace_text_sub_points(str_arg: String) -> String:
	var nstr = str_arg
	
	if "{main_character_name}" in nstr:
		nstr = nstr.replace("{main_character_name}", Singleton_Game_GlobalCommonVariables.main_character_player_node.get_actor_name())
	
	return nstr


func ShowMenu(string_arg: String) -> void:
	if string_arg == "HQMenu":
		Singleton_Game_GlobalCommonVariables.main_character_player_node.set_active_processing(false)
		Singleton_Game_GlobalCommonVariables.menus_root_node.HQMenuWrapperRoot.s_show_hq_menu()
	elif  string_arg == "PriestMenu":
		Singleton_Game_GlobalCommonVariables.main_character_player_node.set_active_processing(false)
		Singleton_Game_GlobalCommonVariables.menus_root_node.PriestMenuWrapperRoot.s_show_priest_menu()
	elif  string_arg == "ShopMenu":
		# print(Singleton_Game_GlobalCommonVariables.interaction_node_reference.ITEM_LIST)
		Singleton_Game_GlobalCommonVariables.menus_root_node.ShopMenuWrapperNode.ShopItemSelectionMenu.insert_item_list(Singleton_Game_GlobalCommonVariables.interaction_node_reference.ITEM_LIST)
		Singleton_Game_GlobalCommonVariables.main_character_player_node.set_active_processing(false)
		Singleton_Game_GlobalCommonVariables.menus_root_node.ShopMenuWrapperNode.s_show_shop_menu()


func GetTweenTimeForText(text_str: String) -> float:
	var tweenTime = text_str.length() / 40
	if tweenTime == 0:
		tweenTime = 0.5
	
	# TODO: add in general settings different speeds
	# setting a min and max and possibliy a instant reveal
	
	print("tweenTime - ", tweenTime)
	
	return tweenTime
