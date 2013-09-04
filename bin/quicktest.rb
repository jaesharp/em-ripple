require 'eventmachine'
require 'em-websocket-client'
#require 'em-ripple'

class SWebSocketClient < EventMachine::WebSocketClient
  def self.connection_completed
    start_tls
  end
end

EM.run do

  conn = SWebSocketClient.connect("ws://s1.ripple.com:443/")

  conn.callback do
    conn.send_msg "{\"command\":\"subscribe\",\"id\":0,\"streams\":[\"ledger\",\"server\",\"transactions\"]}"
  end

  conn.stream do |msg|
    if msg == 'ping'
      conn.send_msg "pong"
      puts "got ping, responded"
    end
    puts "<#{msg}>"
  end

  conn.disconnect do
    puts "gone"
    EM::stop_event_loop
  end

  EM::PeriodicTimer.new(30) do
    puts "pinging"
    conn.send_msg("{\"command\":\"ping\"}")
  end

end
