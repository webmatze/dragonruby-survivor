require 'smaug'

def tick(args)
  init(args) if args.state.tick_count.zero?
  handle_input(args)
  update(args)
  render(args)
end

def init(args)
  args.state.player = {
    x: 640, y: 360, w: 50, h: 50,
    speed: 5, hp: 100, max_hp: 100
  }
  args.state.enemies = []
  args.state.projectiles = []
  args.state.items = []
  args.state.camera = { x: 0, y: 0 }
  args.state.map = { width: 2000, height: 2000 }
  args.state.weapon = { cooldown: 0, max_cooldown: 90 }
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
  if args.state.enemies.length < 10 && args.state.tick_count % 60 == 0
    args.state.enemies << {
      x: rand(args.state.map.width),
      y: rand(args.state.map.height),
      w: 30, h: 30, speed: 2, hp: 1
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
    target = args.state.enemies.sample
    angle = Math.atan2(target.y - args.state.player.y, target.x - args.state.player.x)
    args.state.projectiles << {
      x: args.state.player.x, y: args.state.player.y,
      w: 10, h: 10, dx: Math.cos(angle) * 4, dy: Math.sin(angle) * 4
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
end

def render_map(args)
  args.outputs.solids << [0, 0, args.state.map.width, args.state.map.height, 200, 200, 200]
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

def render_ui(args)
  args.outputs.labels << [10, 710, "HP: #{args.state.player.hp}/#{args.state.player.max_hp}"]
  args.outputs.labels << [10, 690, "Enemies: #{args.state.enemies.length}"]
end
