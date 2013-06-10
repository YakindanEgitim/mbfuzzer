require './lib/proxy.rb'

if ARGV.empty?
  address = "127.0.0.1"
  port = 8080
elsif ARGV.size == 2
  address = ARGV[0]
  port = ARGV[1]
else
  puts "MBProxy Library Usage:\n\t mbfuzzer.rb [address] [port]"
  exit 1
end


MBProxy.new(address,port)

