target 'WRUW-FM' do

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

local_podfile = "Pods/Podfile.local"
#eval(File.open(local_podfile).read) if File.exist? local_podfile

pod 'CBStoreHouseRefreshControl'
pod 'MarqueeLabel'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/DSL'
pod 'SimulatorStatusMagic', :configurations => ['Debug']
pod 'RxSwift', '~> 2.6.1'
pod 'RxCocoa', '~> 2.6.1'
pod 'NSObject+Rx'
pod 'SnapKit', '~> 0.22.0'
pod 'Alamofire', '~> 3.5.0'

  target 'WRUW-FMTests' do
    inherit! :search_paths
  end

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :keys => [
    "MixpanelToken"
    ]}

end
