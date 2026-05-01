extends Projectile

func on_collide(collider: Object, normal: Vector2):
	if !enemy and collider is Enemy and !already_hit.has(collider):
		collider.take_damage(damage, cold, lifesteal)
		if hit_sound != null:
			hit_sound.play()
		if bounces > 0:
			var speed = velocity.length()
			var ri = velocity.normalized()
			velocity = (-ri - 2 * normal * (ri.dot(normal))).normalized() * speed
			global_position += velocity * 0.01
			bounces -= 1
			already_hit.push_back(collider)
		else:
			die()
