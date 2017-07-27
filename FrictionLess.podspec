Pod::Spec.new do |s|
  s.name             = 'FrictionLess'
  s.version          = '0.0.1'
  s.summary          = 'A collection of UX-focused swift components for reducing friction in "user work".'
  s.description      = <<-DESC
Reduce friction with auto-formatting data entry, auto-advancing forms, and proactive user feedback for valid/invalid input.
                       DESC

  s.homepage         = 'https://github.com/Raizlabs/FrictionLess'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jay Clark' => 'jason.clark@raizlabs.com' }
  s.source           = { :git => 'https://github.com/raizlabs/FrictionLess.git', :tag => s.version.to_s }

  s.platform         = :ios, '10.0'

  s.default_subspec = 'All'

  # FormattableTextField

  s.subspec "FormattableTextField" do |ss|
    ss.source_files = 'FrictionLess/FormattableTextField/**/*'
    ss.frameworks = ["UIKit"]
  end

  # Card Entry

  s.subspec "CardEntry" do |ss|
    ss.source_files = 'FrictionLess/CardEntry/**/*.{swift,strings}'
    ss.dependency 'FrictionLess/FormUI'
    ss.resources = "FrictionLess/CardEntry/CardEntry.xcassets"
  end

  # Phone Number Formatter

  s.subspec "PhoneFormatter" do |ss|
    ss.source_files = 'FrictionLess/PhoneFormatter/**/*'
    ss.dependency 'FrictionLess/FormattableTextField'
    ss.dependency 'PhoneNumberKit'
  end

  # Form UI

  s.subspec "FormUI" do |ss|
    ss.source_files = 'FrictionLess/FormUI/**/*.{swift,strings}'
    ss.dependency 'Anchorage'
    ss.dependency 'FrictionLess/FormattableTextField'
  end

  # Catch All

  s.subspec "All" do |ss|
    ss.dependency 'FrictionLess/FormattableTextField'
    ss.dependency 'FrictionLess/CardEntry'
    ss.dependency 'FrictionLess/PhoneFormatter'
    ss.dependency 'FrictionLess/FormUI'
  end

end
