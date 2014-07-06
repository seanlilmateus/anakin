module Luke
  class SettingsWindowController < NSWindowController
    def init
      rect = NSRect.new([0, 0], [150.0, 150.0])
      mask = NSBorderlessWindowMask
      backing = NSBackingStoreBuffered
      window = NSWindow.alloc.initWithContentRect( rect, styleMask: mask, backing: backing, defer: true)
      window.backgroundColor = NSColor.clearColor # NSColor.blackColor     
      window.hasShadow = true
      window.alphaValue = 0.75
      window.opaque = false
      initWithWindow(window).tap { load_content }
    end
    
    def transparent_view
      @transparent_view ||= begin
        rect = NSRect.new [0, 0], [150, 150]
        BlackTransparentView.alloc.initWithFrame(rect)
      end
    end
    
    def load_content
      self.window.contentView = transparent_view
      Motion::Layout.new do |layout|
        layout.view transparent_view
        layout.subviews settings_gear: settings_button, label: label#, loading: loading_screen
        #layout.vertical   '|-5-[loading]-5-|'
        #layout.horizontal '|-5-[loading]-5-|'
        layout.vertical   '|-10-[settings_gear(20)]'
        layout.horizontal '|-10-[settings_gear(20)]'
        layout.constraint { label.centerX == superview.centerX }
        layout.constraint { label.centerY == superview.centerY - 20 }
      end
    end
    
    def label
      @label ||= NSTextField.alloc.init.tap do |lbl|
        lbl.bordered = false
        lbl.editable = true
        lbl.selectable = false
        lbl.textColor = NSColor.whiteColor
        lbl.backgroundColor = NSColor.clearColor
        lbl.stringValue = 'Settings coming soon'
      end
    end
    
    def loading_screen
      @loading ||= LoadingView.alloc.init.tap do |l|
        l.number_of_circles = 5
        l.radius = 30.0
        l.internal_spacing = 3
        l.delegate = self
        l.start_animating
      end
    end
    
    def loadingView(view, circleBackgroundColorAtIndex:index)
      NSColor.whiteColor
    end
    
    def settings_button
      @settings_button ||= NSButton.alloc.init.tap do |btn|
        btn.image = NSImage.imageNamed(NSImageNameSmartBadgeTemplate)
        btn.imagePosition = NSImageOnly
        btn.bezelStyle = NSRecessedBezelStyle
        btn.bordered = false
        btn.cell.backgroundColor = NSColor.blackColor
        btn.action = :settings
        btn.target = self
      end
    end
    
    def settings
      flipper = WindowFlipper.new
      flipper.flip_right = false
      flipper.flip(self.window, to:NSApp.windows.first)
    end

  end
end
