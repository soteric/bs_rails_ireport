require 'ntlm'
require 'net/http'
require 'rexml/document'
include REXML

class PagesController < ApplicationController
  def home
  	redirect_to action: :backlog
  end

  def backlog
  	Net::HTTP.start('versionone.successfactors.com') do |http|
	  request = Net::HTTP::Get.new('/vone/rest-1.v1/Data/Defect?Sel=SecurityScope,Custom_SLA2.Name,Type.Name,IsClosed,Status.Name,CreateDate&Where=SecurityScope=%27Scope:551647%27')
	  request['authorization'] = 'NTLM ' + NTLM.negotiate.to_base64

	  response = http.request(request)

	  # The connection must be keep-alive!

	  challenge = response['www-authenticate'][/NTLM (.*)/, 1].unpack('m').first
	  request['authorization'] = 'NTLM ' + NTLM.authenticate(challenge, 'ewang', 'ah_nt_domain', 'Welcomeew^').to_base64

	  response = http.request(request)

	  xmlfile = response.body
	  xmldoc = Document.new(xmlfile)
	  root = xmldoc.root
	  root.elements.each("Asset") {
	  	|asset| asset.elements.each("Attribute") {
	  		|attr| attr_name, attr_text = attr.attributes['name'], attr.text
	  		print attr_name, ": ", attr_text, "\n"
	  	}
	  }
	end
  end

  def defect
  	Net::HTTP.start('versionone.successfactors.com') do |http|
	  request = Net::HTTP::Get.new('/vone/rest-1.v1/Data/Defect?Sel=SecurityScope,Custom_SLA2.Name,Type.Name,IsClosed,Status.Name,CreateDate&Where=SecurityScope=%27Scope:551647%27')
	  request['authorization'] = 'NTLM ' + NTLM.negotiate.to_base64

	  response = http.request(request)

	  # The connection must be keep-alive!

	  challenge = response['www-authenticate'][/NTLM (.*)/, 1].unpack('m').first
	  request['authorization'] = 'NTLM ' + NTLM.authenticate(challenge, 'ewang', 'ah_nt_domain', 'Welcomeew^').to_base64

	  response = http.request(request)

	  xmlfile = response.body
	  xmldoc = Document.new(xmlfile)
	  root = xmldoc.root
	  root.elements.each("Asset") {
	  	|asset| asset.elements.each("Attribute") {
	  		|attr| attr_name, attr_text = attr.attributes['name'], attr.text
	  		print attr_name, ": ", attr_text, "\n"
	  	}
	  }
	end
  end

  def support
  end
end
