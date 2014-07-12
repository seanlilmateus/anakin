# module Anakin
  class Application    
    attr_accessor :name, :visible, :icon_path
    
    # def self.supportsSecureCoding
    #   true
    # end
    
    def initialize(name, icon_path, visible=true)
      @name, @icon_path, @visible = name, icon_path, visible
    end
    
    VISIBILITY, NAME, ICON = 'visibility', 'name', 'icon'
    
    def initWithCoder(decoder)
      visiblility = decoder.decodeObjectForKey(VISIBILITY)
      the_icon = decoder.decodeObjectForKey(ICON)
      the_name = decoder.decodeObjectForKey(NAME)
      self.class.new(the_name, the_icon, visiblility)
    end
    
    def encodeWithCoder(coder)
      coder.encodeBool(@icon_path, forKey:ICON)
      coder.encodeObject(@name, forKey:NAME)
      coder.encodeBool(@visible, forKey:VISIBILITY)
    end
  end
# end
