Pod::Spec.new do |s|

  s.name         = "ZXLRecorder"
  s.version      = "1.0.0"
  s.summary      = "A Library for iOS to use for recorder"
  s.description  = <<-DESC
                   DESC
  s.homepage     = "https://github.com/ZXLBoaConstrictor"
  s.license      = "MIT"
  s.author             = { "zhangxiaolong" => "244061043@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ZXLBoaConstrictor/ZXLRecorder.git", :tag => "#{s.version}" }
  s.source_files  = "Recorder", "Recorder/*"
  s.resource  = "lame.framework"
  s.framework  = "AVFoundation"
  s.requires_arc = true

end
