require 'smaug'

def tick(args)
  init(args) if args.state.tick_count.zero?
  handle_input(args)
  update(args)
  render(args)
end

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
  args.state.weapon = { cooldown: 0, max_cooldown: 90 }
  args.state.start_tick_count = args.state.tick_count
end

def restart(args)
  init(args)
end

def handle_input(args)
  player = args.state.player
  player.x -= player.speed if args.inputs.keyboard.left
  player.x += player.speed if args.inputs.keyboard.right
  player.y += player.speed if args.inputs.keyboard.up
  player.y -= player.speed if args.inputs.keyboard.down

  # Keep player within map bounds
  player.x = player.x.clamp(0, args.state.map.width - player.w)
  player.y = player.y.clamp(0, args.state.map.height - player.h)

  # Restart the game when 'R' key is pressed
  restart(args) if args.inputs.keyboard.key_down.r
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
    args.state.enemies << {
      x: rand(args.state.map.width),
      y: rand(args.state.map.height),
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

def render(args)
  render_map(args)
  render_player(args)
  render_enemies(args)
  render_projectiles(args)
  render_ui(args)
  render_survival_time(args)
end

def render_map(args)
  args.outputs.background_color = [0, 0, 0]
  args.outputs.solids << [
    -args.state.camera.x,
    -args.state.camera.y,
    args.state.map.width,
    args.state.map.height,
    200, 200, 200
  ]
end

def render_player(args)
  args.outputs.sprites << [
    args.state.player.x - args.state.camera.x,
    args.state.player.y - args.state.camera.y,
    args.state.player.w,
    args.state.player.h,
    'sprites/player.png'
  ]
end

def render_enemies(args)
  args.state.enemies.each do |enemy|
    args.outputs.sprites << [
      enemy.x - args.state.camera.x,
      enemy.y - args.state.camera.y,
      enemy.w,
      enemy.h,
      'sprites/enemy.png'
    ]
  end
end

def render_projectiles(args)
  args.state.projectiles.each do |projectile|
    args.outputs.sprites << [
      projectile.x - args.state.camera.x,
      projectile.y - args.state.camera.y,
      projectile.w,
      projectile.h,
      'sprites/projectile.png'
    ]
  end
end

def render_label_with_shadow(args, x, y, text, size = 0)
  args.outputs.labels << [x + 1, y - 1, text, size, 0, 0, 0, 0]  # Black shadow
  args.outputs.labels << [x, y, text, size, 255, 255, 255, 255]  # White text
end

def render_ui(args)
  render_label_with_shadow(args, 10, 710, "HP: #{args.state.player.hp}/#{args.state.player.max_hp}")
  render_label_with_shadow(args, 10, 690, "Enemies: #{args.state.enemies.length}")
end

def render_survival_time(args)
  survival_time = (args.state.tick_count - args.state.start_tick_count) / 60  # Convert ticks to seconds
  minutes = survival_time / 60
  seconds = survival_time % 60
  time_text = format('%02d:%02d', minutes, seconds)
  render_label_with_shadow(args, 640, 700, time_text, 5)
end
