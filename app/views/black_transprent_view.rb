module Luke
  class BlackTransparentView < NSView
    
    # TODO: Fix the NSBezierPath Strokes for rounded rects, to avoid double beziers
    def drawRect(dirty_rect)
      super
      inner_rect = NSInsetRect(dirty_rect, 2.0, 2.0)
      path = NSBezierPath.bezierPathWithRoundedRect(dirty_rect, xRadius:20.0, yRadius:20.0)
      NSColor.colorWithDeviceWhite(1.0, alpha: 0.8).set
      path.fill      
      path2 = NSBezierPath.bezierPathWithRoundedRect(inner_rect, xRadius:18.0, yRadius:18.0)
      NSColor.blackColor.set
      path2.fill
    end
    
  end
end
