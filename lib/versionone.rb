require 'ntlm'
require 'net/http'

module Versionone
	def v1_query(query, host='versionone.successfactors.com', user='ewang', domain='ah_nt_domain', password='Welcomeew^')
		xmlfile = nil
		Net::HTTP.start('versionone.successfactors.com') do |http|
			request = Net::HTTP::Get.new(query)
			request['authorization'] = 'NTLM ' + NTLM.negotiate.to_base64
			response = http.request(request)
			# The connection must be keep-alive!
			challenge = response['www-authenticate'][/NTLM (.*)/, 1].unpack('m').first
			request['authorization'] = 'NTLM ' + NTLM.authenticate(challenge, user, domain, password).to_base64
			response = http.request(request)
			xmlfile = response.body
		end
		xmlfile
	end

    class BacklogEntity
		def initialize(isClosed="", timebox="", status="", scopeName="", scopeId="")
			@isClosed = isClosed
			@timebox = timebox
			@status = status
			@scopeName = scopeName
			@scopeId = scopeId
		end

		# Getter
		def isClosed
		  @isClosed
		end
		def timebox
		  @timebox
		end
		def status
		  @status
		end
		def scopeName
		  @scopeName
		end
		def scopeId
		  @scopeId
		end

		# Setter
		def isClosed=(value)
		  @isClosed = value
		end
		def timebox=(value)
		  @timebox = value
		end
		def status=(value)
		  @status = value
		end
		def scopeName=(value)
		  @scopeName = value
		end
		def scopeId=(value)
		  @scopeId = value
		end
	end

	class DefectEntity
		def initialize(configurationType="", scopeName="", type="", scopeId="", sla="", status="", isClosed="")
			@configurationType = configurationType
			@scopeName = scopeName
			@type = type
			@scopeId = scopeId
			@sla = sla
			@status = status
			@isClosed = isClosed
		end

		# Getter
		def configurationType
		  @configurationType
		end
		def scopeName
		  @scopeName
		end
		def type
		  @type
		end
		def scopeId
		  @scopeId
		end
		def sla
		  @sla
		end
		def status
		  @status
		end
		def isClosed
		  @isClosed
		end	

		# Setter
		def configurationType=(value)
		  @configurationType = value
		end
		def scopeName=(value)
		  @scopeName = value
		end
		def type=(value)
		  @type = value
		end
		def scopeId=(value)
		  @scopeId = value
		end
		def sla=(value)
		  @sla = value
		end
		def status=(value)
		  @status = value
		end
		def isClosed=(value)
		  @isClosed = value
		end			
	end
end