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
}
# libiconv.2.dylib
 
module Xcodeproj
  class Project
    def self.create_project(name)
      project = Xcodeproj::Project.new(name)
      target = project.new_app_target(:application, name, :ios)
      
      target.build_configurations.each do |conf|
        conf.build_settings['INFOPLIST_FILE'] = 'info.plist'
      end

      group = project.new_group('Classes')
      file_ref = group.new_file('main.m')
      # file_ref.path = 'main.m'
      target.source_build_phase.add_file_reference file_ref

      FRAMEWORKS.each do |fname|
        framework_ref = project.add_system_framework(fname, target)
        target.frameworks_build_phase.add_file_reference(framework_ref)
      end

      project
    end

    def new_app_target(type, name, platform, deployment_target = nil)
      target = new(PBXNativeTarget)
      targets << target
      target.name = name
      target.product_name = name
      target.product_type = Constants::PRODUCT_TYPE_UTI[type]
      # target.build_configuration_list = Xcodeproj::Project::ProjectHelper.configuration_list(platform, deployment_target)

      # Product
      product = products_group.new_file("#{name}.app")
      product.include_in_index = '0'
      product.source_tree = 'BUILT_PRODUCTS_DIR'
      product.explicit_file_type = product.last_known_file_type
      product.last_known_file_type = nil
      target.product_reference = product

      # Build phases
      target.build_phases << new(PBXSourcesBuildPhase)
      target.build_phases << new(PBXFrameworksBuildPhase)

      target
    end

    
  end
end
 
project = Xcodeproj::Project.create_project("tmp")
project.save("test.xcodeproj") 