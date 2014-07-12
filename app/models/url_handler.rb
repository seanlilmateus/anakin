module Anakin
  
  class URLHandler
    
    def initialize
      @work_space = NSWorkspace.sharedWorkspace
    end

    def application_list
      promise = Dispatch::Promise.new
      Dispatch::Queue.concurrent.async do
        url = CFURLCreateWithString(KCFAllocatorDefault, 'http://', nil)
        urls = LSCopyApplicationURLsForURL(url, KLSRolesAll)
        fm = NSFileManager.defaultManager
        applications = urls.map do |url|
          objects = [
            fm.displayNameAtPath(url.path), 
            @work_space.iconForFile(url.path)
          ]
          NSDictionary.dictionaryWithObjects(objects, forKeys: [:name, :icon])
        end
        @applications = ordered_by_favourites(applications)
        promise.fulfill WeakRef.new(@applications)
      end
      
      promise
    end
    
    attr_reader :applications
    
    def openURL(url, withApplication:app_name)
      app_path = @work_space.fullPathForApplication(app_name)
      if app_path
        bundle_id = NSBundle.bundleWithPath(app_path).bundleIdentifier
        urls = [NSURL.URLWithString(url)]
        
        @work_space.openURLs(urls,
                     withAppBundleIdentifier: bundle_id, 
                                     options: NSWorkspaceLaunchAsync,
              additionalEventParamDescriptor: NSAppleEventDescriptor.nullDescriptor,
                           launchIdentifiers: nil)
      end
    end
    
    private
    
    def ordered_by_favourites(applications)
      # remove our own application from the suggestions
      applications.delete_if { |h| h[:name].localizedCompare(APP_NAME).zero? } 
      # order by favs 
      indexes = favourite_order.map do |value|
        applications.index { |h| value == h[:name] }
      end.compact
      # immutable return
      NSArray.arrayWithArray applications.values_at(*indexes) | applications
    end
    
    def defaults
      NSUserDefaults.standardUserDefaults
    end
    
    def favourite_order
      @favs ||= defaults.objectForKey('fav_order') || begin
        update_defaults(['Safari', 'Google Chrome', 'Firefox'])
        defaults.objectForKey('fav_order')
      end
    end
    
    def update_defaults(array)
      defaults.setObject(array, forKey:'fav_order')
      defaults.synchronize
      @favs = nil
    end
  end
end
