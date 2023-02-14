import StripeTerminal

class APIClient: ConnectionTokenProvider {

    static let shared = APIClient()

    func fetchConnectionToken(_ completion: @escaping ConnectionTokenCompletionBlock) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        guard let url = URL(string: "https://staging.fastlane.events/api/stripe-terminal") else {
            fatalError("Invalid backend URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    // Warning: casting using `as? [String: String]` looks simpler, but isn't safe:
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let secret = json?["secret"] as? String {
                        print("Secrret = \(secret)")
                        completion(secret, nil)
                    }
                    else {
                        let error = NSError(domain: "com.stripe-terminal-ios.example",
                                            code: 2000,
                                            userInfo: [NSLocalizedDescriptionKey: "Missing `secret` in ConnectionToken JSON response"])
                        completion(nil, error)
                    }
                }
                catch {
                    completion(nil, error)
                }
            }
            else {
                let error = NSError(domain: "com.stripe-terminal-ios.example",
                                    code: 1000,
                                    userInfo: [NSLocalizedDescriptionKey: "No data in response from ConnectionToken endpoint"])
                completion(nil, error)
            }
        }
        task.resume()
    }
}
