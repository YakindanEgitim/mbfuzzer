require 'rexml/document'
require 'xmlsimple'

class XMLParser
	def initialize
		@doc = ""
		@xml = ""
		@xml_content = []
		@xml_analyser = XmlSimple.new()
	end

	def parse(xml)
		@doc = REXML::Document.new(xml)         
		#root_xml = doc.root
		#@xml_content << {root_xml.name => ""}

		#doc.root.each_element do |value|
		#	if value.has_elements?() != true
		#		@xml_content << { value.name => value.text}
		#	else
		#  		@xml_content << {value.name => "" }
		#       end
		#end
    
		convert_from_xml(xml)
  
		return @xml_content
	end
  
	# convert to hash array from xml content
	def convert_from_xml(xml)
		@xml_content = @xml_analyser.xml_in(xml, 'KeepRoot'=>false)
	end

	# convert to xml from hash array
	def convert_from_hash(h_xml)
		@xml = @xml_analyser.xml_out(h_xml, 'RootName'=>@doc.root.name())
		return @xml
	end

end
