require './lib/xmlparser.rb'

class MBContent

	def initialize()
		@head = ""
		@content = []
		@xml_content = []
	end
  
        #gets content and decide which type of content
        def analyse_content(content)
		#getting head of content
		@head = content.split("\n")[0]

		content.each_line do |content_line|
			#puts content_line              
			if content_line =~ /:/
				key = content_line.split(":")[0]
				value = content_line.split(":")[1].split("\r\n")[0]
				@content << { key => value}
			end
		end

		# content is in an array
		#puts @content
		
		# get xml part from http response 
		x_content = content.split("\n\n")[1]
		@xml_content = XMLParser.new.parse(x_content)
		
		#puts @xml_content
		#puts create_new_content()

		return create_new_content()
	end

	# generate request/response content
	def create_new_content()
		#gets xml
		gen_xml = XMLParser.new().convert_from_hash(@xml_content)

		gen_cont = @head
		
		@content.each() do |cont|
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

