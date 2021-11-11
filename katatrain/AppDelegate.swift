//
//  AppDelegate.swift
//  katatrain
//
//  Created by 黄轶明 on 2021/11/10.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  static var orientationLock = UIInterfaceOrientationMask.all // By default you want all your views to rotate freely
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return AppDelegate.orientationLock
  }
}
