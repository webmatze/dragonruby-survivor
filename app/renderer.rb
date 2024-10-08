class Renderer
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
    player = args.state.player

    args.outputs.sprites << {
      x: player.x - args.state.camera.x,
      y: player.y - args.state.camera.y,
      w: player.w,
      h: player.h,
      path: 'sprites/player.png',
      flip_horizontally: player.flip_horizontally
    }
  end

  def render_enemies(args)
    enemy_sprites = args.state.enemies.map do |enemy|
      [
        enemy.x - args.state.camera.x,
        enemy.y - args.state.camera.y,
        enemy.w,
        enemy.h,
        'sprites/enemy.png'
      ]
    end
    args.outputs.sprites << enemy_sprites
  end

  def render_projectiles(args)
    projectile_sprites = args.state.projectiles.map do |projectile|
      [
        projectile.x - args.state.camera.x,
        projectile.y - args.state.camera.y,
        projectile.w,
        projectile.h,
        'sprites/projectile.png'
      ]
    end
    args.outputs.sprites << projectile_sprites
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
end
