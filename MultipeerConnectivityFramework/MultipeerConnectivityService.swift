//
//  MultipeerConnectivityService.swift
//  MultipeerConnectivityFramework
//
//  Created by Alex on 26.09.18.
//  Copyright © 2018 alex. All rights reserved.
//

import MultipeerConnectivity

protocol PeerConnectionProtocol: class where Self : UIViewController {
    var connectionService: MultipeerConnectivityService! { get set}
    
    func didRecieveData(data: Data)
}

extension PeerConnectionProtocol {
    func startSesion(peerIDname: String) {
        connectionService = MultipeerConnectivityService(peerIDname: peerIDname, rootViewController: self)
    }
    
    func showDevices() {
         present(connectionService.browserViewController, animated: true, completion: nil)
    }
    
    func sendData<T: Encodable>(element: T) {
        let jsonEnsoder = JSONEncoder()
        do {
          let data = try jsonEnsoder.encode(element)
           connectionService.sendData(data: data)
        } catch let(error) {
            print(error)
        }
    }
    
}


final class MultipeerConnectivityService: NSObject {
    
   private var peerId: MCPeerID!
   private var connectionSession: MCSession!
   private var advertiserAssistant: MCAdvertiserAssistant!
   private var rootViewController: PeerConnectionProtocol
    
   fileprivate var browserViewController: MCBrowserViewController!
    
    init(peerIDname: String, rootViewController: PeerConnectionProtocol ) {
        
        self.rootViewController = rootViewController
        peerId = MCPeerID(displayName: peerIDname)
        connectionSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        advertiserAssistant = MCAdvertiserAssistant(serviceType: "test", discoveryInfo: nil, session: connectionSession)
        browserViewController = MCBrowserViewController(serviceType:  "test", session: connectionSession)
        advertiserAssistant.start()
        super.init()
        browserViewController.delegate = self
        connectionSession.delegate = self
    }
    
   fileprivate func sendData(data: Data) {
        if !connectionSession.connectedPeers.isEmpty {
            do {
                try!  connectionSession.send(data, toPeers: connectionSession.connectedPeers, with: .reliable)
            }
        }
    }
}

extension MultipeerConnectivityService: MCSessionDelegate {
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:   print("connecting: \(peerID.displayName)")
        case .connected:    print("connected: \(peerID.displayName)")
        case .notConnected: print("notConnected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
         rootViewController.didRecieveData(data: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
}

extension MultipeerConnectivityService: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
        
    }
    
    
}
