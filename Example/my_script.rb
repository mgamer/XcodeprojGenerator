require 'rubygems'
require 'xcodeproj'



module Xcodeproj
	class Project

		def self.add_new_group(currentGroup, path)
			newGroupName = path.split('/').last
			newGroup = currentGroup.new_group(newGroupName)
			newGroup
		end

		def self.add_files_to_group(currentGroup, path, applicationTarget)
			Dir.glob(path + '/*') do |file|
				if File.directory?(file) 
					newGroup = Xcodeproj::Project.add_new_group(currentGroup, file)
					Xcodeproj::Project.add_files_to_group(newGroup, file, applicationTarget)
				else
					ref = currentGroup.new_reference(file)
					if file.include? ".swift"
						applicationTarget.source_build_phase.add_file_reference(ref)
					end
				end
			end
		end


		def self.create_project(path)
			project = Xcodeproj::Project.new(path)
			applicationTarget = project.new_target(:application, 'TestApp', :ios, '9.2', nil, :swift)

			# applicationTarget.add_system_framework('Foundation')

			sourceGroup = project.new_group('Source')
			Xcodeproj::Project.add_files_to_group(sourceGroup, './src/', applicationTarget)

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
			    'INFOPLIST_FILE' => 'src/Info.plist',
			    'PRODUCT_BUNDLE_IDENTIFIER' => 'pl.bright.inventions.$(PRODUCT_NAME)'
			}

			buildSettingsConfigRelease = {
				'ALWAYS_SEARCH_USER_PATHS' => 'NO',
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
			    'INFOPLIST_FILE' => 'src/Info.plist',
			    'PRODUCT_BUNDLE_IDENTIFIER' => 'pl.bright.inventions.$(PRODUCT_NAME)'
			}


			project.objects.each do |value|
				puts value
			end
			
			buildSettingsConfig.each do |key, array|
				# print "#{key}=>"
				# puts array
				project.objects[3].set_setting(key,array) #fix it 
			end

			# buildSettingsConfigRelease.each do |key, array|
			# 	project.objects[5].set_setting(key,array)
			# end


			# puts project.build_settings("Release")
			# project.objects.each { |value | puts value }

			# buildSettingsConfig.each do |key, value| {
			# 	project.objects[3].set_setting(key,value)
			# }

      		project.save(path + "/TestApp.xcodeproj")      
			project
		end
	end
end

Xcodeproj::Project.create_project('.')