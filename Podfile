# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'
use_frameworks!

target 'FamousSpotTour' do
  pod 'SnapKit', '~> 5.0.0'
  pod 'RealmSwift'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
    end
  end
end
