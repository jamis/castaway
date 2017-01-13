$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'castaway/version'

Gem::Specification.new do |s|
  s.name        = 'castaway'
  s.version     = Castaway::VERSION
  s.authors     = ['Jamis Buck']
  s.email       = ['jamis@jamisbuck.org']
  s.homepage    = 'https://github.com/jamis/castaway'
  s.summary     = 'System for building screencasts and video presentations'
  s.license     = 'MIT'
  s.description = <<-DESC
    Construct screencasts in Ruby! Write your script, declare your timeline,
    mix your audio, and render your video in an easily-edited, easily-repeated
    DSL. (Depends on ImageMagick, Sox, and FFMPEG for the heavy-lifting.)
  DESC

  s.files = Dir['{bin,lib}/**/*', 'MIT-LICENSE', 'README.md']
  s.executables << 'castaway'

  s.add_dependency 'gli', '~> 2.14.0'
  s.add_dependency 'mini_magick', '~> 4.6.0'
  s.add_dependency 'ruby-progressbar', '~> 1.8.1'
  s.add_dependency 'chaussettes', '~> 1.0.0'
end
