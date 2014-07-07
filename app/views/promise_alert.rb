module Luke
  class PromisedAlert
    def self.new(message, info='')
      promise = Dispatch::Promise.new
      alert = NSAlert.new
      #icon_name = NSBundle.mainBundle.infoDictionary['CFBundleIconFiles']
      alert.icon = NSImage.imageNamed(NSImageNameInfo) 
      alert.addButtonWithTitle 'Yes'
      alert.addButtonWithTitle 'No'
      alert.messageText = message
      alert.informativeText = info
=begin
      accessory = NSTextView.alloc.initWithFrame([[0,0], [200,15]])
      attr_string = NSAttributedString.alloc.initWithString(info, attributes: {
        NSFontAttributeName => NSFont.systemFontOfSize(NSFont.systemFontSize),
      })
      accessory.insertText attr_string
      accessory.editable = false
      accessory.drawsBackground = false
      alert.accessoryView = accessory
=end
      alert.alertStyle = NSInformationalAlertStyle
      
      alert.buttons[1].keyEquivalent = '\033'
      alert.buttons[0].keyEquivalent = '\r'
      
      Dispatch::Queue.main.sync do
        alert.beginSheetModalForWindow(NSApp.windows.first, completionHandler:-> ret_code {
          if ret_code == NSAlertFirstButtonReturn
            promise.fulfill(NSAlertFirstButtonReturn)
          else
            promise.reject(NSAlertSecondButtonReturn)
          end
        })
      end
      
      promise
    end
  end
end
