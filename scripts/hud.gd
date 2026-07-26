extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var lives_label = $LivesLabel
@onready var enemy_label = $EnemyLabel
@onready var win_timer = $WinTimer
var enemies = 0

func _process(_delta: float) -> void:
	lives_label.text = "Lives: " + str(player.lives)
	enemy_label.text = "Enemies left: " + str(enemies)
	if enemies <= 0 and win_timer.is_stopped():
		win_timer.start()

func _input(event):
	if event.is_action_pressed("pause"):
		var tree = get_tree()
		if not tree.paused:
			tree.paused = true
			move_pause_panel()

func move_pause_panel():
	var pausePanel = $PausePanel
	pausePanel.position = Vector2(490.0, -400)
	pausePanel.visible = true
	var tween = pausePanel.create_tween()
	tween.tween_property(pausePanel, "position", Vector2(490.0, 210.0), 0.5)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	$PausePanel/PauseTweenTimer.start()

func move_over_panel(text):
	var panel = $GameOverPanel
	$GameOverPanel/Label.text = text
	panel.position = Vector2(490.0, -400)
	panel.visible = true
	var tween = panel.create_tween()
	tween.tween_property(panel, "position", Vector2(490.0, 210.0), 0.5)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	$GameOverPanel/OverTweenTimer.start()

func _on_resume_button_pressed() -> void:
	var pausePanel = $PausePanel
	pausePanel.position = Vector2(220, -400)
	pausePanel.visible = false
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_tween_timer_timeout() -> void:
	$PausePanel/ResumeButton.grab_focus()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_over_tween_timer_timeout() -> void:
	$GameOverPanel/RestartButton.grab_focus()

func _on_win_timer_timeout() -> void:
	get_tree().paused = true
	move_over_panel("You Win!")
