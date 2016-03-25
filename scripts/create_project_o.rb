# -*- coding: utf-8 -*-
#
require 'rubygems'
require 'xcodeproj'

FRAMEWORKS = %w{
    AudioToolbox
    CFNetwork
    CoreGraphics
    CoreLocation
    Foundation
    MediaPlayer
    OpenAL
    OpenGLES
    QuartzCore
    UIKit
    libiconv.2.dylib
}

module Xcodeproj
  class Project
    def get_group(name) 
      self.groups.find { |g| g.name == name } || self.groups.map({ 'name' => name })
    end

    def add_system_framework(fname)
      name, path = nil, nil;
      if (fname =~ /^lib/)
        name, path = fname, "usr/lib/#{fname}"
      else
        name, path = "#{fname}.framework", "System/Library/Frameworks/#{fname}.framework"
      end
      self.files.new({ 
                       'name' => name,
                       'path' => path,
                       'sourceTree' => 'SDKROOT'
                     })
    end
    
    def add_frameworks
      group = get_group('Frameworks')
      FRAMEWORKS.each do |fname|
        framework = add_system_framework(fname)  
        framework.group = group
      end
      self.main_group << group
    end

    def self.create_project(path)
      project = Xcodeproj::Project.new(path)
      project.main_group << project.get_group('Classes')
      # project.add_frameworks()

      products = project.get_group('Products')
      project.main_group << products
      project.root_object.products = products
 
      project.root_object.attributes['buildConfigurationList'] = 
        project.objects.add(Xcodeproj::Project::XCConfigurationList, {
                           'defaultConfigurationIsVisible' => '0',
                           'defaultConfigurationName' => 'Release',
                           'buildConfigurations' => 
                           [
                            project.objects.add(Xcodeproj::Project::XCBuildConfiguration, {
                                               'name' => 'Debug',
                                               'buildSettings' => build_settings(:ios, :debug)
                                             }),
                            project.objects.add(Xcodeproj::Project::XCBuildConfiguration, {
                                               'name' => 'Release',
                                               'buildSettings' => build_settings(:ios, :release)
                                             })
                           ].map(&:uuid)
                         }).uuid
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



Xcodeproj::Project.create_project("/tmp/Test")
