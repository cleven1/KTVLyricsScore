Pod::Spec.new do |spec|
  spec.name         = "AgoraLyricsScore"
  spec.version      = "1.0.3"
  spec.summary      = "AgoraLyricsScore"
  spec.description  = "AgoraLyricsScore"

  spec.homepage     = "git@github.com:AgoraIO-Community/LrcView-iOS"
  spec.license      = "MIT"
  spec.author       = { "ZYQ" => "zhaoyongqiang@agora.io" }
  spec.source       = { :git => "git@github.com:AgoraIO-Community/LrcView-iOS.git" }
  spec.source_files  = "AgoraKaraokeScore/AgoraLrcScoreView/**/*.swift"
  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64', 'DEFINES_MODULE' => 'YES' }
  spec.ios.deployment_target = '10.0'
  spec.swift_versions = "5.0"
  spec.requires_arc  = true
  spec.static_framework = true
  spec.dependency "Zip"
end
