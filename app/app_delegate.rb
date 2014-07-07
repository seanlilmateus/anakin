class AppDelegate
  
  def initialize
    @handler = Luke::URLHandler.new
  end
  
  
  def applicationWillFinishLaunching(_)
    register_handler
  end
  
  
  def applicationDidFinishLaunching(_)
    buildWindow
  end
  
  
  def buildWindow
    @window_controller = Luke::WindowController.new
    @window = @window_controller.window
    @window.center
    @window.orderFrontRegardless
    @window.true_center!
    show_items
  end
  
  
  def applicationWillResignActive(_)
  end
  
  
  def applicationWillBecomeActive(_)
  end
  
  def default_browser_request
    url_ptr = Pointer.new :object
    url = NSURL.URLWithString("http:")
    error = LSGetApplicationForURL(url, KLSRolesAll, nil, url_ptr)
    text = 'Default Browser'
    info = "#{Luke::APP_NAME} is not currently set as your default browser. Would you like to make in your default browser?"
    promise = Luke::PromisedAlert.new(text, info)
    if error.zero? && url_ptr[0] != NSBundle.mainBundle.bundleURL
      promise.then  { register_as_default_browser } 
             .catch { |e| puts "failure #{e}" }
    else
      promise.reject(0)
    end
    
    promise
  end
  
  def show_items
    @handler.application_list
            .then { |items| matrix_items_initialization(items) }
            .then { set_cell_selection_action }
            .then { Dispatch::Queue.main.sync &@window.method(:true_center!) }
            .then { default_browser_request }
  end
  
  # Browser Handlers
  def getUrl(event, withReplyEvent:_)
    @window_controller.url_label.stringValue = ''
    @url_str = event.paramDescriptorForKeyword(KeyDirectObject).stringValue
    cells = @window_controller.icons_matrix.cells
    @window_controller.url_label.stringValue = @url_str
    @handler.applications.zip(cells) { |_, cell| cell.enabled = true }
  end
  
  def register_handler
    event_manager = NSAppleEventManager.sharedAppleEventManager
    event_manager.setEventHandler( self, 
                      andSelector: 'getUrl:withReplyEvent:', 
                    forEventClass: KInternetEventClass,
                       andEventID: KAEGetURL)
  end
  
  def register_as_default_browser
    bundle_id = NSBundle.mainBundle.bundleIdentifier
    http_result = LSSetDefaultHandlerForURLScheme('http', bundle_id)
    https_result = LSSetDefaultHandlerForURLScheme('https', bundle_id)
  end
  
  def set_cell_selection_action
    @window_controller.icons_matrix.target = self
    @window_controller.icons_matrix.action = 'selected_cell:'
  end
  
  def matrix_items_initialization(items)
    Dispatch::Queue.main.sync { @window_controller.add_items(items) }
  end
  
  def selected_cell sender
    current_url = @url_str
    @url_str = nil
    selected = sender.selectedCell
    app_name = @handler.applications[selected.tag][:name]
    @handler.openURL(current_url, withApplication:app_name)
    @window_controller.icons_matrix.cells.each { |cell| cell.enabled = true }
    @window_controller.url_label.stringValue = ''
  end
end
