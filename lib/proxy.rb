require 'socket'
require 'thread'
require 'uri'
require './lib/cert.rb'
 #creates a TCP Server to catch requests
 def create(addr, port)
      server = TCPServer.new(addr, port)
      while
        s = server.accept
        Thread.new{ request(s) }
      end
  end
  
  # closes open connections
  def close(conn, srv)
     conn.close
     srv.close
  end

  #gathers http requests and sends to server;
  #repeats same job vice versa
  def request(connection)
      content=""
      type = nil
      
      content = connection.sysread(63535)
      #line = connection.gets
      head = content.split("\n")[0]
      #extracts http header information
      type = head[/^\w+/]
      url = head[/^\w+\s+(\S+)/, 1]
      http = head[/HTTP\/(1\.\d)\s*$/, 1]

      puts "Type:"+type+" URL:"+url+" HTTP:"+http

      if type == "CONNECT"
          server_host = head.split(" ")[1].split(":")[0]
          server_port = head.split(":")[1].split(" ")[0]
          con_server = TCPSocket.new(server_host,server_port)

          if con_server
            puts("HTTP/#{http} 200 Connection Established\r\n\r\n")
            connection.write("HTTP/#{http} 200 Connection Established\r\n\r\n")
            begin
            while data = connection.sysread(63535)
                puts "Client Data:\n"+data
                con_server.write data
                remote_data = con_server.sysread(63535)              
                puts "Remote Data:\n"+remote_data
                connection.write remote_data          
            end
            rescue Exception => httpsException
              puts "HTTPS Exception : #{httpsException}"
              con_server.close
              connection.close
            end           
          else
            connection.puts("Error")                          
          end          
      else
         uri = URI::parse(url)
         server = TCPSocket.new(uri.host, uri.port)
         if uri.query.nil?
            nhead="#{type} #{uri.path} HTTP/#{http}"
         else
            nhead="#{type} #{uri.path}?#{uri.query} HTTP/#{http}"
         end
         content.gsub!(head,nhead)
         puts "OLD Header :\n"+head
         puts "NEW Header :\n"+nhead
         puts "Last Content :\n"+content
         server.write content
   
         begin
           while  scontent = server.sysread(90000)
             #puts "Server Content :"+ scontent          
             connection.write scontent       
           end
         rescue Exception => httpException
           puts "HTTP Exception : #{httpException}"
           connection.close
           server.close
         end
       end
       ensure
          connection.close
          server.close   
          con_server.close  
  end

