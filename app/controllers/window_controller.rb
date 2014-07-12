module Anakin
  class WindowController < NSWindowController
    attr_reader :browser_controller
    
    def init
      rect = NSRect.new([0, 0], [150.0, 150.0])
      main_window = BlackTransparentWindow.new(rect)
      initWithWindow(main_window).tap { load_content }
    end
    
    def settings
      @settings_window_controller.window.setFrame(self.window.frame, display:false)
      flipper = WindowFlipper.new
      flipper.flip(self.window, to:@settings_window_controller.window)
      @settings_window_controller.instance_variable_get(:@settings_controller)
                                .loading_screen
                                .start_animating
    end
        
    def load_content
      @browser_controller = BrowsersViewController.alloc.init
      @settings_window_controller = SettingsWindowController.alloc.init
      Motion::Layout.new do |layout|
        layout.view self.window.contentView
        layout.subviews mainview: @browser_controller.view
        layout.vertical   '|[mainview]|'
        layout.horizontal '|[mainview]|'
      end
      
      @browser_controller.settings_button.action = :settings
      @browser_controller.settings_button.target = self
      @settings_window_controller = SettingsWindowController.alloc.init
    end
    
    def method_missing(meth, *args, &blk)
      browser_controller.send(meth, *args, &blk)
    end
    
  end
end
