Pod::Spec.new do |s|
  s.name         = 'RBStoryboardLink'
  s.version      = '0.0.7'
  s.summary      = 'Makes transitioning between storyboards possible.'
  s.homepage     = 'https://github.com/rob-brown/RBStoryboardLink'
  s.license      = { 
    :type => 'MIT', 
    :file => 'LICENSE' 
  }
  s.author       = 'Robert Brown'
  s.source       = { 
      :git => 'https://github.com/djbe/RBStoryboardLink.git'
  }
  s.platform     = :ios, '5.1.1'
  s.source_files = 'RBStoryboardLink.{h,m}', 'RBStoryboardLinkSource.h'
  s.public_header_files = 'RBStoryboardLink.h', 'RBStoryboardLinkSource.h'
  s.frameworks = 'UIKit'
  s.requires_arc = true
end
