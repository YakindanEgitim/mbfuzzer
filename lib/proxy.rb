require 'socket'
require 'thread'
require 'uri'
require 'cert.rb'
 
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
      datacount = 0
      
      line = connection.gets
      #extracts http header information
      type = line[/^GET|POST|CONNECT/]
      url = line[/^\w+\s+(\S+)/, 1]
      http = line[/HTTP\/(1\.\d)\s*$/, 1]
      uri = URI::parse(url)      
      
#TODO : CONNECT requests redirect  
#      if type == "CONNECT"        
#        puts type + uri.scheme
#        s = TCPSocket.new(host, port)
#        sslContext = OpenSSL::SSL::SSLContext.new(ssl_cert)
#        remote = OpenSSL::SSL::SSLSocket.new(s,sslContext)
#        remote.connect 
#        
#        remote.puts l
#        remote.gets
#        
#        remote.close        

        server = TCPSocket.new(uri.host, uri.port) 
      

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
       ensure    
          close(connection, server)   
        
  end

