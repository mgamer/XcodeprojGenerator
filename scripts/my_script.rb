require 'rubygems'
require 'xcodeproj'



module Xcodeproj
	class Project
		def self.create_project(path)
			project = Xcodeproj::Project.new(path)
			testApplication = project.new_target(:application, 'testApplication', :ios, '9.2', nil, :swift)

			sourceGroup = project.new_group('src')
			sourceGroup.new_reference('./src/') #read all source directories and files

			#adding frameworks
			group = get_group


      		project.save(path + "/#{File.basename(path)}.xcodeproj")      
			project
		end

    private    
	    COMMON_BUILD_SETTINGS = {
	      :all => {
	        'ALWAYS_SEARCH_USER_PATHS' => 'NO',
	        'GCC_C_LANGUAGE_STANDARD' => 'gnu99',
	        'INSTALL_PATH' => "$(BUILT_PRODUCTS_DIR)",
	        'GCC_WARN_ABOUT_MISSING_PROTOTYPES' => 'YES',
	        'GCC_WARN_ABOUT_RETURN_TYPE' => 'YES',
	        'GCC_WARN_UNUSED_VARIABLE' => 'YES',
	        'OTHER_LDFLAGS' => ''
	      },
	      :debug => {
	        'GCC_DYNAMIC_NO_PIC' => 'NO',
	        'GCC_PREPROCESSOR_DEFINITIONS' => ["DEBUG=1", "$(inherited)"],
	        'GCC_SYMBOLS_PRIVATE_EXTERN' => 'NO',
	        'GCC_OPTIMIZATION_LEVEL' => '0'
	      },
	      :ios => {
	        'ARCHS' => "$(ARCHS_STANDARD_32_BIT)",
	        'GCC_VERSION' => 'com.apple.compilers.llvmgcc42',
	        'IPHONEOS_DEPLOYMENT_TARGET' => '4.3',
	        'PUBLIC_HEADERS_FOLDER_PATH' => "$(TARGET_NAME)",
	        'SDKROOT' => 'iphoneos'
	      },
	    }
	    def self.build_settings(platform, scheme)
	      settings = COMMON_BUILD_SETTINGS[:all].merge(COMMON_BUILD_SETTINGS[platform])
	      settings['COPY_PHASE_STRIP'] = scheme == :debug ? 'NO' : 'YES'
	      if scheme == :debug
	        settings.merge!(COMMON_BUILD_SETTINGS[:debug])
	      else
	        settings['VALIDATE_PRODUCT'] = 'YES' if platform == :ios
	      end
	      settings
	    end   		
	end
end

Xcodeproj::Project.create_project('./test/')

