require './lib/xmlparser.rb'

class MBContent

	def initialize()
		@head = ""
		@head_content = []
		@body_content = []
		@xml_parser = XMLParser.new()
	end
  
        #gets content and decide which type of content
        def analyse_content(content)
		
		#puts "Incoming content : "
		#puts content

		if content =~ /Content-Type: text\/xml/
			puts "XML content"
			extract_head_content(content)
			
			# get xml body from content 
			x_content = content.split("\n\n")[1]
			@body_content = @xml_parser.parse(x_content)
		
		elsif content =~ /Content-Type: application\/json/
			#json parsing part will be added
			#puts "JSON Content"
			#extract_head_content(content)
			return content
		else
			return content
		end

		#content is in an array
		puts @head
		puts @head_content
		puts @body_content

		return create_new_content()
	end

		
	def extract_head_content(content)
		#getting head of content
		@head = content.split("\n")[0]

		content.each_line do |content_line|
			#puts content_line              
			if content_line =~ /:/
				key = content_line.split(":")[0]
				value = content_line.split(":")[1].split("\r\n")[0]
				@head_content << { key => value}
			end
		end
	end


	# generate request/response content
	def create_new_content()
		#gets only xml for now
		gen_xml = @xml_parser.convert_from_hash(@body_content)

		gen_cont = @head
		
		@head_content.each() do |cont|
			cont.each do |key,value|
				if key == "Content-Length"
                			value = gen_xml.size	#calculate new content length
                		end
				gen_cont = "#{gen_cont}#{key}:#{value}\r\n"
			end
		end

		gen_cont = "#{gen_cont}\n\n#{gen_xml}"		
		#puts gen_cont

		return gen_cont
        end
end

