//
//  LinkedList.swift
//  SampleKit
//
//  Created by kyle.cha 10/14/23.
//

import Foundation

public protocol Nodeable {
	associatedtype Value
	var value: Value { get set }
	var next: Value? { get set }
	//		init(value: Value, next: Self?)
}

// MARK: Extensions

public extension Nodeable where Self.Value: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool { lhs.value == rhs.value }
}

public extension Nodeable where Self: AnyObject {
	var retainCount: Int { CFGetRetainCount(self as CFTypeRef) }
}

public extension Nodeable where Self: CustomStringConvertible {
	var description: String { "{ value: \(value), next: \(next == nil ? "nil" : "exist") }" }
}

public class LinkedListNode<N> {
	
	public var value: N
	public var next: LinkedListNode?
	
	public init(_ newValue: N) {
		self.value = newValue
	}
}

public class LinkedList<N> {
	
	public typealias Node = LinkedListNode<N>
	
	public init() { }
	
	// Node references
	public var head: Node?
	public var tail: Node?
}

// ------------------------------------------------------------------
// MARK: Helper Functions
// ------------------------------------------------------------------
extension LinkedList {
	
	public func isEmpty() -> Bool {
		var result = true
		if head != nil { // Head being non-nil for non-empty Linked List
			result = false
		}
		return result
	}
	
	public var first: Node? {
		head
	}
	
	public var last: Node? {
		tail
	}
	
	public var count: Int {
		var nodeCount = 0
		var tempNode = self.first
		while tempNode != nil {
			nodeCount += 1
			tempNode = tempNode?.next
		}
		return nodeCount
	}
}

// ------------------------------------------------------------------
// MARK: Node At Index
// ------------------------------------------------------------------

extension LinkedList {
	
	public func nodeAtIndex(_ index: Int) -> Node? {
		
		var result: Node?
		
		if self.isEmpty() || index > self.count - 1 {
			print("Invalid Linked List Node index...")
			return result
		}
		
		if index < self.count {
			var currentNode = self.head
			var currNodeIndex = -1
			
			while currentNode != nil {
				result = currentNode
				currNodeIndex += 1
				if currNodeIndex == index {
					break
				}
				currentNode = currentNode?.next
			}
		}
		return result
	}
	
	public func kthNodeFromEnd(_ index: Int) -> Node? {
		let nodeIndexFromStart = self.count - index - 1
		return nodeAtIndex(nodeIndexFromStart)
	}
}

// ------------------------------------------------------------------
// MARK: Human Readable Format
// ------------------------------------------------------------------
extension LinkedList: CustomStringConvertible {
	
	public var description: String {
		var text = "["
		var tempNode = self.first
		
		while tempNode != nil {
			if tempNode === self.first {
				text += "\(String(describing: tempNode?.value))"
			} else {
				text += text + " --> " + "\(String(describing: tempNode?.value))"
			}
			tempNode = tempNode?.next
		}
		text += "]"
		return text
	}
}

// ------------------------------------------------------------------
// MARK: Insert into Linked List
// ------------------------------------------------------------------

extension LinkedList {
	
	public func insertAtIndex(_ index: Int, value: N) {
		let newNode = LinkedListNode.init(value)
		if self.isEmpty() {
			if index > self.count - 1 {
				print("Invalid Linked List Node index. Can not insert new node...")
				return
			} else {
				// List was empty, insert new element
				self.head = newNode
				self.tail = newNode
			}
		} else if index > self.count - 1 {
			print("Invalid Linked List Node index. Can not insert new node...")
			return
		} else {
			// List has at-least 1 element, insert new element
			let prevNode = nodeAtIndex(index)
			newNode.next = prevNode?.next
			prevNode?.next = newNode
		}
	}
	
	public func insertAtHead(_ value: N) {
		let newNode = LinkedListNode.init(value)
		
		if self.head == nil && self.tail == nil {
			self.head = newNode
			self.tail = newNode
		} else {
			let tempHeadNode = self.head
			newNode.next = tempHeadNode
			self.head = newNode
		}
	}
	
	public func insertAtTail(_ value: N) {
		
		let newNode = LinkedListNode(value)
		newNode.next = nil
		self.tail?.next = newNode
		self.tail = newNode
		if self.head == nil {
			self.head = self.tail
		}
	}
	
	// TODO: More condition checks needs to be added here
	public func deleteAtIndex(_ index: Int) {
		if self.isEmpty() {
			print("Can not delete node from empty linked list")
		} else if index > self.count - 1 || index < 0 {
			print("Invalid Linked List Node index. Can not delete node...")
		} else if index == 0 {
			if self.count == 1 {
				self.head = nil
				self.tail = nil
			} else {
				self.head = head?.next
			}
		} else if index == self.count - 1 {
			self.tail = nodeAtIndex(index - 1)
		} else {
			let tempNode = nodeAtIndex(index - 1)
			tempNode?.next = nodeAtIndex(index)
		}
	}
}

// ------------------------------------------------------------------
// MARK: Detect Loop
// Explanation of Looping alorithm: https://www.youtube.com/watch?v=apIw0Opq5nk
// ------------------------------------------------------------------
extension LinkedList {
	
	public func detectLoop() -> (Bool, Node?) {
		
		var loopDetected = false
		var fastPointer = self.head
		var slowPointer = self.head
		
		var loopingNode: Node?
		
		while slowPointer?.next != nil {
			fastPointer = fastPointer?.next?.next
			slowPointer = slowPointer?.next
			
			if slowPointer === fastPointer {
				loopingNode = slowPointer
				loopDetected = true
				break
			}
		}
		return (loopDetected, loopingNode)
	}
}

// ------------------------------------------------------------------
// MARK: Reverse a Singly Linked List
// Recursively: https://www.youtube.com/watch?v=MRe3UsRadKw
// Iteratively: https://www.youtube.com/watch?v=XwIivDg1BlY
// ------------------------------------------------------------------

extension LinkedList {
	// O(n) time,
	// O(1) space
	public func reverseLL_Iterative() {
		var prevNode: Node? // as singly linked list doesn't has link to previous node, cache it
		var currNode = self.head // Node to traverse the linked list
		var nextNode: Node? // Cache next node, as during reversing the link between two nodes, connectivity to next gets lost
		
		self.tail = self.head
		
		while currNode != nil {
			nextNode = currNode?.next
			currNode?.next = prevNode
			prevNode = currNode
			currNode = nextNode
		}
		self.head = prevNode
		
		print("Reversed Linked List: \(self.description)")
	}
	
	// O(n) time,
	// O(n) space (due to recursion, each stack during recursion is cached in Stack memory)
	public func reverseLL_Recursively() {
		reverse_recursive(prev: nil, curr: self.head)
		print("Reversed Linked List: \(self.description)")
	}
	
	private func reverse_recursive(prev: Node?, curr: Node?) {
		if curr == nil {
			return
		}
		if curr?.next == nil {
			self.head = curr
			curr?.next = prev
			return
		}
		reverse_recursive(prev: curr, curr: curr?.next)
		curr?.next = prev
	}
}

// ------------------------------------------------------------------
// MARK: Pallindrome
// ------------------------------------------------------------------

extension LinkedList {
	
	public func isPallindrome() -> Bool {
		var result = false
		if self.count == 0 {
			return result
		} else if self.count == 1 {
			result = true
		} else {
			// Compare with reversed list is same as original one
			let origList = self
			self.reverseLL_Recursively()
			let reversedList = self
			let maxIndex = self.count / 2 + self.count % 2
			
			var currIndex = 0
			result = true
			while currIndex < maxIndex {
				if origList.nodeAtIndex(currIndex) !== reversedList.nodeAtIndex(currIndex) {
					result = false
					break
				}
				currIndex += 1
			}
		}
		return result
	}
}

extension LinkedListNode: Comparable, Equatable where N: Comparable, N: Equatable {
	public static func == (lhs: LinkedListNode<N>, rhs: LinkedListNode<N>) -> Bool {
		lhs.value == rhs.value && (lhs.memoryAddress(of: &lhs.next) == rhs.memoryAddress(of: &rhs.next))
	}
	
	private func memoryAddress<Type>(of pointer: UnsafePointer<Type>) -> String {
		"\(pointer)"
	}
	
	public static func < (lhs: LinkedListNode<N>, rhs: LinkedListNode<N>) -> Bool {
		lhs.value < rhs.value
	}
	
	public static func >= (lhs: LinkedListNode<N>, rhs: LinkedListNode<N>) -> Bool {
		lhs.value >= rhs.value
	}
}

// ------------------------------------------------------------------
// Delete Middle node of a Linked List. You don't know head or tail node
// https://www.youtube.com/watch?v=Cay6RsoIG78&index=4&list=PLamzFoFxwoNiAFTHWT-v7jtLAGbMn0Mar
// B => A => D => E => F => C
//           👆
// ------------------------------------------------------------------

extension LinkedList {
	
	public func deleteMiddleNode() {
		guard let node = nodeAtIndex(2) else {
			return
		}
		
		deleteGivenNode(node)
	}
	
	private func deleteGivenNode(_ node: LinkedListNode<N>) {
		let currValue = node.next?.value
		if let currVal = currValue {
			node.value = currVal
			node.next = node.next?.next
		}
	}
}
