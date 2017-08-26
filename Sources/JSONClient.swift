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
	public let client: Responder
	
	public enum Error: Swift.Error {
		case invalidResponse
		case invalidURL
	}
	
	open func headers() -> [HeaderKey: String] { return [:] }
	
	public init(baseUrl: String, client: Responder) {
		self.baseUrl = baseUrl
		self.client = client
	}
	
	open func performRequest(method: HTTP.Method = .get,
	                         pathComponents components: [String] = [],
	                         query: [String: CustomStringConvertible] = [:],
	                         headers: [HeaderKey: String] = [:],
	                         body: ContentBody = .empty) throws -> JSON {
		
		guard let uri = ([baseUrl] + components).joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
			throw Error.invalidURL
		}
		
		var requestHeaders = self.headers()
		headers.forEach { requestHeaders[$0.key] = $0.value }
		requestHeaders["Content-Type"] = body.contentType.description
		
		let request = Request(method: method, uri: uri, headers: requestHeaders, body: body.content.makeBody())
		if !query.isEmpty {
			request.formURLEncoded = try Node(node: query)
		}
		let response = try client.respond(to: request)
		switch response.body {
		case .data(let bytes): return try JSON(bytes: bytes)
		case _: throw Error.invalidResponse
		}
	}
}
