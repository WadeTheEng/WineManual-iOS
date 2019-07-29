platform :ios, "7.0"

# ignore all warnings from all pods
inhibit_all_warnings!

# All  targets
pod 'RestKit', :git => 'git@github.com:Papercloud/RestKit.git', :commit => 'dd443eaa92cfb590642a14c6ce71c027f5200d4e'

pod 'PCDefaults',     :head
pod 'PCDefaults/Map', :head

pod 'MagicalRecord' # Active Record convenience
pod 'MMDrawerController'
pod 'Google-Maps-iOS-SDK'
pod 'iCarousel'
pod 'OHHTTPStubs'
pod 'PDTSimpleCalendar'
pod 'V8HorizontalPickerView'
pod 'SWTableViewCell', :git => 'https://github.com/Papercloud/SWTableViewCell'
pod 'Mixpanel'
pod 'BugSense'
pod 'forecast-ios-api'
pod 'Facebook-iOS-SDK', '~> 3.12.0'
pod 'CCTemplate', '~> 0.2.0'
pod 'TestFlightSDK', '~> 3.0'

#target "WineHound" do
  pod 'Instabug'
#end

target "WineHoundTests", :exclusive => true do
  pod 'KIF', '~> 2.0'
  pod 'Nocilla' # Stub HTTP requests
end

# Remove 64-bit build architecture from Pods targets
post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |configuration|
      target.build_settings(configuration.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
    end
  end
end