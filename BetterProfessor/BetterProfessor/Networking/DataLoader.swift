//
//  DataLoader.swift
//  BetterProfessor
//
//  Created by Bhawnish Kumar on 6/22/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import Foundation

protocol DataLoader {
    func loadData(from request: URLRequest, completion: @escaping(Data?, URLResponse?, Error?) -> Void)
    func loadData(from url: URL, completion: @escaping(Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: DataLoader {
    // When nesting completion handlers, remember that we're sending data to wherever the top layered method is called.
    // Always remember to call completion with only the data you want sent back.
    func loadData(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        // Create a DataTask with the request:
        // - An URLRequest can be built up to contain headers and encoded data in the body.

        // We use this when we want to send data to the server
        dataTask(with: request) { data, response, error in
            // We can choose to handle the usual checking for data or error in here.
            // But we can also worry about handling that within whichever controller uses these methods.
            // This gives rooom for custom error handling and data handling if the app was much larger in scale.
            // Here we'll need it because we're handling Posts and User network requests separately.
            completion(data, response, error)
        }.resume()
    }

    // Create a DataTask with just an URL: This is good if all we care about is pinging the server without any data.
    func loadData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }

}
