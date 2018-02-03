//
//  Body.swift
//  JSONClient
//
//  Created by Emilio Peláez on 12/29/16.
//
//

import Foundation
import HTTP
import JSON

public struct ContentBody {
	public enum ContentType {
		case textPlain
		case applicationJson
		case custom(value: String)
	}
	
	public let contentType: ContentType
	public let content: BodyRepresentable
	
	public static let empty = ContentBody(contentType: .textPlain, content: Body.data([]))
	
	public init(contentType: ContentType, content: BodyRepresentable) {
		self.contentType = contentType
		self.content = content
	}
	
	public init(json: JSON) {
		self.init(contentType: .applicationJson, content: json.makeBody())
	}
	
	public init(plainText: String) {
		self.init(contentType: .textPlain, content: plainText)
	}
	
	public init<T: Encodable>(object: T, encoder: JSONEncoder = JSONEncoder()) throws {
		let data = try encoder.encode(object)
		self.init(contentType: .applicationJson, content: Body.data(data.makeBytes()))
	}
}


extension ContentBody.ContentType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .textPlain: return "text/plain"
		case .applicationJson: return "application/json"
		case .custom(let value): return value
		}
	}
}

