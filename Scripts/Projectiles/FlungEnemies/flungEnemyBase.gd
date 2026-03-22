extends "../Player/projectlePlayerBase.gd"

func _process(delta: float) -> void:
	if alive:
		rotation += delta * 20

func enemyColliion(enemyNode):
	if enemyNode.onHit(attackDamage,self):
		projectileDeath(false, true)
		$EnemyCollideSound.play()
