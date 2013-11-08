require 'cube'

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  cube = Cube::Client.new 'gprpc32.kbs.msu.edu'
  duration = (finish - start) * 1000
  cube.send 'md', start, response: duration, path: payload[:path]
end
