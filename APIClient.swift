//
//  APIClient.swift
//  Burn
//
//  Created by Ambuj Punn on 9/7/17.
//

import Foundation

class APIClient {
    private var apiKey = ""
    
    static func sharedInstance(apiKey: String) -> APIClient {
        return APIClient(key: apiKey)
    }
    
    private init(key: String) {
        self.apiKey = key
    }
    
    func sendRequestWithQueryParams(endpoint: String, method: String, queryParams: [String:Any], completion: @escaping (_ data: Any?, _ response: URLResponse?, _ error: Error?) -> Void) {
        // Set up query params
        let parameterString = queryParams.stringFromHttpParameters()
        let requestString = "\(endpoint)?\(parameterString)"
        
        guard let request = self.setupRequest(endpoint: requestString, method: method) else {
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
    func sendRequestWithBody(endpoint: String, method: String, body: [String:Any], completion: @escaping (_ data: Any?, _ response: URLResponse?, _ error: Error?) -> Void) {
        guard var request = self.setupRequest(endpoint: endpoint, method: method) else {
            return
        }
       
        // Set up body
        do {
            let json = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = json
        } catch {
            print("Error: cannot create JSON from body")
            return
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
    private func setupRequest(endpoint: String, method: String) -> URLRequest? {
        guard let url = URL(string: endpoint) else {
            print("Error: Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(self.apiKey, forHTTPHeaderField: "auth")
        request.httpMethod = method
        
        return request
    }
}

// https://stackoverflow.com/questions/27723912/swift-get-request-with-parameters
extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}
