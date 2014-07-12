module Anakin
  class IconsMatrix < NSMatrix
    
    include OwnInitializer
    
    def initialize(frame, num_of_rows=1, num_of_cols)
      initWithFrame(frame, 
                mode: NSHighlightModeMatrix, #NSRadioModeMatrix
           cellClass: TransparentButtonCell,
        numberOfRows: num_of_rows,
     numberOfColumns: num_of_cols)
      self.selectionByRect = true
      self.cellBackgroundColor = NSColor.blackColor
      self.cellSize = NSSize.new(130, 135)
      self.intercellSpacing = NSSize.new(5, 5)
      self.allowsEmptySelection = false
      self.drawsCellBackground = true
      self.backgroundColor = NSColor.clearColor
    end
  end
end
