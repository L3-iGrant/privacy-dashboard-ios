#
# Be sure to run `pod lib lint PrivacyDashboardiOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PrivacyDashboardiOS'
  s.version          = '2024.4.2'
  s.summary          = 'Govstack PrivacyDashboard SDKs – Effortlessly embed a comprehensive privacy dashboard into any mobile application out of the box, ensuring adherence to Govstacks consent management framework. Prioritise user trust and transparency with this seamless integration tool.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'This SDKS is developed to provide an out-of-the-box privacy dashboard feature based on the Govstack consent building block framework. It is designed to integrate seamlessly into mobile applications; the dashboard provides a transparent view of how user data is utilised. Using data agreements, users and developers are kept informed about data procedures. Individual users can monitor their data usage, whilst developers are guided to handle the data appropriately, all by the Govstack consent management framework.'

  s.homepage         = 'https://github.com/decentralised-dataexchange/bb-consent-ios-privacy-dashboard.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'iGrant.io' => 'support@igrant.io' }
  s.source           = { :git => 'https://github.com/decentralised-dataexchange/bb-consent-ios-privacy-dashboard.git', :tag => s.version.to_s }
  s.social_media_url = 'https://www.linkedin.com/company/igrantio'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = '**/Classes/**/*.{h,m,swift,storyboard}'
# s.source_files = 'PrivacyDashboardiOS/Classes/**/*', 'PrivacyDashboardiOS/Classes/*', 'PrivacyDashboardiOS/Resources/*'
# s.source_files = 'PrivacyDashboardiOS/*' 'PrivacyDashboardiOS/Classes/**/*', 'PrivacyDashboardiOS/Classes/*', 'PrivacyDashboardiOS/Resources/*'
#  s.resources = 'PrivacyDashboardiOS/**/*'

   s.resource_bundles = {
     'PrivacyDashboardiOS' => ['**/Classes/*.storyboard', '**/Resources/*.xcassets', '**/Resources/*.lproj']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 5.4.1'
  s.dependency 'SwiftyJSON'
  s.dependency 'IQKeyboardManagerSwift'
  s.dependency "ExpandableLabel"
  s.dependency 'MiniLayout', '~> 1.3.0'
  s.dependency 'StepProgressView'
  s.dependency 'SDStateTableView'
  s.dependency 'SwiftEntryKit'
  s.dependency 'AFDateHelper'
  s.dependency 'Kingfisher'
end
