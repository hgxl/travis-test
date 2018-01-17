Pod::Spec.new do |s|
  s.name = 'InAppNotificationFramework'
  s.version = '1.0.0'
  s.license = 'BSD'
  s.summary = 'Elegant InApp notifications framework'
  s.homepage = 'https://github.com/hgxl/travis-test'
  s.authors = { 'Henri GIL' => 'henri.m.gil@gmail.com' }
  s.source = { :git => 'https://github.com/hgxl/travis-test.git', :tag => s.version }

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'InAppNotificationFramework/*.swift'
