# -*- coding: utf-8 -*-
#
require 'rubygems'
require 'xcodeproj'

ADD_FRAMEWORKS = %w{
AddressBook
AVFoundation
GameKit
libicucore.A.dylib
libsqlite3.dylib
libxml2.dylib
libz.1.2.5.dylib
MessageUI
MobileCoreServices
Security
StoreKit
CoreTelephony
}

module Xcodeproj
  class Project
    def get_group(name) 
      self.groups.find { |g| g.name == name } || self.groups.new({ 'name' => name })
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
                       'sourceTree' => 'SDKROOT',
                     })
    end

    def arrange_frameworks
      group = get_group('Frameworks')
      frameworks_build_phases_list = [] 
      self.targets.each do |target|
        target.frameworks_build_phases.each do |phase|
          frameworks_build_phases_list.push(phase)
        end
      end

      self.files.sort{|a,b| a.name <=> b.name }.each do |file|
        path = file.path
        if (path =~ /^System\/Library\/Frameworks/ or path =~ /^usr\/lib/)
          file.group = group
        end
      end
      ADD_FRAMEWORKS.each do |fname|
        if (group.files.find {|f|
              cname = (f.name =~ /framework$/) ? "#{fname}.framework" :  fname
              f.name == cname
            })
        else
          framework = add_system_framework(fname)
          framework.group = group
          frameworks_build_phases_list.each do |buildPhase|
            buildPhase.files << framework.buildFiles.new
          end
        end
      end
    end

    def self.arrange_project(path)

      # xcodeproj_path = nil
      # Dir.glob("#{path}/*.xcodeproj").each do |file|
      #   xcodeproj_path = file
      # end
      # return if !xcodeproj_path
      #       print('save')
      project = Xcodeproj::Project.new("./tmp/xcodeproj_path")
      project.arrange_frameworks()

      project.save(xcodeproj_path)      
      project
    end
    private    
  end
end


if $0 == __FILE__
  Xcodeproj::Project.arrange_project("./tmp/Test")
end