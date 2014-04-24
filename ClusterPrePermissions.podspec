#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "ClusterPrePermissions"
  s.version          = "0.1.0"
  s.summary          = "Cluster's pre-permissions utility to ask users using their own dialog for photos or contacts access, before making the system-based request."
  s.description      = <<-DESC
                       Cluster's reusable pre-permissions utility that lets developers ask the 
                       users on their own dialog for photos or contacts access, before making 
                       the system-based request. This is based on the Medium post by Cluster 
                       describing the different ways to ask for iOS permissions 
                       (https://medium.com/p/96fa4eb54f2c).
                       DESC
  s.homepage         = "https://cluster.co/"
  s.screenshots      = "http://f.cl.ly/items/2I1V1R3b3q3A3H3y3u18/new-1.jpg"
  s.license          = 'MIT'
  s.author           = { "Rizwan Sattar" => "rsattar@gmail.com" }
  s.source           = { :git => "https://github.com/clusterinc/ClusterPrePermissions.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/cluster'

  s.platform     = :ios, '6.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'ClusterPrePermissions/ClusterPrePermissions/*.{h,m}'
  #s.resources = 'Assets/*.png'

  #s.ios.exclude_files = 'Classes/osx'
  #s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  # s.frameworks = 'SomeFramework', 'AnotherFramework'
  # s.dependency 'JSONKit', '~> 1.4'
end
