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
	
	public var jsonDecoder = JSONDecoder()
	
	public enum Error: Swift.Error {
		case invalidResponse
		case invalidURL
	}
	
	open func headers() -> [HeaderKey: String] { return [:] }
	
	public init(baseUrl: String, client: Responder) {
		self.baseUrl = baseUrl
		self.client = client
	}
	
	open func performDecodableRequest<T: Decodable>(method: HTTP.Method = .get,
	                                                path components: [String] = [],
	                                                query: [String: CustomStringConvertible] = [:],
	                                                headers: [HeaderKey: String] = [:],
	                                                body: ContentBody = .empty,
	                                                decoder: JSONDecoder? = nil) throws -> T {
		let data = try performDataRequest(method: method, path: components, query: query, headers: headers, body: body)
		return try (decoder ?? jsonDecoder).decode(T.self, from: data)
	}
	
	@discardableResult
	open func performJSONRequest(method: HTTP.Method = .get,
	                             path components: [String] = [],
	                             query: [String: CustomStringConvertible] = [:],
	                             headers: [HeaderKey: String] = [:],
	                             body: ContentBody = .empty) throws -> JSON {
		let data = try performDataRequest(method: method, path: components, query: query, headers: headers, body: body)
		return try JSON(bytes: data.makeBytes())
	}
	
	private func performDataRequest(method: HTTP.Method = .get,
	                             path components: [String] = [],
	                             query: [String: CustomStringConvertible] = [:],
	                             headers: [HeaderKey: String] = [:],
	                             body: ContentBody = .empty) throws -> Data {
		guard let path = components.joined(separator: "/").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
			throw Error.invalidURL
		}
		let uri = [baseUrl, path].joined(separator: "/")
		
		var requestHeaders = self.headers()
		headers.forEach { requestHeaders[$0.key] = $0.value }
		requestHeaders["Content-Type"] = body.contentType.description
		
		let request = Request(method: method, uri: uri, headers: requestHeaders, body: body.content.makeBody())
		if !query.isEmpty {
			request.formURLEncoded = try Node(node: query)
		}
		let response = try client.respond(to: request)
		switch response.body {
		case .data(let bytes): return Data(bytes: bytes)
		case _: throw Error.invalidResponse
		}
	}
}
