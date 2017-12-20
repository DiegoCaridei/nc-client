//
//  CountUpAndDownLatch.swift
//  whoops
//
//  Created by vgm on 5/24/17.
//  Copyright © 2017 Durian. All rights reserved.
//

import Foundation

// modified from: https://github.com/zhuhaow/CountdownLatch/
// (MIT license) also changes for swift 3
public class CountUpAndDownLatch {
	public var count: Int
	
	private let dispatch_queue = DispatchQueue(label: "CountDownQueue")
	private let dispatch_queue_2 = DispatchQueue(label: "CountDownQueue")
	
	let semaphore = DispatchSemaphore(value: 0)
	
	var hasSubscriber = false
	
	public init(_ count: Int) {
		self.count = count
	}
	
	public func countDown() {
		let me = self
		
		dispatch_queue.sync() {
			
			if (me.count > 0)	{
				me.count -= 1	}
			
			if self.count == 0 && self.hasSubscriber {
				self.semaphore.signal()
				self.hasSubscriber = false
			}
		}
	}
	
	public func countUp() {
		dispatch_queue.sync() {
			self.count += 1
			if self.count == 0 && self.hasSubscriber {
				self.semaphore.signal()
				self.hasSubscriber = false
			}
		}
	}
	
	public func waitUntilZero() {
		dispatch_queue_2.sync() {
			if self.count == 0 {
				return
			}
			self.hasSubscriber = true
			semaphore.wait(timeout: DispatchTime.distantFuture)
		}
	}
}
