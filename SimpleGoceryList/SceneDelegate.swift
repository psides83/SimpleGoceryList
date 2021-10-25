//
//  SceneDelegate.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/20/21.
//

import SwiftUI
import UIKit
import CloudKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            guard let url = URL(string: shortcutItem.type) else {
                return
            }

            openURL(url)
        }
    }
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let url = URL(string: shortcutItem.type) else {
            completionHandler(false)
            return
        }

        openURL(url, completion: completionHandler)
    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        guard cloudKitShareMetadata.containerIdentifier == Config.containerID else {
            print("Shared container identifier \(cloudKitShareMetadata.containerIdentifier) did not match known identifier.")
            return
        }

        // Create an operation to accept the share, running in the app's CKContainer.
        let container = CKContainer(identifier: Config.containerID)
        let operation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])

        debugPrint("Accepting CloudKit Share with metadata: \(cloudKitShareMetadata)")

        operation.perShareCompletionBlock = { metadata, share, error in
            let rootRecordID = metadata.rootRecordID

            if let error = error {
                debugPrint("Error accepting share with root record ID: \(rootRecordID), \(error)")
            } else {
                debugPrint("Accepted CloudKit share for root record ID: \(rootRecordID)")
            }
        }

        operation.acceptSharesCompletionBlock = { error in
            if let error = error {
                debugPrint("Error accepting CloudKit Share: \(error)")
            }
        }

        operation.qualityOfService = .utility
        container.add(operation)
    }
}
