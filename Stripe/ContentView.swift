//
//  ContentView.swift
//  Stripe
//
//  Created by Jeroen Jochems on 10/02/2023.
//

import SwiftUI
import StripeTerminal


struct ContentView: View {
    
    @ObservedObject var stripe = Stripe.shared
    
    init() {
        Terminal.setTokenProvider(APIClient.shared)
    }
    
    var body: some View {
        VStack {
            	
            if stripe.connectedReader != nil {
                Button("Pay 1000", action: stripe.pay)
            } else {
                
                if stripe.readers.count == 0 {
                    Button("Find readers", action: stripe.discoverReadersAction)
                } else {
                    ForEach(stripe.readers, id: \.self.serialNumber)  { reader in
                        Button(reader.serialNumber) {
                            stripe.connectToReader(reader)
                        }
                    }
                }
            }
        }
        .padding()
    }
    

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
