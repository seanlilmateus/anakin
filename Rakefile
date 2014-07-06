# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Luke'
  app.info_plist['LSUIElement'] = true
  app.frameworks << 'QuartzCore'
  
  # URL schemes to handle http and https
  app.info_plist['CFBundleURLTypes'] = [
      { 
        'CFBundleURLName'    => 'http URL',
        'CFBundleURLSchemes' => ['http'] 
      },
      { 
        'CFBundleURLName'    => 'Secure http URL',
        'CFBundleURLSchemes' => ['https'] 
      },
  ]
  
end
