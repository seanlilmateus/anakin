class WindowFlipper  
  
  attr_reader :animation_window, :target_window, :duration
  attr_accessor :flip_right
  
  def initialize
    @duration = 0.4
    @flip_right = true
  end
  
  def flip_right?
    @duration
  end
  
  def flip(active_window, to:target_window)
    current = (active_window.currentEvent.modifierFlags & NSShiftKeyMask ? 10.0 : 1.0)
    durat = self.duration * current
    zDistance = 1500.0
    
    active_view = active_window.contentView.superview
    target_view = target_window.contentView.superview
    
    # create window for animation
    max_width  = [NSWidth(active_window.frame),  NSWidth(target_window.frame)].max  + 500
    max_height = [NSHeight(active_window.frame), NSHeight(target_window.frame)].max + 500
    
    origin = NSPoint.new(NSMidX(active_window.frame) - (max_width / 2.0),
                         NSMidY(active_window.frame) - (max_height / 2.0))
                         
    animation_frame = NSRect.new(origin, [max_width, max_height])
    @animation_window = window_for_animation(animation_frame)
    
    # add perspective
    transform = CATransform3DIdentity
    transform.m34 = 1.0/zDistance #-1.0 / zDistance
    # transform = CATransform3DRotate(transform, 80.0 * Math::PI / 180.0, 0, 1, 0)

    @animation_window.contentView.layer.sublayerTransform = transform

    # move target window to active window
    origin = [
      NSMidX(active_window.frame) - (NSWidth(target_window.frame) / 2 ), 
      NSMaxY(active_window.frame) - NSHeight(target_window.frame)
    ]
    size = [NSWidth(target_window.frame), NSHeight(target_window.frame)]
    target_frame = NSRect.new(origin, size)    
    target_window.setFrame(target_frame, display:false)
    @target_window = WeakRef.new(target_window)
    
    # New Active/Target Layers
    CATransaction.begin
    active_window_layer = layer_from_view(active_view)
    target_window_layer = layer_from_view(target_view)
    CATransaction.commit
    
    active_window_layer.frame = rect( active_view.frame, 
                            fromView: active_view, 
                              toView: @animation_window.contentView)
                              
    target_window_layer.frame = rect( target_view.frame, 
                            fromView: target_view, 
                              toView: @animation_window.contentView)
    
    CATransaction.begin
    @animation_window.contentView.layer.addSublayer(active_window_layer)
    CATransaction.commit
    
    @animation_window.orderFront(nil)
    
    CATransaction.begin
    @animation_window.contentView.layer.addSublayer(target_window_layer)
    CATransaction.commit
    
    # Animate our new layers
    CATransaction.begin
    active_anim = animationWithDuration(durat * 0.5, flip:true, right:@flip_right)
    target_anim = animationWithDuration(durat * 0.5, flip:false,  right:@flip_right)
    CATransaction.commit
    
    target_anim.delegate = self
    active_window.orderOut(nil)
  
    CATransaction.begin
    active_window_layer.addAnimation(active_anim, forKey:'flipWnd')
    target_window_layer.addAnimation(target_anim, forKey:'flipWnd')
    CATransaction.commit
  end
  
  private
  
  def window_for_animation(frame)
    NSWindow.alloc.initWithContentRect( frame, 
                             styleMask: NSBorderlessWindowMask, 
                               backing: NSBackingStoreBuffered, 
                                 defer: false).tap do |win|
      win.hasShadow = win.opaque = false
      win.backgroundColor = NSColor.clearColor
      win.contentView.wantsLayer = true
    end
  end
  
  def layer_from_view(view)
    image = view.bitmapImageRepForCachingDisplayInRect(view.bounds)
    view.cacheDisplayInRect(view.bounds, toBitmapImageRep:image)
    
    layer = CALayer.layer
    layer.contents = image.CGImage
    layer.doubleSided = false
    
    # shadow window, used in the Mac OS X 10.6
    layer.shadowOpacity = 0.5
    layer.shadowOffset = NSSize.new(0, -10)
    layer.shadowRadius = 15.0
    layer
  end
  
  # next 3 methods for translate coordinats
  def rect_from_screen(rect, view)
    rect.origin = view.window.convertScreenToBase(rect.origin)
    view.convertRect(rect, fromView:nil)
  end
  
  def  rect_to_screen(rect, view)
    rect = view.convertRect(rect, toView:nil)
    rect.origin = view.window.convertBaseToScreen(rect.origin)
    rect
  end

  
  def rect(rect, fromView:from, toView:to)
    rect = rect_to_screen(rect, from)
    rect_from_screen(rect, to)
  end
  
  # create Core Animation are receding and to expand the window
  def animationWithDuration(time, flip:flip, right:right)
    flip_animation = CABasicAnimation.animationWithKeyPath('transform.rotation.y')
    start_value, end_value = if right
      [(flip ? 0.0 : -Math::PI), (flip ? Math::PI : 0.0)]
    else
      [(flip ? 0.0 : Math::PI), (flip ? -Math::PI : 0.0)]
    end
    
    flip_animation.fromValue = start_value
    flip_animation.toValue = end_value
    
    scale_animation = CABasicAnimation.animationWithKeyPath('transform.scale')
    scale_animation.fromValue  = 1.0
    scale_animation.toValue = 1.3
    scale_animation.duration = time * 0.5
    scale_animation.autoreverses = true
    
    animation_group = CAAnimationGroup.animation.tap do |group|
      group.animations = [flip_animation, scale_animation]
      func = CAMediaTimingFunction.functionWithName(KCAMediaTimingFunctionEaseInEaseOut)
      group.timingFunction = func
      group.duration = time
      group.fillMode = KCAFillModeForwards
      group.removedOnCompletion = false
    end
  end
  
  def animationDidStop(animation, finished:flag)
    if flag
      @target_window.makeKeyAndOrderFront(nil)
      @animation_window.orderOut(nil)
      @target_window = nil
      @animation_window = nil
    end
  end
end
