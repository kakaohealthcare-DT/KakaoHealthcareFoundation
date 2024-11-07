import Foundation

@propertyWrapper
public class ThreadAtomic<Value> {
	private var storage: Value
	private var atomicQueue = DispatchQueue(label: "com.kakaohealthcare.mcare.atomic")
	
	public init(wrappedValue value: Value) {
		storage = value
	}
	
	public var wrappedValue: Value {
		get {
			var result: Value?
			atomicQueue.sync {
				result = storage
			}
			return result ?? storage
		}
		set {
			atomicQueue.async(flags: .barrier) {
				self.storage = newValue
			}
		}
	}
}
