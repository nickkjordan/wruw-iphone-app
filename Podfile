target 'WRUW-FM' do

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

local_podfile = "Pods/Podfile.local"
#eval(File.open(local_podfile).read) if File.exist? local_podfile

pod 'MarqueeLabel'
pod 'ARAnalytics', '~> 5.0.1', :subspecs => ["Mixpanel", "DSL"]
pod 'SimulatorStatusMagic', :configurations => ['Debug']
pod 'RxSwift', '~> 4.1.2'
pod 'RxCocoa', '~> 4.1.2'
pod 'NSObject+Rx', '~> 4.3.0'
pod 'SnapKit', '~> 4.0.0'
pod 'Alamofire', '~> 4.7.2'

  target 'WRUW-FMTests' do
    inherit! :search_paths
  end

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :keys => [
    "MixpanelToken"
    ]}

end
