class InputHandler
  def handle_input(args)
    player = args.state.player

    # Keyboard movement
    player.x -= player.speed if args.inputs.keyboard.left
    player.x += player.speed if args.inputs.keyboard.right
    player.y += player.speed if args.inputs.keyboard.up
    player.y -= player.speed if args.inputs.keyboard.down

    # Mouse movement
    if args.inputs.mouse.button_left
      mouse_x = args.inputs.mouse.x + args.state.camera.x
      mouse_y = args.inputs.mouse.y + args.state.camera.y
      angle = Math.atan2(mouse_y - player.y, mouse_x - player.x)
      player.x += Math.cos(angle) * player.speed
      player.y += Math.sin(angle) * player.speed
    end

    # Keep player within map bounds
    player.x = player.x.clamp(0, args.state.map.width - player.w)
    player.y = player.y.clamp(0, args.state.map.height - player.h)

    # Restart the game when 'R' key is pressed
    restart(args) if args.inputs.keyboard.key_down.r
  end

  def restart(args)
    StateUpdater.new.init(args)
  end
end
