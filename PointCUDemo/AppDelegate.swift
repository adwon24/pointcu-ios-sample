//
//  AppDelegate.swift
//  PointCUDemo
//
//  Created by Juno Yoon on 5/19/26.
//

import UIKit
import GFPSDK
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GFPAdManagerDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MARK: - NAM SDK 초기화
        let configuration = GFPAdConfiguration()
        DispatchQueue.main.async {
            GFPAdManager.setup(
                withPublisherCd: "N256497692",
                target: self,
                configuration: configuration
            ) { error in
                if let error = error {
                    print("[NAM] 초기화 실패: \(error.description)")
                }
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - GFPAdManagerDelegate (필수)
    func attStatus() -> GFPATTAuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        return GFPATTAuthorizationStatus(rawValue: Int(status.rawValue)) ?? .notDetermined
    }
}
