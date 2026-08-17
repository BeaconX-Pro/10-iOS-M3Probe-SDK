Pod::Spec.new do |s|
  s.name             = 'MKMThreeProbe'
  s.version          = '0.0.2'
  s.summary          = 'A short description of MKMThreeProbe.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/BeaconX-Pro/10-iOS-M3Probe-SDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lovexiaoxia' => 'aadyx2007@163.com' }
  s.source           = { :git => 'https://github.com/BeaconX-Pro/10-iOS-M3Probe-SDK.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  
  # ========== 资源文件 ==========
  s.resource_bundles = {
    'MKMThreeProbe' => ['MKMThreeProbe/Assets/*.png']
  }
  
  # ========== ConnectManager 层 ==========
  s.subspec 'ConnectManager' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/ConnectManager/**/*.{h,m}'
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKMThreeProbe/SDK'
  end
  
  # ========== CTMediator 路由层 ==========
  s.subspec 'CTMediator' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/CTMediator/**/*.{h,m}'
    ss.dependency 'CTMediator'
  end
  
  # ========== SDK 层（对外提供，客户只需要这个）==========
  s.subspec 'SDK' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/SDK/**/*.{h,m}'
    ss.dependency 'MKBaseBleModule'
  end
  
  # ========== Target 层 ==========
  s.subspec 'Target' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/Target/**/*.{h,m}'
    ss.dependency 'MKMThreeProbe/Functions'
  end
  
  # ========== Functions 层（包含所有页面，客户不需要）==========
  s.subspec 'Functions' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/Functions/**/*.{h,m}'
    
    ss.dependency 'MKMThreeProbe/ConnectManager'
    ss.dependency 'MKMThreeProbe/SDK'
    ss.dependency 'MKMThreeProbe/CTMediator'
    
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKCustomUIModule'
    ss.dependency 'MKBeaconXCustomUI'
    ss.dependency 'HHTransition'
    ss.dependency 'MLInputDodger'
    ss.dependency 'NordicDFU', '4.16.0'
  end
  
end
