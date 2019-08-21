//
//  ConnectAlertViewController.swift
//  imessage
//
//  Created by Feynman on 8/19/19.
//  Copyright © 2019 Feynman. All rights reserved.
//

import UIKit

func connectVC(_ extensionContext: NSExtensionContext?) -> UIAlertController {
    let bundleURL = URL(string: "com.vcal.smartcal.app")!
    let controller = UIAlertController(title: "Connect Calendar", message: nil, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default) { _ in
        extensionContext?.open(bundleURL, completionHandler: nil)
    }
    controller.addAction(action)
    
    return controller
}
