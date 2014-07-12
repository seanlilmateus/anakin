module Anakin
  class SettingsViewController < NSViewController
    def loadView
      self.view = BlackTransparentView.alloc.initWithFrame([[0,0], [150, 150]])
      load_content
    end
    
    def load_content
      Motion::Layout.new do |layout|
        layout.view self.view
        layout.subviews settings_gear: settings_button, loading: loading_screen, label: label
        layout.vertical   '[loading(60)]'
        layout.horizontal '[loading(330)]'
        layout.constraint { loading.centerX == superview.centerX }
        layout.constraint { loading.centerY == superview.centerY }        
        layout.vertical   '|-10-[settings_gear(20)]'
        layout.horizontal '|-10-[settings_gear(20)]'
        layout.constraint { label.centerX == superview.centerX }
        layout.constraint { label.centerY == superview.centerY + 60 }
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
      end
    end
        
  end
end
