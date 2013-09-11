require 'eventmachine'
require 'em-ripple/ripple/client/peer/transports/secure_web_socket'

EM.run do

  conn = EMRipple::Ripple::Client::Peer::Transports::SecureWebSocket.connect('s1.ripple.com', port: 443)

  conn.on_handshake_completed do
    conn.send_command "{\"command\":\"subscribe\",\"id\":54684,\"streams\":[\"ledger\",\"server\",\"transactions\"]}"
  end

  conn.on_response_received do |issuing_command, response|
    puts "<#{response}>"
  end

  conn.on_disconnect do
    puts "gone"
    EM::stop_event_loop
  end

  EM::PeriodicTimer.new(30) do
    puts "pinging"
    conn.send_command("{\"command\":\"ping\"}")
  end

end
