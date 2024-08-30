class StateUpdater
  def init(args)
    args.state.player = {
      x: 640, y: 360, w: 32, h: 32,
      speed: 5, hp: 100, max_hp: 100
    }
    args.state.enemies = []
    args.state.projectiles = []
    args.state.items = []
    args.state.camera = { x: 0, y: 0 }
    args.state.map = { width: 2000, height: 2000 }
    args.state.weapon = { cooldown: 0, max_cooldown: 30 }
    args.state.start_tick_count = args.state.tick_count
  end

  def update(args)
    update_camera(args)
    spawn_enemies(args)
    move_enemies(args)
    handle_collisions(args)
    update_projectiles(args)
    fire_weapon(args)
  end

  def update_camera(args)
    args.state.camera.x = args.state.player.x - 640
    args.state.camera.y = args.state.player.y - 360
  end

  def spawn_enemies(args)
    if args.state.enemies.length < 1000 && args.state.tick_count % 20 == 0
      # Calculate the camera's viewport
      viewport = {
        left: args.state.camera.x,
        right: args.state.camera.x + 1280,
        top: args.state.camera.y + 720,
        bottom: args.state.camera.y
      }

      # Generate a random position outside the viewport
      x = y = 0
      loop do
        x = rand(args.state.map.width)
        y = rand(args.state.map.height)
        break unless x.between?(viewport[:left], viewport[:right]) &&
                   y.between?(viewport[:bottom], viewport[:top])
      end

      args.state.enemies << {
        x: x,
        y: y,
        w: 16, h: 16, speed: 0.3, hp: 1
      }
    end
  end

  def move_enemies(args)
    args.state.enemies.each do |enemy|
      angle = Math.atan2(args.state.player.y - enemy.y, args.state.player.x - enemy.x)
      enemy.x += Math.cos(angle) * enemy.speed
      enemy.y += Math.sin(angle) * enemy.speed
    end
  end

  def handle_collisions(args)
    args.state.enemies.reject! do |enemy|
      if args.geometry.intersect_rect?(args.state.player, enemy)
        args.state.player.hp -= 1
        true
      end
    end
  end

  def update_projectiles(args)
    args.state.projectiles.reject! do |projectile|
      projectile.x += projectile.dx
      projectile.y += projectile.dy

      hit_enemy = args.state.enemies.find { |enemy| args.geometry.intersect_rect?(projectile, enemy) }
      if hit_enemy
        hit_enemy.hp -= 1
        args.state.enemies.reject! { |enemy| enemy.hp <= 0 }
        true
      else
        projectile.x < 0 || projectile.x > args.state.map.width ||
        projectile.y < 0 || projectile.y > args.state.map.height
      end
    end
  end

  def fire_weapon(args)
    args.state.weapon.cooldown -= 1 if args.state.weapon.cooldown > 0

    if args.state.weapon.cooldown <= 0 && !args.state.enemies.empty?
      nearest_enemies = args.state.enemies.select { |enemy|
        distance = Math.sqrt((enemy.x - args.state.player.x)**2 + (enemy.y - args.state.player.y)**2)
        distance <= 200
      }.sort_by { |enemy|
        Math.sqrt((enemy.x - args.state.player.x)**2 + (enemy.y - args.state.player.y)**2)
      }.first(5)
      target = nearest_enemies.sample
      return if target.nil?

      angle = Math.atan2(target.y - args.state.player.y, target.x - args.state.player.x)
      args.state.projectiles << {
        x: args.state.player.x, y: args.state.player.y,
        w: 16, h: 16, dx: Math.cos(angle) * 4, dy: Math.sin(angle) * 4
      }
      args.state.weapon.cooldown = args.state.weapon.max_cooldown
    end
  end
end
