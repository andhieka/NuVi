require 'net/http'
require 'uri'
require 'json'
require 'logger'

require_relative 'Module'

class ModuleUtility

	def initialize() 
		@academic_year = "2013-2014"
		@academic_semester = "2"
		@nusmods_url = "http://api.nusmods.com/#{@academic_year}/#{@academic_semester}/"
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::DEBUG
	end

	
	def get_module_list()
		uri = URI.parse(@nusmods_url + "moduleList.json")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)

		if response.code == "200"
			module_list = {}
			result = JSON.parse(response.body)
			result.each do |code, name|
				module_list[code] = name
			end
			return module_list
		else
			error_message = "ModuleUtility::get_module_list -- Failed to retrieve module list."
			@logger.error(error_message)
			raise RuntimeError, error_message
		end
	end

	def get_module_info(module_code)
		module_code.upcase! # all module code use capital letters
		uri = URI.parse(@nusmods_url + "modules/#{module_code}.json")
		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri.request_uri)
		response = http.request(request)

		if response.code == "200"
			module_info = JSON.parse(response.body)
			return module_info
		else
			error_message = "ModuleUtility::get_module_list -- Failed to retrieve module list."
			@logger.error(error_message)
			raise RuntimeError, error_message
		end
	end

	def get_module(module_code)
		info = get_module_info(module_code)
		mod = Module.new(info['ModuleCode'],
			info["ModuleCredit"],
			info["Prerequisite"],
			info["Corequisite"],
			info["Preclusion"],
			info["CrossModule"] )
		return mod
	end

end

