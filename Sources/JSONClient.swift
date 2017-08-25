//
//  JSONClient.swift
//  JSONClient
//
//  Created by Emilio Peláez on 12/24/16.
//
//

import Foundation

import Vapor
import HTTP

open class JSONClient {
	public let baseUrl: String
	public let client: ClientProtocol.Type
	
	public enum Error: Swift.Error {
		case invalidResponse
		case invalidURL
	}
	
	open func headers() -> [HeaderKey: String] { return [:] }
	
	public init(baseUrl: String, client: ClientProtocol.Type) {
		self.baseUrl = baseUrl
		self.client = client
	}
	
	open func performRequest(method: HTTP.Method = .get,
	                         pathComponents components: [String] = [],
	                         query: [String: CustomStringConvertible] = [:],
	                         headers: [HeaderKey: String] = [:],
	                         body: ContentBody = .empty) throws -> JSON {
		guard let url = ([baseUrl] + components).joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
			throw Error.invalidURL
		}
		var requestHeaders = self.headers()
		headers.forEach { requestHeaders[$0.key] = $0.value }
		requestHeaders["Content-Type"] = body.contentType.description
		
		let response = try client.request(method, url, headers: requestHeaders, query: query, body: body.content)
		switch response.body {
		case .data(let bytes): return try JSON(serialized: bytes)
		case _: throw Error.invalidResponse
		}
	}
}
