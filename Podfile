target 'WRUW-FM' do

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

local_podfile = "Pods/Podfile.local"
#eval(File.open(local_podfile).read) if File.exist? local_podfile

pod 'MarqueeLabel'
pod 'ARAnalytics/Mixpanel'
pod 'ARAnalytics/DSL'
pod 'SimulatorStatusMagic', :configurations => ['Debug']
pod 'RxSwift', '~> 3.3.1'
pod 'RxCocoa', '~> 3.3.1'
pod 'NSObject+Rx', '~> 3.0.0'
pod 'SnapKit', '~> 3.2.0'
pod 'Alamofire', '~> 4.4.0'

  target 'WRUW-FMTests' do
    inherit! :search_paths
  end

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :keys => [
    "MixpanelToken"
    ]}

end
