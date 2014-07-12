module Anakin
  class TransparentButtonCell < NSButtonCell
    
    def init
      super.tap do |instance|
        instance.bezelStyle = NSRecessedBezelStyle
        instance.buttonType = NSOnOffButton
        instance.enabled = false
        instance.title = ''
        instance.gradientType = NSGradientNone
        instance.imagePosition = NSImageAbove
        instance.showsStateBy = NSNoCellMask
        instance.highlightsBy = NSChangeGrayCellMask 
        instance.imageScaling = NSImageScaleProportionallyUpOrDown
        instance.backgroundColor = NSColor.blackColor
      end
    end
    
    # remove the bezel around the cell
    def drawBezelWithFrame(frame, inView:controlView)
    end
  end
end