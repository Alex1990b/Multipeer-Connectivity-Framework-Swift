//
//  ViewController.swift
//  MultipeerConnectivityFramework
//
//  Created by Alex on 26.09.18.
//  Copyright © 2018 alex. All rights reserved.
//

import UIKit

struct Test: Codable {
    var text: String
}

final class ViewController: UIViewController, PeerConnectionProtocol {
    typealias View = ViewController
    
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var messageTextField: UITextField!
    
    private var test: Test!
    
    var connectionService: MultipeerConnectivityService!

    override func viewDidLoad() {
        super.viewDidLoad()
        startSesion(peerIDname: UIDevice.current.name)
    }
    
    func didRecieveData(data: Data) {
        let jsonDeceder = JSONDecoder()
        do {
            let item = try? jsonDeceder.decode(Test.self, from: data)
            test = item
            DispatchQueue.main.async { [weak self] in
                self?.resultLabel.text = self?.test.text
            }
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return false
    }
}
private extension ViewController {
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        test = Test(text: messageTextField.text!)
        sendData(element: test)
    }
    
    @IBAction func seeDevicesButtonTapped(_ sender: UIButton) {
        showDevices()
    }
}

