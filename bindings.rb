#!/usr/bin/env macruby
framework 'Foundation'
framework 'Cocoa'

# id obj = [decoder decodeObjectOfClass:[MyClass class] forKey:@"myKey"];
class Application
  attr_accessor :name, :visible
  
  def self.supportsSecureCoding
    true
  end
  
  def initialize(name, visible=true)
    @name, @visible = name, visible
  end
  
  def icon
  end
  
  VISIBILITY, NAME = 'visibility', 'name'
  
  def initWithCoder(decoder)
    visiblility = decoder.decodeObjectOfClass(TrueClass, forKey:VISIBILITY)
    the_name = decoder.decodeObjectOfClass(NSString, forKey:NAME)
    self.class.new(the_name, visiblility)
  end
  
  def encodeWithCoder(coder)
    coder.encodeBool(@visible, forKey:VISIBILITY)
    coder.encodeObject(@name, forKey:NAME)
  end
end

array = %W{mateus armando}.map(&Application.method(:new))
archiev =  NSKeyedArchiver.archivedDataWithRootObject(array)


defaults = { last_temperature: archiev }
duds = NSUserDefaults.standardUserDefaults.registerDefaults(defaults)
#duds.synchronize


transformer = NSValueTransformer.valueTransformerForName(NSKeyedUnarchiveFromDataTransformerName)
p transformer.transformedValue(archiev)

## p NSUserDefaultsController.sharedUserDefaultsController.values.valueForKey('last_temperature')
##puts NSUserDefaultsController.sharedUserDefaultsController.values.methods(false,true) #methods(true, true)
# withKeyPath: "values.last_temperature",

# NSUnarchiveFromDataTransformerName ;
# NSKeyedUnarchiveFromDataTransformerName ;

=begin
controller = NSArrayController.alloc.init
controller.bind 'contentObject',
      toObject: NSUserDefaultsController.sharedUserDefaultsController,
   withKeyPath: 'values.browsers',
       options: { 'NSContinuouslyUpdatesValue' => true }

tableview.bind 'content',
     toObject: controller,
  withKeyPath: 'values.browsers',
      options: { 'NSContinuouslyUpdatesValue' => true }


matrix.bind 'content',
   toObject: controller,
withKeyPath: 'values.browsers',
    options: { 
      'NSInsertsNullPlaceholderBindingOption' => false,
    }
=end#https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CocoaBindings/Concepts/NSUserDefaultsController.html
