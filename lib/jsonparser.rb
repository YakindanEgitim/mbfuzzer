require 'json'

class JSONParser

	def initialize
		@json_content = []
	end

	#incoming json is converted to hash
	def convert_to_hash(json_content)
		@json_content = JSON.parse(json_content)
		
		return @json_content
	end

	# json content which is in a hash is converted to json
	def convert_to_json(hash_content)
		
		return JSON.generate(hash_content)
	end

end
