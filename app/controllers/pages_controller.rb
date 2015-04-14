require 'ntlm'
require 'net/http'
require 'rexml/document'
include REXML
require 'versionone'

class PagesController < ApplicationController
  def home
  	redirect_to action: :backlog
  end

  def backlog
  	Net::HTTP.start('versionone.successfactors.com') do |http|
		request = Net::HTTP::Get.new('/vone/rest-1.v1/Data/Story?Sel=SecurityScope.Name,SecurityScope,IsClosed,Status.Name,Timebox.Name&Where=SecurityScope="Scope:1421910"|SecurityScope="Scope:1744828"|SecurityScope="Scope:1664929"|SecurityScope="Scope:1289440"|SecurityScope="Scope:1735471"|SecurityScope="Scope:1165147"|SecurityScope="Scope:1618137"|SecurityScope="Scope:1289443"|SecurityScope="Scope:1686777"|SecurityScope="Scope:1609272"|SecurityScope="Scope:1661626"')
		request['authorization'] = 'NTLM ' + NTLM.negotiate.to_base64

		response = http.request(request)
		# The connection must be keep-alive!

		challenge = response['www-authenticate'][/NTLM (.*)/, 1].unpack('m').first
		request['authorization'] = 'NTLM ' + NTLM.authenticate(challenge, 'ewang', 'ah_nt_domain', 'Welcomeew^').to_base64


		response = http.request(request)
		
		xmlfile = response.body
		xmldoc = Document.new(xmlfile)
		root = xmldoc.root
		modules = ['1289443','1421910','1289440','1686777','1165147','1664929','1744828','1661626','1609272','1735471','1618137']
		pillar_backlogs = [[],[],[],[],[],[],[],[],[],[],[]]
		
		@total_count_not_start = []
		@total_count_dev_in_progress = []
		@total_count_qa_in_progress = []
		@total_count_complete = []

		bi_status_not_started = ['None', 'No Requirements', 'Requirements Done', 'Planned']
	    bi_status_in_progress = ['In Progress', 'Awaiting Clarification', 'Awaiting Code Fix', 'Blocked', 'Reopened']
	    bi_status_in_testing = ['In Testing', 'Dev Complete']
	    bi_status_done = ['Done']

		root.elements.each("Asset") do |asset|
			tmp = []
			asset.elements.each("Attribute") do |attr|
		  		attr_name, attr_text = attr.attributes['name'], attr.text
		  		print attr_name, ": " , attr_text, "\n"
		  		if attr_name == 'IsClosed'
		  			tmp[0] = attr_text
		  		elsif attr_name == 'Timebox.Name'
		  			tmp[1] = attr_text
		  		elsif attr_name == 'Status.Name'
		  			tmp[2] = attr_text
		  		elsif attr_name == 'SecurityScope.Name'
		  			tmp[3] = attr_text
		  		end
		  	end
			if asset.get_elements("Relation").length == 1
				asset.elements.each("Relation") do |relation|
					relation_name = relation.attributes['name']
					relation.elements.each("Asset") do |relation_asset|
						relation_text = relation_asset.attributes['idref']
						if relation_name == 'SecurityScope'
							tmp[4] = relation_text
						end
					end
				end
			end
			if tmp[4] == 'Scope:'+ modules[0]
				pillar_backlogs[0] << tmp
			elsif tmp[4] == 'Scope:'+ modules[1]
				pillar_backlogs[1] << tmp
			elsif tmp[4] == 'Scope:'+ modules[2]
				pillar_backlogs[2] << tmp
			elsif tmp[4] == 'Scope:'+ modules[3]
				pillar_backlogs[3] << tmp
			elsif tmp[4] == 'Scope:'+ modules[4]
				pillar_backlogs[4] << tmp
			elsif tmp[4] == 'Scope:'+ modules[5]
				pillar_backlogs[5] << tmp
			elsif tmp[4] == 'Scope:'+ modules[6]
				pillar_backlogs[6] << tmp
			elsif tmp[4] == 'Scope:'+ modules[7]
				pillar_backlogs[7] << tmp
			elsif tmp[4] == 'Scope:'+ modules[8]
				pillar_backlogs[8] << tmp
			elsif tmp[4] == 'Scope:'+ modules[9]
				pillar_backlogs[9] << tmp
			elsif tmp[4] == 'Scope:'+ modules[10]
				pillar_backlogs[10] << tmp
			end
		end
		print pillar_backlogs
		pillar_backlogs.each do |backlogs|
			tmp_count_notStarted, tmp_count_devInProgress, tmp_count_qaInProgress, tmp_count_completed = 0, 0, 0, 0
			if backlogs.length != 0
				backlogs.each do |backlog|
					if backlog[1] == "Sprint 1"
						if backlog[2] != nil
							if bi_status_not_started.include?(backlog[2])
								tmp_count_notStarted += 1
							elsif bi_status_in_progress.include?(backlog[2])
								tmp_count_devInProgress += 1
							elsif bi_status_in_testing.include?(backlog[2])
								tmp_count_qaInProgress += 1
							elsif bi_status_done.include?(backlog[2])
								tmp_count_completed += 1
							end
						else
							tmp_count_notStarted += 1
							print backlog[2], " tmp_count_notStarted +1 \n"
						end
					end
				end
			end
			@total_count_not_start << tmp_count_notStarted
			@total_count_dev_in_progress << tmp_count_devInProgress
			@total_count_qa_in_progress << tmp_count_qaInProgress
			@total_count_complete << tmp_count_completed
		end
  	end
  end

  def defect
  	Net::HTTP.start('versionone.successfactors.com') do |http|
		request = Net::HTTP::Get.new('/vone/rest-1.v1/Data/Defect?Sel=SecurityScope,Custom_SLA2.Name,Type.Name,IsClosed,Custom_ConfigurationType.Name,Status.Name&Where=SecurityScope="Scope:1421910"|SecurityScope="Scope:1744828"|SecurityScope="Scope:1664929"|SecurityScope="Scope:1289440"|SecurityScope="Scope:1735471"|SecurityScope="Scope:1165147"|SecurityScope="Scope:1618137"|SecurityScope="Scope:1289443"|SecurityScope="Scope:1686777"|SecurityScope="Scope:1609272"|SecurityScope="Scope:1661626"')
		request['authorization'] = 'NTLM ' + NTLM.negotiate.to_base64

		response = http.request(request)
		# The connection must be keep-alive!

		challenge = response['www-authenticate'][/NTLM (.*)/, 1].unpack('m').first
		request['authorization'] = 'NTLM ' + NTLM.authenticate(challenge, 'ewang', 'ah_nt_domain', 'Welcomeew^').to_base64


		response = http.request(request)
		
		xmlfile = response.body
		xmldoc = Document.new(xmlfile)
		root = xmldoc.root
		modules = ['1289443','1421910','1289440','1686777','1165147','1664929','1744828','1661626','1609272','1735471','1618137']
		pillar_defects = [[],[],[],[],[],[],[],[],[],[],[]]
		
		@defect_count_unresolved = []
		@defect_count_in_testing = []
		@defect_count_closed = []

		d_status_unresolved = ['None', 'No Requirements', 'Requirements Done', 'Planned', 'In Progress', 'Awaiting Clarification', 'Awaiting Code Fix', 'Blocked', 'Reopened']
	    d_status_in_testing = ['Dev Complete', 'In Testing']
	    d_status_closed = ['Done']

		root.elements.each("Asset") do |asset|
			tmp = []
			asset.elements.each("Attribute") do |attr|
		  		attr_name, attr_text = attr.attributes['name'], attr.text
		  		print attr_name, ": " , attr_text, "\n"
		  		if attr_name == 'Custom_ConfigurationType.Name'
		  			tmp[0] = attr_text
		  		elsif attr_name == 'SecurityScope.Name'
		  			tmp[1] = attr_text
		  		elsif attr_name == 'Type.Name'
		  			tmp[2] = attr_text
		  		elsif attr_name == 'Custom_SLA2.Name'
		  			tmp[4] = attr_text
		  		elsif attr_name == 'Status.Name'
		  			tmp[5] = attr_text
		  		elsif attr_name == 'IsClosed'
		  			tmp[6] = attr_text
		  		end
		  	end
			if asset.get_elements("Relation").length == 1
				asset.elements.each("Relation") do |relation|
					relation_name = relation.attributes['name']
					relation.elements.each("Asset") do |relation_asset|
						relation_text = relation_asset.attributes['idref']
						if relation_name == 'SecurityScope'
							tmp[3] = relation_text
						end
					end
				end
			end
			if tmp[3] == 'Scope:'+ modules[0]
				pillar_defects[0] << tmp
			elsif tmp[3] == 'Scope:'+ modules[1]
				pillar_defects[1] << tmp
			elsif tmp[3] == 'Scope:'+ modules[2]
				pillar_defects[2] << tmp
			elsif tmp[3] == 'Scope:'+ modules[3]
				pillar_defects[3] << tmp
			elsif tmp[3] == 'Scope:'+ modules[4]
				pillar_defects[4] << tmp
			elsif tmp[3] == 'Scope:'+ modules[5]
				pillar_defects[5] << tmp
			elsif tmp[3] == 'Scope:'+ modules[6]
				pillar_defects[6] << tmp
			elsif tmp[3] == 'Scope:'+ modules[7]
				pillar_defects[7] << tmp
			elsif tmp[3] == 'Scope:'+ modules[8]
				pillar_defects[8] << tmp
			elsif tmp[3] == 'Scope:'+ modules[9]
				pillar_defects[9] << tmp
			elsif tmp[3] == 'Scope:'+ modules[10]
				pillar_defects[10] << tmp
			end
		end
		print pillar_defects
		pillar_defects.each do |defects|
			tmp_d_count_unresolved, tmp_d_count_in_trogress, tmp_d_count_closed = 0, 0, 0
			if defects.length != 0
				defects.each do |defect|
					if defect[5] != nil
						if d_status_unresolved.include?(defect[5])
							tmp_d_count_unresolved += 1
						elsif d_status_in_testing.include?(defect[5])
							tmp_d_count_in_trogress += 1
						elsif d_status_closed.include?(defect[5])
							tmp_d_count_closed += 1
						end
					else
						tmp_d_count_unresolved += 1
						print defect[5], " tmp_d_count_unresolved +1 \n"
					end
				end
			end
			@defect_count_unresolved << tmp_d_count_unresolved
			@defect_count_in_testing << tmp_d_count_in_trogress
			@defect_count_closed << tmp_d_count_closed
		end
  	end
  end

  def support
  end
end
