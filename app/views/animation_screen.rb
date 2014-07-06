# https://github.com/mownier/MONActivityIndicatorView/blob/master/
# MONActivityIndicatorView/MONActivityIndicatorView.m
module Luke
  class LoadingView < NSView
  
    attr_reader :number_of_circles, :internal_spacing
    attr_reader :duration, :radius, :delay, :delegate
  
    def delegate=(del)
      @delegate = WeakRef.new(del)
    end
    
    def init
      initWithFrame(CGRect.new)
    end
  
    def initWithFrame(frame)
      super.tap { setup_defaults }
    end
  
    def start_animating
      unless self.animating?
        add_circles
        self.hidden = false
        @animating = true
      end
    end
  
    def stop_animating
      if self.animating?
        remove_circles
        self.hidden = true
        @animating = false
      end
    end
  
    def animating?
      @animating
    end
  
    def number_of_circles=(number)
      @number_of_circles = number
      adjust_frame
    end
  
    def radius=(rad)
      @radius = rad
      adjust_frame
    end
  
    def internal_spacing=(int)
      @internal_spacing = int
      adjust_frame
    end
  
    private
  
    def remove_circles
      self.subviews.each &:removeFromSuperview
    end
  
    def adjust_frame
      f = self.frame
      f.size.width  = (self.number_of_circles * ((2 * self.radius) + self.internal_spacing)) - self.internal_spacing
      f.size.height = self.radius * 2
      self.frame = f
    end
  
    def create_circle(radius, color, position)
      rect = NSRect.new([position, 0], [radius * 2, radius * 2])
      circle = NSView.alloc.initWithFrame rect
      circle.layer = CALayer.layer
      circle.layer.backgroundColor = color.CGColor
      circle.backgroundColor = color
      circle.wantsLayer = true
      circle.layer.cornerRadius = radius
      circle.translatesAutoresizingMaskIntoConstraints = false
      circle
    end
  
    def create_animation(duration, delay)
      CABasicAnimation.animationWithKeyPath('transform.scale').tap do |anim|
        anim.delegate = self
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.autoreverses = true
        anim.duration = duration
        anim.removedOnCompletion = false
        anim.beginTime = CACurrentMediaTime() + delay
        anim.repeatCount = Float::INFINITY
        anim.timingFunction = CAMediaTimingFunction.functionWithName(KCAMediaTimingFunctionEaseInEaseOut)
      end
    end
  
    def add_circles
      self.number_of_circles.times do |index|
        color = if self.delegate && self.delegate.respond_to?('loadingView:circleBackgroundColorAtIndex:')
          self.delegate.loadingView(self, circleBackgroundColorAtIndex:index)
        else
          @default_color
        end
      
        circle = create_circle(self.radius, color, index * ((2 * self.radius) + self.internal_spacing))
        # circle.layer.transform = CGAffineTransformMakeScale(0, 0)
        circle.layer.affineTransform = CGAffineTransformMakeScale(0, 0)
        animation = create_animation(self.duration, index * self.delay)
        circle.layer.addAnimation(animation, forKey:'scale')
        self.addSubview(circle)
      end
    end
  
    def setup_defaults
      self.translatesAutoresizingMaskIntoConstraints = false
      @number_of_circles = 5
      @internal_spacing  = 5
      @radius = 10
      @delay = 0.2
      @duration = 0.8
      @default_color = NSColor.lightGrayColor
      self.backgroundColor = NSColor.redColor
    end
    
  end
end
