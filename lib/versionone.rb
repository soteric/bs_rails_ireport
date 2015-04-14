class Defect
	def initialize(isClosed, timebox, status, securityScope, securityScope_full)
		@isClosed = ""
		@timebox = ""
		@status = ""
		@securityScope = ""
		@securityScope_full = ""
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
	def securityScope
	  @securityScope
	end
	def securityScope_full
	  @securityScope_full
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
	def securityScope=(value)
	  @securityScope = value
	end
	def securityScope_full=(value)
	  @securityScope_full = value
	end
end