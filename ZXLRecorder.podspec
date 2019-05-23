Pod::Spec.new do |s|

  s.name         = "ZXLRecorder"
  s.version      = "1.0.6"
  s.summary      = "A Library for iOS to use for recorder"
  s.homepage     = "https://github.com/ZXLBoaConstrictor"
  s.license      = "MIT"
  s.author             = { "zhangxiaolong" => "244061043@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ZXLBoaConstrictor/ZXLRecorder.git", :tag => "#{s.version}" }
  s.source_files  = "ZXLRecorder/Recorder/*.{h,m}"
  s.vendored_frameworks  = "ZXLRecorder/lame.framework"
  s.framework  = "AVFoundation"
  s.requires_arc = true
  s.xcconfig = { "OTHER_LDFLAGS" => "-w" }
end
