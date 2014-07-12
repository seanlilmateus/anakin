module Anakin
  class WindowController < NSWindowController
    def init
      rect = NSRect.new([0, 0], [150.0, 150.0])
      main_window = BlackTransparentWindow.new(rect)
      initWithWindow(main_window).tap { load_content }
    end
    
    
    def transparent_view
      @transparent_view ||= BlackTransparentView.alloc.initWithFrame([[0,0], [150, 150]])
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
    
    def url_label
      @url_label ||= NSTextField.alloc.init.tap do |lbl|
        lbl.bordered = false
        lbl.editable = false
        lbl.selectable = false
        lbl.opaque = false
        lbl.textColor = NSColor.whiteColor
        lbl.alignment = NSCenterTextAlignment
        lbl.cell.backgroundColor = NSColor.blackColor
        lbl.cell.usesSingleLineMode = true
        lbl.cell.wraps = true
        lbl.cell.lineBreakMode = NSLineBreakByTruncatingMiddle
        lbl.preferredMaxLayoutWidth = 300
        # lbl.backgroundColor = NSColor.clearColor
      end
    end
    
    def settings
      @settings_controller.window.setFrame(self.window.frame, display:false)
      flipper = WindowFlipper.new
      flipper.flip(self.window, to:@settings_controller.window)
    end
    
    
    def load_content
      self.window.contentView = transparent_view
      @settings_controller = SettingsWindowController.alloc.init
    end
    
    
    def icons_matrix(num_of_rows=1, num_of_cols=1)
      @_matrix ||= IconsMatrix.new([[0, 0], [145, 145]], num_of_rows, num_of_cols).tap do |mtx|
        Motion::Layout.new do |layout|
          layout.view transparent_view
          layout.subviews matrix: mtx, gear: settings_button, label:url_label
          layout.vertical   '|-15-[matrix]-30-|'
          layout.horizontal '|-5-[matrix]-5-|'
          layout.vertical   '|-10-[gear(20)]'
          layout.horizontal '|-10-[gear(20)]'
          layout.horizontal '[label(<=300@1000)]'
          layout.vertical   '[label(==20@1000)]-2-|'
          layout.constraint { label.centerX == superview.centerX }
        end
      end
    end
    
    def add_items(items)
      slices = items.each_slice(4).to_a
      num_of_cols = slices.count
      num_of_rows = num_of_cols > 1 ? 4 : slices.first.count
      items.zip(icons_matrix(num_of_cols, num_of_rows).cells) do |app, cell|
        cell.title, cell.image = app[:name], app[:icon]
      end
      icons_matrix.cells.each_with_index { |cell, idx| cell.tag = idx }      
      icons_matrix.sizeToCells
    end
    
  end
end
