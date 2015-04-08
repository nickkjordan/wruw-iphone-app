source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

local_podfile = "Pods/Podfile.local"
#eval(File.open(local_podfile).read) if File.exist? local_podfile

pod 'AFNetworking', '~> 2.5.0'
pod 'Ono'
pod 'AFOnoResponseSerializer'
pod 'CBStoreHouseRefreshControl'
pod 'MarqueeLabel'
pod 'SDCSegmentedViewController'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/DSL'

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :keys => [
    "MixpanelToken"
    ]}