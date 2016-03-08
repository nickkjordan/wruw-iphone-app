source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

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
pod 'SimulatorStatusMagic', :configurations => ['Debug']
pod 'RxSwift', '~> 2.0'
pod 'RxCocoa'
pod 'NSObject+Rx'

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :keys => [
    "MixpanelToken"
    ]}