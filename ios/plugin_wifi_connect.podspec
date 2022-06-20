#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint plugin_wifi_connect.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'plugin_wifi_connect'
  s.version          = '0.0.1'
  s.summary          = 'Plugin referring to flutter_wifi_connect from our weplenish friends they gave us the permission to continue with the plugin new updates'
  s.description      = <<-DESC
Plugin referring to flutter_wifi_connect from our weplenish friends they gave us the permission to continue with the plugin new updates
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
