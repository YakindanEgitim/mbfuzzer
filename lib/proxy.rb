require 'socket'
require 'openssl'
require 'zlib'
require 'thread'
require 'timeout'
require 'uri'
require './lib/cert.rb'
require './lib/mbcontent.rb'


class MBProxy

  	#creates server to handle requests
  	def initialize(addr, port)
    		begin
      			@socket = TCPServer.new(addr, port)

			@cert_store = OpenSSL::X509::Store.new()
            		@cert_store.set_default_paths		

      			@threads = []
			@mbcontent = MBContent.new(File.open('./config/mbconfig.cfg'))

      			while
        			s = @socket.accept
        			@threads << Thread.new{ request(s) }
      			end
    		rescue Interrupt
      			puts "Interrupt handled"
    		ensure
      			stop
    		end  
  	end
  
  	def stop
    		@threads.each do |thread|
      			Thread.kill(thread)
    		end
    		@socket.close
  	end

	# closes open connections
	def close(conn, srv)
  		conn.close
  		srv.close
	end

	#open ssl connection
	def ssl_open(host,port)
  		s = TCPSocket.new(host, port)
  		sslContext = OpenSSL::SSL::SSLContext.new
    		sslContext.ca_path ='/etc/ssl/certs'
    		sslContext.verify_mode = OpenSSL::SSL::VERIFY_NONE
  		ssl = OpenSSL::SSL::SSLSocket.new(s,sslContext)
  		ssl.sync = true
  		ssl.connect
  		return s,ssl
	end

	#close ssl connection
	def ssl_close(s,ssl)  
  		ssl.close
  		s.close
	end

	def read_http(sock)
    		content = ""
    		while sock

        		content << sock.sysread(90000)
        		#content.gsub!("Accept-Encoding: gzip, deflate","Accept-Encoding: sdhc")
        		#content.gsub!("Accept-Encoding: gzip","Accept-Encoding: sdhc")

        		#if content =~ /Content-Length:\s*(.*)$/i
        		#  content << sock.sysread($i)
        		#  break

        		if content =~ /Transfer-Encoding: chunked/
            			break if content.include?("\r\n0\r\n")
        		elsif content.include?("\r\n\r\n") or content.include?("\n\n") 
            			break
        		end
    		end

    		return content
	end 


	#receiving data from server and redirecting to client
	def recv_send_4_server(server,client)
		tmp_content = ""
  		begin
    			Timeout::timeout(10) {
    				while scontent = server.sysread(1)
					tmp_content = "#{tmp_content}#{scontent}"
      					#client.write scontent 
      					break if scontent.length < 1
    				end
				#client.write @mbcontent.analyse_content(tmp_content)
    			}
  		rescue Exception::EFOError
  		rescue Timeout::Error
    			puts "HTTP Exception : Socket Timed out!"
  		rescue Exception => httpException
    			puts "HTTP Exception : #{httpException}"
  		ensure
			
  		    	if tmp_content =~ /Transfer-Encoding: chunked/
            			client.write tmp_content
  		    	else
  		      		client.write @mbcontent.analyse_content(tmp_content)
  		    	end
    			client.close
    			server.close   
  		end
	end

	def cert_gen(serverssl)
  		begin
  			sslContext = OpenSSL::SSL::SSLContext.new
    			sslContext.cert = OpenSSL::X509::Certificate.new(File.open('./certs/server.crt'))
    			sslContext.key = OpenSSL::PKey::RSA.new(File.open('./certs/server.key'))
    			sslContext.ca_file = './certs/cacert.pem'
    			sslContext.ca_path ='/etc/ssl/certs'

  			#this part will use on-the-fly valid ssl certificate generation
  			#ncert,nkey = Cert.new.ssl_cert(OpenSSL::X509::Certificate.new(serverssl.peer_cert))
  			#sslContext.cert = OpenSSL::X509::Certificate.new(ncert)
  			#sslContext.key = OpenSSL::PKey::RSA.new(nkey)

    			sslContext.verify_mode = OpenSSL::SSL::VERIFY_NONE
  		rescue Exception => sslException
    			puts "Certification Exception : #{sslException}"
  		end
  		return sslContext
	end

	#creating ssl io object
	def ssl_io(io,sslContext)
  		begin
    			sslio = OpenSSL::SSL::SSLSocket.new(io, sslContext)
    			sslio.sync_close = true
    			sslio.accept
  		rescue Exception => sslException
    			puts "SSL Exception : #{sslException}"
  		end
  		return sslio
	end

	#zlip inflate for gunzip
	def inflate(string)
      		zstream = Zlib::Inflate.new
      		buf = zstream.inflate(string)
    		zstream.finish
      		zstream.close
      		buf
	end


	#gathers http requests and sends to server;
	#repeats same job vice versa
	def request(prx_client)
  		content=""
  		type = nil

  		content = prx_client.sysread(63535)
  		head = content.split("\n")[0]

  		#extracts http header information
  		type = head[/^\w+/]
  		url = head[/^\w+\s+(\S+)/, 1]
  		http = head[/HTTP\/(1\.\d)\s*$/, 1]

  		if type == "CONNECT"
    			#opening remote ssl connection
    			server_host = head.split(" ")[1].split(":")[0]
    			server_port = head.split(":")[1].split(" ")[0]
    			prx_tcpserver,prx_sslserver=ssl_open(server_host,server_port)

    			if prx_sslserver
      				#creating ssl io
      				puts("Connection Established for HTTPS")
      				prx_client.write("HTTP/#{http} 200 Connection Established\r\n\r\n")
      				ssl_context=cert_gen(prx_sslserver)
      				prx_sslclient=ssl_io(prx_client,ssl_context)

      				#SSL Content, Response Test Sample
      				#prx_sslclient.puts "HTTP/1.1 200 OK\nContent-Type: text/plain\nContent-Length: 30\n\n<html><body>Test</body></html> "

      				while 
        				begin
          					content = read_http(prx_sslclient)
          					prx_sslserver.write content

          					scontent = read_http(prx_sslserver)
          					prx_sslclient.write scontent
          
        				rescue Exception => sslConnectionException
          					#it's an ssl verification bug, it will be fixed
          					puts "SSL Connection Exception : #{sslConnectionException}"
        				ensure 
          					ssl_close(prx_tcpserver,prx_sslserver)
          					prx_sslclient.close
          					prx_client.close
        				end

     	 			end
    			else
      				prx_client.puts("Remote Server is unavailable")                          
    			end          
  		else
    			#reading data from connected client
    			uri = URI::parse(url)
    			prx_server = TCPSocket.new(uri.host, uri.port)
    			if uri.query.nil?
      				nhead="#{type} #{uri.path} HTTP/#{http}"
    			else
      				nhead="#{type} #{uri.path}?#{uri.query} HTTP/#{http}"
    			end
    			content.gsub!(head,nhead)

    			#keep-alive not supported yet
    			content.gsub!("Connection: keep-alive","Connection: close")

    			#writing request to server and redirecting response to client
    			prx_server.write content
    			recv_send_4_server(prx_server,prx_client)
  		end
	end
end
