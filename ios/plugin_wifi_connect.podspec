#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin_wifi_connect.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plugin_wifi_connect'
  s.version          = '0.0.1'
  s.summary          = 'Connect Flutter apps to Wi-Fi networks by SSID or SSID prefix.'
  s.description      = <<-DESC
A low-dependency Flutter plugin for connecting to open or protected Wi-Fi networks
by SSID or SSID prefix, based on flutter_wifi_connect.
                       DESC
  s.homepage         = 'https://github.com/chenrilima/plugin_wifi_connect'
  s.license          = { :type => 'BSD-3-Clause', :file => '../LICENSE' }
  s.author           = 'Carlos Henrique'
  s.source           = { :path => '.' }
  s.source_files = 'plugin_wifi_connect/Sources/plugin_wifi_connect/**/*.{h,m,swift}'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
