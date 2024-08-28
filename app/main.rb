require 'app/input_handler'
require 'app/state_updater'
require 'app/renderer'

def tick(args)
  state_updater.init(args) if args.state.tick_count.zero?
  input_handler.handle_input(args)
  state_updater.update(args)
  renderer.render(args)
end

def state_updater
  @state_updater ||= StateUpdater.new
end

def input_handler
  @input_handler ||= InputHandler.new
end

def renderer
  @renderer ||= Renderer.new
end
