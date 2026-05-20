# Uncomment the next line to define a global platform for your project
install! 'cocoapods', warn_for_unused_master_specs_repo: false
platform :ios, '15.0'

target 'PointCUDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'NAMSDK', '8.15.0'
  pod 'NAMSDK/MediationNDA', '8.15.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
