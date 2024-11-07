import Foundation

public protocol ClassNameProtocol {
	static var className: String { get }
	
	var className: String { get }
}

public extension ClassNameProtocol {
	static var className: String {
		String(describing: self)
	}

	var className: String {
		type(of: self).className
	}
}

extension NSObject: ClassNameProtocol {}
