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
		gen_json = JSON.generate(hash_content)
		# slash control and changing if exist any slash
		new_json = gen_json.to_s
		new_json.gsub!('/','\\/')

		new_json = "#{new_json}\r\n"
		return new_json
	end

end
