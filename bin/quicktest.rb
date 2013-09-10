require 'eventmachine'
require 'em-ripple/ripple/client/peer/transports/secure_web_socket'

EM.run do

  conn = EMRipple::Ripple::Client::Peer::Transports::SecureWebSocket.connect('s1.ripple.com', port: 443)

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
