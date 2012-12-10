#
# Be sure to run `pod spec lint VHMenuView.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "VHMenuView"
  s.version      = "1.0.0"
  s.summary      = "a menu can be configured from plist."
  s.homepage     = "https://github.com/b051/VHMenuView"
  s.license      = 'MIT'
  s.author       = { "Sheng Ning" => "shengning@gmail.com" }
  s.source       = { :git => "https://github.com/b051/VHMenuView.git", :tag => "1.0.0" }
  s.platform     = :ios, '5.0'
  s.source_files = '*.{h,m}'
  s.resources = "Resources/*.png"
  s.requires_arc = true
end
