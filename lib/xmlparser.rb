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
                # incoming xml file convert to document format
                @doc = REXML::Document.new(xml)

                #self.search_replace()
                self.convert_from_xml(@doc.to_s)

                return @xml_content
        end

        # convert to hash array from xml content
        def convert_from_xml(xml)
                @xml_content = @xml_analyser.xml_in(xml, 'KeepRoot'=>false)
        end

        # convert to xml from hash array
        def convert_from_hash(h_xml)
                xml = @xml_analyser.xml_out(h_xml, 'RootName'=>@doc.root().name())

                #arrange xml content for creating appropriate content
                xml.each_line do |xml_line|
                        @xml = "#{@xml}#{xml_line}\r\n"
                end

                return @xml
        end


        # gets content from config file and search inside of the xml in order to replace
        def search_replace()
                config = File.open('./lib/mbconfig.cfg')

                config.each_line do |line|
                        # type checking
                        if line.split("=")[0] == "XML"
                                #extract parameters
                                tag = line.split("=")[1].split(":")[0]
                                new_text = line.split(":")[1]

                                # controls that the xml include element which comes from config file
                                if @doc.elements[tag].has_text? == true
                                        @doc.elements[tag].text = new_text
                                end
                        end

                end
        end

end

