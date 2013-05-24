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

end

