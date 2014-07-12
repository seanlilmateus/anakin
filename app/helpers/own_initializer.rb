module Anakin
  APP_NAME = NSBundle.mainBundle.objectForInfoDictionaryKey('CFBundleDisplayName')
  module OwnInitializer
    def self.new(*args, &block)
      instance = alloc
      instance.initialize(*args, &block)
      instance
    end
  end
end
