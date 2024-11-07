//
//  Timer+Extension.swift
//  SampleKit
//
//  Created by gyun on 2023/06/29.
//

import Foundation

public final class TimerProvider {
    private weak var timer: Timer?
    private weak var target: AnyObject?
    private let action: (Timer) -> Void
    
    private init(
        timeInterval: TimeInterval,
        target: AnyObject,
        repeats: Bool,
        action: @escaping (Timer) -> Void
    ) {
        self.target = target
        self.action = action
        self.timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(fire),
            userInfo: nil,
            repeats: repeats
        )
    }
    
    public class func scheduledTimer(
        timeInterval: TimeInterval,
        target: AnyObject,
        repeats: Bool,
        action: @escaping (Timer) -> Void
    ) -> Timer? {
        TimerProvider(
            timeInterval: timeInterval,
            target: target,
            repeats: repeats,
            action: action
        ).timer
    }
    
    @objc private func fire(timer: Timer) {
        if target == nil {
            timer.invalidate()
        } else {
            DispatchQueue.main.safeAsync {
                self.action(timer)
            }
        }
    }
    
    public func invalidate() {
        timer?.invalidate()
    }
}
