require 'socket'
require 'thread'
require 'uri'
 
 #
 def create(addr, port)
      socket = TCPServer.new(addr, port)
                
      while
        s = socket.accept
        Thread.new{ request(s) }
      end        
  end
  
  #
  def open(uri)
     return TCPSocket.new(uri.host, uri.port)
  end
  
  # 
  def close(conn, srv)
     conn.close
     srv.close
  end

  #
  def request(connection)     
      content=""
      type = nil
      datacount = 0
      
      line = connection.gets
      type = line[/^GET|POST/]
      url = line[/^\w+\s+(\S+)/, 1]
      http = line[/HTTP\/(1\.\d)\s*$/, 1]
      uri = URI::parse(url)
      
      server = open(uri)
      server.puts("#{type} #{uri.path}?#{uri.query} HTTP/#{http}\r\n")
      
      while ( l = connection.gets)          
          if l =~ /^Content-Length:/
            datacount=l.split(":")[1].to_i
          end
          
          if l.strip.empty?
            server.puts("Connection: close\r\n\r\n")
            if datacount >= 0
                server.puts(connection.read(datacount))
            end
            break
          else
            server.puts(l)
          end
       end
       
       while
          server.read(90000, content)
          connection.puts(content)
          if content.size < 90000
            break
          end
       end     
       
       close(connection, server)      
   end

