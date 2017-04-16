Pod::Spec.new do |s|
	s.name = 'BbCore'
	s.version = '0.0.9'
	s.license = 'MIT'
	s.summary = 'Core Libraries for Bb.'
	s.homepage = 'https://github.com/evilBird/BbCore'
	s.authors = { 'Travis Henspeter' => 'travis.henspeter@gmail.com' }
	s.source = { :git => 'https://github.com/evilBird/BbCore.git', :tag => s.version }
	s.requires_arc = true
	s.ios.deployment_target = '8.0'
	s.frameworks = 'UIKit'
	s.source_files = 'BbCore/**/*.{h,m}
	s.dependencies = 'BbRuntime', 'UIView+Layout'
end