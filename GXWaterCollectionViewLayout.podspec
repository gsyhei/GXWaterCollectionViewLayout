#
#  Be sure to run `pod spec lint GXWaterCollectionViewLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "GXWaterCollectionViewLayout"
  s.version      = "0.0.1"
  s.summary      = "一个好用的瀑布流布局(可设置纵/横两个方向)"
  s.homepage     = "https://github.com/gsyhei/GXWaterCollectionViewLayout"
  s.license      = "MIT"
  s.author       = { "Gin" => "279694479@qq.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/gsyhei/GXWaterCollectionViewLayout.git", :tag => "0.0.1" }
  s.requires_arc = true
  s.source_files = "GXWaterCollectionViewLayout/GXWaterCollectionViewLayout*.{h,m}"

end
