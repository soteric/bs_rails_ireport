require 'ntlm'
require 'net/http'
require 'rexml/document'
include REXML

class PagesController < ApplicationController
  include Versionone
  
  def home
  	redirect_to action: :backlog
  end

  def backlog
	modules = {'tgm'=> '1289443', 'pmt'=> '1421910', 'pmr'=> '1289440', 'mtr'=> '1686777', 'cal'=> '1165147', 'vrp'=> '1664929', 'scm'=> '1744828', 'cmp'=> '1661626', 'pe'=> '1609272', 'trvw'=> '1735471', 'cdp'=> '1618137'}
	fields = ['SecurityScope.Name', 'SecurityScope', 'IsClosed', 'Status.Name', 'Timebox.Name']
	pillar_backlogs = [[],[],[],[],[],[],[],[],[],[],[]] # All backlog items container

	# Backlog item status category
	bi_status_not_started = ['None', 'No Requirements', 'Requirements Done', 'Planned']
    bi_status_in_progress = ['In Progress', 'Awaiting Clarification', 'Awaiting Code Fix', 'Blocked', 'Reopened']
    bi_status_in_testing = ['In Testing', 'Dev Complete']
    bi_status_done = ['Done']

	# Backlog item number list in category
	@total_list_not_start = []
	@total_list_dev_in_progress = []
	@total_list_qa_in_progress = []
	@total_list_complete = []
	
	# Prepare api query
	base_url = '/vone/rest-1.v1/Data/Story?'
	select_url = 'Sel=SecurityScope.Name,SecurityScope,IsClosed,Status.Name,Timebox.Name&'
	where_url = 'Where=SecurityScope="Scope:1421910"|SecurityScope="Scope:1744828"|SecurityScope="Scope:1664929"|SecurityScope="Scope:1289440"|SecurityScope="Scope:1735471"|SecurityScope="Scope:1165147"|SecurityScope="Scope:1618137"|SecurityScope="Scope:1289443"|SecurityScope="Scope:1686777"|SecurityScope="Scope:1609272"|SecurityScope="Scope:1661626"'
	api_query = base_url + select_url + where_url

	# Query and extract xml result
	xmlfile = v1_query(query=api_query)
	xmldoc = Document.new(xmlfile)
	root = xmldoc.root
	
	# Extract elements tree 
	# Asset ->
	#         Attribute ->
	#         Relation  ->
	#	                  Asset
	root.elements.each("Asset") do |asset|
		tmp = BacklogEntity.new
		
		# extract 1st level asset
		asset.elements.each("Attribute") do |attr|
	  		attr_name, attr_text = attr.attributes['name'], attr.text
	  		if attr_name == 'IsClosed'
	  			tmp.isClosed = attr_text
	  		elsif attr_name == 'Timebox.Name'
	  			tmp.timebox = attr_text
	  		elsif attr_name == 'Status.Name'
	  			tmp.status = attr_text
	  		elsif attr_name == 'SecurityScope.Name'
	  			tmp.scopeName = attr_text
	  		end
	  	end
		
		# extract 2nd level asset under Relation
		if asset.get_elements("Relation").length == 1
			asset.elements.each("Relation") do |relation|
				relation_name = relation.attributes['name']
				relation.elements.each("Asset") do |relation_asset|
					relation_text = relation_asset.attributes['idref']
					if relation_name == 'SecurityScope'
						tmp.scopeId = relation_text
					end
				end
			end
		end

		# attached to pillar_backlogs container
		if tmp.scopeId == 'Scope:'+ modules['tgm']
			pillar_backlogs[0] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pmt']
			pillar_backlogs[1] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pmr']
			pillar_backlogs[2] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['mtr']
			pillar_backlogs[3] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cal']
			pillar_backlogs[4] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['vrp']
			pillar_backlogs[5] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['scm']
			pillar_backlogs[6] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cmp']
			pillar_backlogs[7] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pe']
			pillar_backlogs[8] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['trvw']
			pillar_backlogs[9] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cdp']
			pillar_backlogs[10] << tmp
		end
	end

	# Calculate and populate report data into list 
	pillar_backlogs.each do |module_backlogs|
		count_notStarted, count_devInProgress, count_qaInProgress, count_completed = 0, 0, 0, 0

		if module_backlogs.length != 0
			module_backlogs.each do |backlog|
				if backlog.timebox == "Sprint 1"
					if backlog.status != nil
						if bi_status_not_started.include?(backlog.status)
							count_notStarted += 1
						elsif bi_status_in_progress.include?(backlog.status)
							count_devInProgress += 1
						elsif bi_status_in_testing.include?(backlog.status)
							count_qaInProgress += 1
						elsif bi_status_done.include?(backlog.status)
							count_completed += 1
						end
					else 
						# if status value is empty, count it into notStarted status
						count_notStarted += 1
					end
				end
			end
		end

		# report data for view to use
		@total_list_not_start << count_notStarted
		@total_list_dev_in_progress << count_devInProgress
		@total_list_qa_in_progress << count_qaInProgress
		@total_list_complete << count_completed

	end
  end

  def defect
  	modules = {'tgm'=> '1289443', 'pmt'=> '1421910', 'pmr'=> '1289440', 'mtr'=> '1686777', 'cal'=> '1165147', 'vrp'=> '1664929', 'scm'=> '1744828', 'cmp'=> '1661626', 'pe'=> '1609272', 'trvw'=> '1735471', 'cdp'=> '1618137'}
  	fields = ['Custom_ConfigurationType.Name', 'SecurityScope.Name', 'Type.Name', 'SecurityScope', 'Custom_SLA2.Name', 'Status.Name', 'IsClosed']
	pillar_defects = [[],[],[],[],[],[],[],[],[],[],[]]

	# Defect status category
	d_status_unresolved = ['None', 'No Requirements', 'Requirements Done', 'Planned', 'In Progress', 'Awaiting Clarification', 'Awaiting Code Fix', 'Blocked', 'Reopened']
    d_status_in_testing = ['Dev Complete', 'In Testing']
    d_status_closed = ['Done']

	# Defect number list in category
	@total_list_unresolved = []
	@total_list_in_testing = []
	@total_list_closed = []
	
	# Prepare api query
	base_url = '/vone/rest-1.v1/Data/Defect?'
	select_url = 'Sel=SecurityScope,Custom_SLA2.Name,Type.Name,IsClosed,Custom_ConfigurationType.Name,Status.Name&'
	where_url = 'Where=SecurityScope="Scope:1421910"|SecurityScope="Scope:1744828"|SecurityScope="Scope:1664929"|SecurityScope="Scope:1289440"|SecurityScope="Scope:1735471"|SecurityScope="Scope:1165147"|SecurityScope="Scope:1618137"|SecurityScope="Scope:1289443"|SecurityScope="Scope:1686777"|SecurityScope="Scope:1609272"|SecurityScope="Scope:1661626"'
	api_query = base_url + select_url + where_url

	# Query and extract xml result
	xmlfile = v1_query(query=api_query)
	xmldoc = Document.new(xmlfile)
	root = xmldoc.root

	# Extract elements tree 
	# Asset ->
	#         Attribute ->
	#         Relation  ->
	#	                  Asset
	root.elements.each("Asset") do |asset|
		tmp = DefectEntity.new

		# extract 1st level asset
		asset.elements.each("Attribute") do |attr|
	  		attr_name, attr_text = attr.attributes['name'], attr.text
	  		if attr_name == 'Custom_ConfigurationType.Name'
	  			tmp.configurationType = attr_text
	  		elsif attr_name == 'SecurityScope.Name'
	  			tmp.scopeName = attr_text
	  		elsif attr_name == 'Type.Name'
	  			tmp.type = attr_text
	  		elsif attr_name == 'Custom_SLA2.Name'
	  			tmp.sla = attr_text
	  		elsif attr_name == 'Status.Name'
	  			tmp.status = attr_text
	  		elsif attr_name == 'IsClosed'
	  			tmp.isClosed = attr_text
	  		end
	  	end

	  	# extract 2nd level asset under relation
		if asset.get_elements("Relation").length == 1
			asset.elements.each("Relation") do |relation|
				relation_name = relation.attributes['name']
				relation.elements.each("Asset") do |relation_asset|
					relation_text = relation_asset.attributes['idref']
					if relation_name == 'SecurityScope'
						tmp.scopeId = relation_text
					end
				end
			end
		end

		# attached to pillar_defects container
		if tmp.scopeId == 'Scope:'+ modules['tgm']
			pillar_defects[0] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pmt']
			pillar_defects[1] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pmr']
			pillar_defects[2] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['mtr']
			pillar_defects[3] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cal']
			pillar_defects[4] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['vrp']
			pillar_defects[5] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['scm']
			pillar_defects[6] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cmp']
			pillar_defects[7] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['pe']
			pillar_defects[8] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['trvw']
			pillar_defects[9] << tmp
		elsif tmp.scopeId == 'Scope:'+ modules['cdp']
			pillar_defects[10] << tmp
		end
	end

	pillar_defects.each do |defects|
		count_unresolved, count_in_trogress, count_closed = 0, 0, 0

		if defects.length != 0
			defects.each do |defect|
				if defect.status != nil 
					if d_status_unresolved.include?(defect.status)
						count_unresolved += 1
					elsif d_status_in_testing.include?(defect.status)
						count_in_trogress += 1
					elsif d_status_closed.include?(defect.status)
						count_closed += 1
					end
				else
					# if status value is empty, count it into unresolved status
					count_unresolved += 1
				end
			end
		end
		
		# report data for view to use
		@total_list_unresolved << count_unresolved
		@total_list_in_testing << count_in_trogress
		@total_list_closed << count_closed
	end
  end

  def support
  end
end
