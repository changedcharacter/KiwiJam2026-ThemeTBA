extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group("player")
@onready var lives_label = $LivesLabel
@onready var enemy_label = $EnemyLabel
var enemies = 0

func _ready() -> void:
	player.connect("hit", update_lives_label)
	update_lives_label()

func _process(_delta: float) -> void:
	enemy_label.text = "Enemies left: " + str(enemies)

func _input(event):
	if event.is_action_pressed("pause"):
		var tree = get_tree()
		if not tree.paused:
			tree.paused = true
			move_pause_panel()

func update_lives_label():
	lives_label.text = "Lives: " + str(player.lives)

func move_pause_panel():
	var pausePanel = $PausePanel
	pausePanel.position = Vector2(490.0, -400)
	pausePanel.visible = true
	var tween = pausePanel.create_tween()
	tween.tween_property(pausePanel, "position", Vector2(490.0, 210.0), 0.5)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	$PausePanel/TweenTimer.start()

func _on_resume_button_pressed() -> void:
	var pausePanel = $PausePanel
	pausePanel.position = Vector2(220, -400)
	pausePanel.visible = false
	get_tree().paused = false

func _on_tween_timer_timeout() -> void:
	$PausePanel/ResumeButton.grab_focus()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
