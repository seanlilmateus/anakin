module Anakin
  
  class URLHandler
    
    def application_list
      promise = Dispatch::Promise.new
      Dispatch::Queue.concurrent.async do
        url = CFURLCreateWithString(KCFAllocatorDefault, 'http://', nil)
        urls = LSCopyApplicationURLsForURL(url, KLSRolesAll)
        
        fm = NSFileManager.defaultManager
        
        applications = urls.map do |url|
          app_name = fm.displayNameAtPath(url.path)
          Application.new(app_name, url.path)
        end
        
        update_defaults(applications)
        @applications = ordered_by_favourites(applications)
        promise.fulfill WeakRef.new(@applications)
      end
      promise
    end
    
    attr_reader :applications
    
    def openURL(url, withApplication:app_name)
      work_space = NSWorkspace.sharedWorkspace
      app_path = work_space.fullPathForApplication(app_name)
      if app_path
        bundle_id = NSBundle.bundleWithPath(app_path).bundleIdentifier
        urls = [NSURL.URLWithString(url)]
        
        work_space.openURLs(urls,
                     withAppBundleIdentifier: bundle_id, 
                                     options: NSWorkspaceLaunchAsync,
              additionalEventParamDescriptor: NSAppleEventDescriptor.nullDescriptor,
                           launchIdentifiers: nil)
      end
    end
    
    private
    
    def ordered_by_favourites(applications)
      # remove our own application from the suggestions
      applications.delete_if { |app| app.name.localizedCompare(APP_NAME).zero? } 
      # order by favs 
      indexes = favourite_order.map do |value|
         applications.index { |app| value == app.name }
      end.compact
      # immutable return
      NSArray.arrayWithArray applications.values_at(*indexes) | applications
    end
        
    private
        
    def favourite_order
      @favs ||= ['Safari', 'Google Chrome', 'Firefox']
    end

    def update_defaults(array)
      Dispatch::Queue.main.sync do
        archive =  NSKeyedArchiver.archivedDataWithRootObject(array)
        defaults = NSUserDefaults.standardUserDefaults
        unless defaults.objectForKey('browsers')
          defaults.setObject(archive, forKey:'browsers')
          defaults.synchronize
        end
      end
    end
    
  end
end
