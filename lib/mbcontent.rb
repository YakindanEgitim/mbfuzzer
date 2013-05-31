require './lib/xmlparser.rb'
require './lib/jsonparser.rb'
require 'xmlsimple'


class MBContent

	def initialize(config_file)
		@head = ""
		@type = ""
		@head_content = []
		@body_content = []
		@xml_parser = XMLParser.new()
		@json_parser = JSONParser.new()
		@raw = ""
		@actions = Hash.new()
		self.load_actions(config_file)
	end

	#gets content and decide which type of content
	def analyse_content(content)
		#puts "Incoming content : "
		#puts content

		@head_content.clear()
		@body_content.clear()
		@head.clear()
		@raw.clear()
		@type.clear()

		if content =~ /Content-Type: text\/xml/
			@type = "XML"
			extract_head_content(content)
			
			# get xml body from content
			x_content = extract_body_content(content)
			@body_content = xml_actions( @xml_parser.parse(x_content) )

		elsif content =~ /Content-Type: application\/json/
			@type = "JSON"

			extract_head_content(content)
			@body_content = @json_parser.convert_to_hash( extract_body_content(content) )
			
		else	
			return content if content.empty?
			@type = "RAW"
			extract_head_content(content)
			@raw = extract_body_content(raw_actions(content))
		end

		#content is in an array

		#puts @head
		#puts @head_content
		#puts @body_content
		
		return create_new_content()
	end


	# this method gets prepared action lists from incoming config file
	def load_actions(config_file)
    		#puts "Actions are loaded!!!"
		action = XmlSimple.new.xml_in(config_file, { 'ForceArray' => false })
        
		action.each do |a_name,a_attr|
			case a_name
				when "searchreplace" then @actions['searchreplace'] = a_attr
				when "bigdata" then @actions['bigdata'] = a_attr
			end
		end
	end

	# raw_actions method looks the search and replace actions and 
	# make necessary changes according to the actions.
	def raw_actions(content)
		return content if @actions['searchreplace'] == nil
		
		@actions['searchreplace'].each do |entry|
			target = entry["target"]
			newdata = entry["newdata"]

			content.gsub!(target,newdata)
		end
	    
	    return content
	end

	# xml_actions gets bigdata config parameters and applies to 
  	# incoming xml content if xml element name exist in the content 
  	def xml_actions(content)
    		# TODO recursive search implementation in order to look 
    		# merge operation inside nested hashes
    		return content if @actions['bigdata'] == nil
          
    		@actions['bigdata'].each do |entry|
          		name = entry["name"]
			data = entry["data"]
			count = entry["count"]
          
			new = {name => [data*count.to_i]}
          		
			content = content.merge(new) if content.has_key?(name)
		end
    
		return content
	end
	
	#
	def json_actions(content)
		# TODO apply json content actions 
		# after preparing config file
		return content
	end


	def extract_head_content(content)
		#getting head of content
		@head = content.split("\r\n")[0]
		
		content.each_line do |content_line|
			#puts content_line
			if content_line =~ /:\ /
				key = content_line.split(":")[0]
				value = content_line.split(": ")[1].split("\r\n")[0]
				@head_content << { key => value}
			end
		end
	end


	def extract_body_content(content)
		#getting body of content
		control = false
		body = ""

		
		content.each_line do |content_line|
			control = true if content_line == "\r\n"
			body = "#{body}#{content_line}" if control == true
		end

		return body
	end


	# generate request/response content
	def create_new_content()
		#gets only xml for now
		old_length = ""
		new_length = ""
		gen_body = ""
		gen_cont = ""
        
		case @type
			when "XML" then gen_body = @xml_parser.convert_from_hash(@body_content)
			when "JSON" then gen_body = @json_parser.convert_to_json(@body_content)
			when "RAW" then gen_body = @raw
		end

    
		@head_content.each() do |cont|
			cont.each do |key,value|
				if key == "Content-Length"
					old_length = "#{key}: #{value}"  #calculate new content length
				end
				gen_cont = "#{gen_cont}#{key}: #{value}\r\n"
			end
		end
		
		new_length = "Content-Length: #{gen_body.length}"
		#puts "#{old_length} --- #{new_length}"
		gen_cont.gsub!(old_length,new_length)  
    		
		# combine all parts
		gen_cont = "#{@head}\r\n#{gen_cont}\r\n#{gen_body}"    
     		
		# show new content
		#puts gen_cont

		return gen_cont
	end
end
