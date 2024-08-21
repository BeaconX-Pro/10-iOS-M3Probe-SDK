#
# Be sure to run `pod lib lint MKMThreeProbe.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MKMThreeProbe'
  s.version          = '0.0.1'
  s.summary          = 'A short description of MKMThreeProbe.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/BeaconX-Pro/10-iOS-M3Probe-SDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lovexiaoxia' => 'aadyx2007@163.com' }
  s.source           = { :git => 'https://github.com/BeaconX-Pro/10-iOS-M3Probe-SDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  
  s.resource_bundles = {
    'MKMThreeProbe' => ['MKMThreeProbe/Assets/*.png']
  }
  
  s.subspec 'ConnectManager' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/ConnectManager/**'
    
    ss.dependency 'MKBaseModuleLibrary'
    
    ss.dependency 'MKMThreeProbe/SDK'
  end
  
  s.subspec 'CTMediator' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/CTMediator/**'
    
    ss.dependency 'CTMediator'
  end
  
  s.subspec 'SDK' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/SDK/**'
    ss.dependency 'MKBaseBleModule'
  end
  
  s.subspec 'Target' do |ss|
    ss.source_files = 'MKMThreeProbe/Classes/Target/**'
    
    ss.dependency 'MKMThreeProbe/Functions'
  end
  
  s.subspec 'Functions' do |ss|
    
    ss.subspec 'AboutPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/AboutPage/Controller/**'
      end
    end

    ss.subspec 'AdvConfigPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/AdvConfigPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/AdvConfigPage/Model'
        ssss.dependency 'MKMThreeProbe/Functions/AdvConfigPage/View'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/AdvConfigPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/AdvConfigPage/View/**'
      end
    end

    ss.subspec 'ProbePage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/ProbePage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/ProbePage/View'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/ProbePage/View/**'
      end
    end

    ss.subspec 'QuickSwitchPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/QuickSwitchPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/QuickSwitchPage/Model'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/QuickSwitchPage/Model/**'
      end
    end

    ss.subspec 'ScanPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/ScanPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/ScanPage/Model'
        ssss.dependency 'MKMThreeProbe/Functions/ScanPage/View'

        ssss.dependency 'MKMThreeProbe/Functions/TabBarPage/Controller'
        ssss.dependency 'MKMThreeProbe/Functions/AboutPage/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/ScanPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/ScanPage/View/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/ScanPage/Model'
      end
    end

    ss.subspec 'SensorConfigPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/SensorConfigPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/SensorConfigPage/Model'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/SensorConfigPage/Model/**'
      end
    end
    
    ss.subspec 'SensorPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/SensorPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/SensorPage/View'
        
        ssss.dependency 'MKMThreeProbe/Functions/ProbePage'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/SensorPage/View/**'
      end
    end
    
    ss.subspec 'SettingPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/SettingPage/Controller/**'

        ssss.dependency 'MKMThreeProbe/Functions/SensorConfigPage/Controller'
        ssss.dependency 'MKMThreeProbe/Functions/QuickSwitchPage/Controller'
        ssss.dependency 'MKMThreeProbe/Functions/UpdatePage/Controller'
        ssss.dependency 'MKMThreeProbe/Functions/AdvConfigPage/Controller'
      end
    end

    ss.subspec 'TabBarPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/TabBarPage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/TabBarPage/Model'

        ssss.dependency 'MKMThreeProbe/Functions/SensorPage/Controller'
        ssss.dependency 'MKMThreeProbe/Functions/SettingPage/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/TabBarPage/Model/**'
      end
    end
    
    ss.subspec 'UpdatePage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/UpdatePage/Controller/**'
        
        ssss.dependency 'MKMThreeProbe/Functions/UpdatePage/Model'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MKMThreeProbe/Classes/Functions/UpdatePage/Model/**'
      end
    end

    ss.dependency 'MKMThreeProbe/ConnectManager'
    ss.dependency 'MKMThreeProbe/SDK'
    ss.dependency 'MKMThreeProbe/CTMediator'
    
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKCustomUIModule'
    ss.dependency 'MKBeaconXCustomUI'
    ss.dependency 'HHTransition'
    ss.dependency 'MLInputDodger'
    ss.dependency 'iOSDFULibrary',    '4.13.0'
  end
  
end
