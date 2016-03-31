require 'rubygems'
require 'xcodeproj'



module Xcodeproj
	class Project
		def self.create_project(path)
			project = Xcodeproj::Project.new(path)
			applicationTarget = project.new_target(:application, 'testApplication', :ios, '9.2', nil, :swift)

			applicationTarget.add_system_framework('Foundation')
			
			#
			# file_references = project.new_file("./src/")

			sourceGroup = project.new_group('src')

			Dir.glob('./src/*') do |file|
				ref = sourceGroup.new_reference(file)
			end

			buildSettingsConfig = {
				'ALWAYS_SEARCH_USER_PATHS' => 'YES',
				'GCC_C_LANGUAGE_STANDARD' => 'gnu99',
				'INSTALL_PATH' => "$(BUILT_PRODUCTS_DIR)",
				'GCC_WARN_ABOUT_MISSING_PROTOTYPES' => 'YES',
				'GCC_WARN_ABOUT_RETURN_TYPE' => 'YES',
				'GCC_WARN_UNUSED_VARIABLE' => 'YES',
				'OTHER_LDFLAGS' => '',
				'ARCHS' => "$(ARCHS_STANDARD_32_BIT)",
				'IPHONEOS_DEPLOYMENT_TARGET' => '9.2',
				'PUBLIC_HEADERS_FOLDER_PATH' => "$(TARGET_NAME)",
				'SDKROOT' => 'iphoneos',
				'GCC_DYNAMIC_NO_PIC' => 'NO',
				'GCC_PREPROCESSOR_DEFINITIONS' => ["DEBUG=1", "$(inherited)"],
				'GCC_SYMBOLS_PRIVATE_EXTERN' => 'NO',
				'GCC_OPTIMIZATION_LEVEL' => '0',
			    'INFOPLIST_FILE' => 'src/Info.plist'
			}
			
			buildSettingsConfig.each do |key, array|
				# print "#{key}=>"
				# puts array
				project.objects[3].set_setting(key,array)
			end

			# puts project.build_settings("Release")
			# project.objects.each { |value | puts value }

			# buildSettingsConfig.each do |key, value| {
			# 	project.objects[3].set_setting(key,value)
			# }

      		project.save(path + "/test.xcodeproj")      
			project
		end
	end
end

Xcodeproj::Project.create_project('.')