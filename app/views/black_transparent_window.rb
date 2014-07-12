module Anakin
  class BlackTransparentWindow < NSWindow
    
    include OwnInitializer
    
    def true_center!
      nframe = self.frame
      screen = NSScreen.mainScreen.frame
      nframe.origin.x = (screen.size.width - nframe.size. width) / 2
      nframe.origin.y = (screen.size.height - nframe.size.height) / 5
      self.setFrameOrigin(nframe.origin)
    end
    
    
    # TODO: Make window collectionBehavior to appear in all spaces
    def initialize(rect)
      mask = NSBorderlessWindowMask
      backing = NSBackingStoreBuffered
      initWithContentRect(rect, styleMask:mask, backing:backing, defer:true)
      # self.level = NSStatusWindowLevel
      self.backgroundColor = NSColor.clearColor # NSColor.blackColor     
      self.hasShadow = true
      self.alphaValue = 0.75
      self.opaque = false
      self.hidesOnDeactivate = true
      # self.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces
      @initial_location = NSPoint.new
    end
    
    
    def canBecomeKeyWindow
      true
    end
  end
end
