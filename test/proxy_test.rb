require './lib/proxy.rb'

#if ARGV.empty?
#  address = "127.0.0.1"
#  port = 8080
#elsif ARGV.size == 2
#  address = ARGV[0]
#  port = ARGV[1]
#else
#  puts "Proxy Library Usage: proxy.rb [address][port]"
#  exit 1
#end
 
address = "127.0.0.1"
port = 8080

create(address, port)
