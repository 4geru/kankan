require 'webrick'

params = {
    :DocumentRoot => './coverage',
    :BindAddress => '0.0.0.0',
    :Port => 8080
}

srv = WEBrick::HTTPServer.new(params)

trap(:INT){ srv.shutdown }
srv.start