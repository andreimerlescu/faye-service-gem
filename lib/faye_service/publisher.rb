module FayeService
	module Publisher
		class << self
			# Creates a new HTTP Request with the channel and message to broadcast to any potential channel subscribers
			#
			# channel => String
			# => Channel must be structured like: 
			#    /channel/name
			#    /parent/child
			#    /parent/child1/child2
			#    /parent/child1/child2/child3
			#    /parent/child1/child2/child3/child4
			#    /parent/child1/child2/child3/child4/child5
			#    /parent/child1/child2/child3/child4/child5/child6
			# => Channels can only go 6 children deep
			# => Channels must be between 3 and 32 characters in length
			# => Channels can only contain abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUBWXYV0123456789-
			#
			# message => String, Array, or Hash
			# => Will be parsed into JSON
			# => Should be less than 10KB in size (no programmed limit)
			def publish(channel,message)
				if channel =~ %r{^(/[\w-]{3,32}\/[\w-]{3,32}?(\/[\w-]{3,32})?(\/[\w-]{3,32})?(\/[\w-]{3,32})?(\/[\w-]{3,32})?(\/[\w-]{3,32})?)$}
					message = {
						:channel => channel,
						:data => message,
						:ext => {
							:auth_token => FayeService::auth_token,
							:auth_service => FayeService::auth_service
						}
					}
					uri = URI.parse(FayeService::url)
					FayeService::logger.debug "Sending #{message.length} bytes to #{channel} via #{uri}."
					http_result = Net::HTTP.post_form(uri, :message => message.to_json)
					FayeService::logger.debug http_result.to_json
					return http_result.body
				else
					FayeService::logger.warn "Invalid channel name provided: #{channel}"
				end #/if
			end #/def
		end #/class
	end #/module
end #/module

