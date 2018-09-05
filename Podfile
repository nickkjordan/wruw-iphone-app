target 'WRUW-FM' do

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

inhibit_all_warnings!

local_podfile = "Pods/Podfile.local"
#eval(File.open(local_podfile).read) if File.exist? local_podfile

pod 'MarqueeLabel'
pod 'ARAnalytics', '~> 5.0.1', :subspecs => ["Mixpanel", "DSL"]
pod 'SimulatorStatusMagic', :configurations => ['Debug']
pod 'RxSwift', '~> 4.2.0'
pod 'RxCocoa', :git => 'https://github.com/ReactiveX/RxSwift.git', :branch => 'master'
pod 'NSObject+Rx', '~> 4.3.0'
pod 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit.git', :branch => 'develop'
pod 'Alamofire', '~> 4.7.2'

  target 'WRUW-FMTests' do
    inherit! :search_paths
  end

plugin 'cocoapods-keys', {
    :project => "WRUW",
    :target => "WRUW-FM",
    :keys => [
    "MixpanelToken",
    "SpotifyToken"
    ]}

end
