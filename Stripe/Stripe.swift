//
//  StripeDelegate.swift
//  Stripe
//
//  Created by Jeroen Jochems on 13/02/2023.
//

import Foundation
import UIKit;

import StripeTerminal

class Stripe: NSObject, ObservableObject, DiscoveryDelegate, BluetoothReaderDelegate, OfflineDelegate {
    static let shared = Stripe()
    
    func terminal(_ terminal: Terminal, didChange networkStatus: NetworkStatus) {
        print("Network status changed to \(networkStatus)")
    }
    
    func terminal(_ terminal: Terminal, didForwardPaymentIntent intent: PaymentIntent, error: Error?) {
        print("Forwarded intent \(intent)")
    }
    
    func terminal(_ terminal: Terminal, didReportForwardingError error: Error) {
        print("Forwarding error reported \(error)")
    }
    
    
    @Published var readerMessageLabel = UILabel()
    @Published var readers: Array<Reader> = []
    @Published var connectedReader: Reader?
    
    func discoverReadersAction() {
        let config = DiscoveryConfiguration(
          discoveryMethod: .bluetoothScan,
          simulated: false
        )

        self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: self) { error in
            if let error = error {
                print("discoverReaders failed: \(error)")
            } else {
                print("discoverReaders succeeded")
            }
        }
    }
    
    func connectToReader(_ reader: Reader) {
        let config = BluetoothConnectionConfiguration(locationId: "tml_E6kczgO7xnof83")
        
        Terminal.shared.connectBluetoothReader(reader, delegate: self, connectionConfig: config) { reader, error in
            if let reader = reader {
                self.connectedReader = reader;
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func pay() {
        let params = PaymentIntentParameters(amount: 1000, currency: "EUR", paymentMethodTypes: ["card_present"])
        let createConfig = CreateConfiguration(failIfOffline: false)
        
        Terminal.shared.createPaymentIntent(params, createConfig: createConfig) {
            createResult, createError in
            if let error = createError {
                print("Failed creating paymentIntent \(error)")
            } else if let paymentIntent = createResult {
                print("Payment Intent created")
                
                
                Terminal.shared.collectPaymentMethod(paymentIntent) { collectResult, collectError in
                    if collectError != nil {
                        print ("Failed collecting patment method")
                    } else {
                        print("Success")
                    }
                    self.processPayment(paymentIntent)
                }
            }
        }
    }
    
    private func processPayment(_ paymentIntent: PaymentIntent) {
        Terminal.shared.processPayment(paymentIntent) { processResult, processError in
            if let error = processError {
                print("processPayment failed: \(error)")
            } else {
                print("Processing succeeded")
            }
        }
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        self.readers = readers
    }
    
    
    var discoverCancelable: Cancelable?
    
    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        print("Reader update is available")
    }
    
    func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        print("Started updating software")
    }
    
    func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        print("Reader updating: \(progress)")
    }
    
    func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
        print("Finished installing update")
    }
    
    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        readerMessageLabel.text = Terminal.stringFromReaderInputOptions(inputOptions)
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        readerMessageLabel.text = Terminal.stringFromReaderDisplayMessage(displayMessage)
    }
    
}
