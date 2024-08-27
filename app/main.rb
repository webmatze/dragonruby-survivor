require 'smaug'

def tick(args)
  init(args) if args.state.tick_count.zero?
  handle_input(args)
  update(args)
  render(args)
end

def init(args)
  args.state.player = {
    x: 640,
    y: 360,
    w: 50,
    h: 50,
    speed: 5
  }
end

def handle_input(args)
  if args.inputs.keyboard.left
    args.state.player.x -= args.state.player.speed
  elsif args.inputs.keyboard.right
    args.state.player.x += args.state.player.speed
  end

  if args.inputs.keyboard.up
    args.state.player.y += args.state.player.speed
  elsif args.inputs.keyboard.down
    args.state.player.y -= args.state.player.speed
  end
end

def update(args)
  # Add game logic here
end

def render(args)
  args.outputs.solids << [args.state.player.x, args.state.player.y, args.state.player.w, args.state.player.h, 255, 0, 0]
end
