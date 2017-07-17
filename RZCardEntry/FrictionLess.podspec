#
# Be sure to run `pod lib lint FrictionLess.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FrictionLess'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FrictionLess.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A collection of swift UI/UX components for reducing friction in "user work": forms, payment, checkout.
                       DESC

  s.homepage         = 'https://github.com/Raizlabs/FrictionLess'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jay Clark' => 'jason.clark@raizlabs.com' }
  s.source           = { :git => 'https://github.com/raizlabs/FrictionLess.git', :tag => s.version.to_s }

  s.platform         = :ios, '10.0'

  s.default_subspec = 'All'

  # FormattableTextField

  s.subspec "FormattableTextField" do |ss|
    ss.source_files = 'FrictionLess/Classes/FormattableTextField/**/*'
    ss.frameworks = ["UIKit"]
  end

  # Card Entry

  s.subspec "CardEntry" do |ss|
    ss.source_files = 'FrictionLess/Classes/CardEntry/**/*'
    ss.frameworks = ["UIKit"]
    ss.dependency 'FrictionLess/FormattableTextField'
  end

  # Catch All

  s.subspec "All" do |ss|
    ss.dependency 'FrictionLess/FormattableTextField'
    ss.dependency 'FrictionLess/CardEntry'
  end

end
