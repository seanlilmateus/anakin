module Anakin
  class SettingsWindowController < NSWindowController
    def init
      rect = NSRect.new([0, 0], [150.0, 150.0])
      mask = NSBorderlessWindowMask
      backing = NSBackingStoreBuffered
      window = NSWindow.alloc.initWithContentRect(rect, styleMask: mask, backing: backing, defer: true)
      window.backgroundColor = NSColor.clearColor # NSColor.blackColor     
      window.hasShadow = true
      window.alphaValue = 0.75
      window.opaque = false
      initWithWindow(window).tap { load_content }
    end
    
    def load_content
      @settings_controller ||= SettingsViewController.alloc.init
      Motion::Layout.new do |layout|
        layout.view self.window.contentView
        layout.subviews mainview: @settings_controller.view
        layout.vertical   '|[mainview]|'
        layout.horizontal '|[mainview]|'
      end if self.window.contentView.subviews.empty?
      
      @settings_controller.settings_button.action = :settings
      @settings_controller.settings_button.target = self
    end
    
    def settings
      @settings_controller.loading_screen.stop_animating
      flipper = WindowFlipper.new
      flipper.flip_right = false
      flipper.flip(self.window, to:NSApp.windows.first)
    end
    
  end
end
