//
//  ViewController.swift
//  dewdue
//
//  Created by Devine Lu Linvega on 2014-08-06.
//  Copyright (c) 2014 XXIIVV. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {
                            
	@IBOutlet var timeLeftLabel: UILabel!
	@IBOutlet var timeTargetLabel: UILabel!
	@IBOutlet var timeTouchView: UIView!
	@IBOutlet var gridView: UIView!
	@IBOutlet var pointNow: UIView!
	@IBOutlet var pointTarget: UIView!
	@IBOutlet var alarmLabel: UILabel!
    
    @IBOutlet weak var markerNow: UIView!
    @IBOutlet weak var markerTarget: UIView!
	
	var tileSize:CGFloat = 0.0
	var screenWidth:CGFloat = 0.0
	var screenHeight:CGFloat = 0.0
	
	var templateLineSpacing:CGFloat = 5.0
	
	var touchStart:CGFloat = 0.0
	var incrementMinutes = 0
	
	var timeNow: DateComponents!
	var timeThen: DateComponents!
	
	var timerTouch:Timer!
    
    var touchSound:SystemSoundID = 0
    var releaseSound:SystemSoundID?
    var barSound:SystemSoundID?
    
    var lastLineCount:Float = 0.0
	
	// MARK: - Init
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		templateStart()
		timeStart()
		lineUpdate()
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}
	
	// MARK: - Time
	
	func timeStart()
    {
        touchSound = createTouchSound()
        releaseSound = createReleaseSound()
        barSound = createBarSound()
        
		timeUpdate()
		var timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.timeStep), userInfo: nil, repeats: true)
	}
	
	func timeUpdate()
	{
		let date = Date()
		
		let calendar = Calendar.current
		let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
		
		timeNow = (calendar as NSCalendar).components([.hour, .minute, .second] , from: date)
		
		let dateFuture = Date(timeIntervalSinceNow: TimeInterval(incrementMinutes) )
		let futureDate = dateFormatter.string( from: dateFuture )
		
		timeThen = (calendar as NSCalendar).components([.hour, .minute, .second] , from: dateFuture)
		
		var timeThenSecondsString = "\(timeThen.second)"
		if( timeThen.second! < 10 ){ timeThenSecondsString = "0\(timeThen.second)" }
		
		var timeThenMinutesString = "\(timeThen.minute)"
		if( timeThen.minute! < 10 ){ timeThenMinutesString = "0\(timeThen.minute)" }
		
		timeTargetLabel.text = "\(timeThen.hour):\(timeThenMinutesString):\(timeThenSecondsString)"
		
		let hoursLeft = incrementMinutes/60/60
		let minutesLeft = (incrementMinutes/60) - (60*hoursLeft)
		let secondsLeft = (incrementMinutes) - (60*60*hoursLeft) - (60*minutesLeft)
		
		var secondsLeftString = "\(secondsLeft)"
		if( secondsLeft < 10 ){ secondsLeftString = "0\(secondsLeft)" }
		
		var MinutesLeftString = "\(minutesLeft)"
		if( minutesLeft < 10 ){ MinutesLeftString = "0\(minutesLeft)" }
		
		if(hoursLeft > 0){
			timeLeftLabel.text = "\(hoursLeft):\(MinutesLeftString):\(secondsLeftString)"
		}
		else if( minutesLeft > 0 ){
			timeLeftLabel.text = "\(MinutesLeftString):\(secondsLeftString)"
		}
		else{
			timeLeftLabel.text = "\(secondsLeftString)"
		}
		
		if( incrementMinutes < 1 ){
			timeLeftLabel.text = ""
		}
	
		if incrementMinutes > 0 { incrementMinutes -= 1 }
        
        incrementMinutes = incrementMinutes % 86400
	}
	
	func timeIncrementSmall()
	{
		incrementMinutes += 5
		timeStep()
	}
	
	func timeStep()
	{
		timeUpdate()
		lineUpdate()
	}
	
	// MARK: - Template
	
	func templateStart()
	{
		tileSize = self.view.frame.width/8
		screenWidth = self.view.frame.width
		screenHeight = self.view.frame.height
		timeTouchView.frame = CGRect(x: tileSize, y: tileSize, width: screenWidth-(2*tileSize), height: screenHeight-(2*tileSize))
		
		pointNow.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
		pointNow.backgroundColor = UIColor.white
		pointTarget.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
		pointTarget.backgroundColor = UIColor.white
		
		gridView.frame = CGRect(x: tileSize, y: tileSize, width: screenWidth - (2 * tileSize), height: screenHeight - (2 * tileSize) )
		
		timeLeftLabel.frame = CGRect(x: tileSize, y: 0, width: screenWidth-(2*tileSize), height: tileSize)
		timeTargetLabel.frame = CGRect(x: tileSize, y: 0, width: screenWidth-(2*tileSize), height: tileSize)
		alarmLabel.frame = CGRect(x: tileSize, y:screenHeight - (1 * tileSize) , width: screenWidth-(2*tileSize), height: tileSize)
		
		Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.templateGrid), userInfo: nil, repeats: false)
	}
	
	func templateGrid()
	{
        var i = 1
		while i < 24*4
		{
            let targetFrame:CGRect = CGRect(x: 0, y: (templateLineSpacing * CGFloat(i)), width: screenWidth-(2*tileSize)+1, height: 1)
            let initFrame:CGRect = CGRect(x: 0, y: (templateLineSpacing * CGFloat(i)), width: 0, height: 1)
			let lineView = UIView(frame: initFrame)
			
			if i == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).withAlphaComponent(0.5) }
			else if i % 24 == 0 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.3.png")!).withAlphaComponent(0.5) }
			else if i % 4 == 2 { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).withAlphaComponent(0.5) }
			else { lineView.backgroundColor = UIColor(patternImage:UIImage(named:"tile.1.png")!).withAlphaComponent(0.5) }
			
			self.gridView.addSubview(lineView)
            
            
            let duration = 0.5
            let delay:TimeInterval = (0.01 * Double(i))
            let options = UIViewAnimationOptions.curveLinear
            
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                // any changes entered in this block will be animated
                lineView.frame = targetFrame
            }, completion: nil)

			i = i + 1
		}
		
	}
    
	// MARK: - Touch
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
        AudioServicesPlaySystemSound(touchSound)
        
        if(( timerTouch ) != nil){
            timerTouch.invalidate()
        }
        
		for touch: AnyObject in touches {
			let location = touch.location(in: gridView)
			touchStart = location.y
		}
		
		timerTouch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(ViewController.timeIncrementSmall), userInfo: nil, repeats: true)
		
		timeIncrementSmall()
		
		timeLeftLabel.textColor = UIColor.gray
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
        timerTouch.invalidate()
        timerTouch.invalidate()
        
		for touch: AnyObject in touches
		{
			let location = touch.location(in: gridView)
			let incrementStep = abs(touchStart - location.y)
			
			if touchStart > location.y { incrementMinutes += Int(incrementStep) }
			else{ incrementMinutes -= Int(incrementStep) }
			
			if incrementMinutes < 0 {
				incrementMinutes = 0
			}
			
			timeUpdate()
			lineUpdate()
		}
		
		timeLeftLabel.textColor = UIColor.gray
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        AudioServicesPlaySystemSound(releaseSound!)
        
        timerTouch.invalidate()
        timerTouch.invalidate()
		
		if incrementMinutes > 0
		{
			alarmSetup()
		}
		
		timeLeftLabel.textColor = UIColor.white
		
		timeUpdate()
        lineUpdate()
	}
    
    // MARK: Sounds
    
    func createTouchSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.touch" as CFString, "wav" as CFString, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
    func createReleaseSound() -> SystemSoundID {
        var soundID: SystemSoundID = 1
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.release" as CFString, "wav" as CFString, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
    func createBarSound() -> SystemSoundID {
        var soundID: SystemSoundID = 0
        let soundURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), "audio.bar" as CFString, "mp3" as CFString, nil)
        AudioServicesCreateSystemSoundID(soundURL!, &soundID)
        return soundID
    }
    
    // MARK: Misc
	
	func lineUpdate()
	{
		lineNowDraw()
		lineThenDraw()
		lineInbetweensDraw()
	}
	
	func lineNowDraw()
	{
		let targetSeconds = (timeNow.hour! * 60 * 60) + (timeNow.minute! * 60) + timeNow.second!
		
		var positionY = (24-CGFloat(timeNow.hour!)) * templateLineSpacing * 4
		
		if timeNow.minute! >= 45 { positionY -= templateLineSpacing * 3  }
		else if timeNow.minute! >= 30 { positionY -= templateLineSpacing * 2  }
		else if timeNow.minute! >= 15 { positionY -= templateLineSpacing * 1  }
		
		let spaceToOccupy = screenWidth - (2 * tileSize)
		
		let percentGone = Float(targetSeconds % 900)/900
		var posWidth = CGFloat(percentGone) * spaceToOccupy
		
		var lineOrigin = CGFloat(percentGone) * spaceToOccupy
		var lineWidth = CGFloat(Int(gridView.frame.size.width-lineOrigin))
		
		let fromMinutePos = ((timeNow.minute! * 60) + timeNow.second!) % 900
		
		// Doesnt take the whole line
		if fromMinutePos + incrementMinutes < 900
		{
			let targetTimeThen = (timeThen.hour! * 60 * 60) + (timeThen.minute! * 60) + timeThen.second!
			
			let targetPercentGone = Float(targetTimeThen % 900)/900
			var targetPosWidth = CGFloat(targetPercentGone) * spaceToOccupy
			targetPosWidth = targetPosWidth - lineOrigin
			
			lineWidth = targetPosWidth
			pointTarget.isHidden = true
			
		}
		
		if lineWidth < 2 {
			lineWidth = 1
		}
        
        lineOrigin = CGFloat(Int(lineOrigin))

		pointNow.frame = CGRect(x: lineOrigin, y: positionY,width: lineWidth , height: 1)
        
        markerNow.backgroundColor = UIColor.gray
        markerNow.frame = CGRect(x: tileSize * 0.75 * -1, y: positionY, width: tileSize/2, height: 1)
	}
	
	func lineThenDraw()
	{
		// Draw Then
		
		let targetSeconds = (timeThen.hour! * 60 * 60) + (timeThen.minute! * 60) + timeThen.second!
		var positionY = (24-CGFloat(timeThen.hour!)) * templateLineSpacing * 4
		
		if timeThen.minute! > 44 { positionY -= templateLineSpacing * 3  }
		else if timeThen.minute! > 29 { positionY -= templateLineSpacing * 2  }
		else if timeThen.minute! > 14 { positionY -= templateLineSpacing * 1  }
		
		let spaceToOccupy = screenWidth - (2 * tileSize)
		
		let percentGone = Float(targetSeconds % 900)/900
		let posWidth = CGFloat(percentGone) * spaceToOccupy
		
		pointTarget.frame = CGRect(x: 0, y: positionY, width: posWidth, height: 1)
		pointTarget.isHidden = false
		
		if pointTarget.frame.origin.y == pointNow.frame.origin.y
		{
			pointTarget.isHidden = true
		}
        
        markerTarget.backgroundColor = UIColor.gray
        markerTarget.frame = CGRect(x: tileSize * 0.75 * -1, y: positionY, width: tileSize/2, height: 1)
	}
	
	func lineInbetweensDraw()
	{
		for view in gridView.subviews {
			if view.tag != 100 { continue }
			view.removeFromSuperview()
		}
		
		let numberOfLines = (pointNow.frame.origin.y - pointTarget.frame.origin.y)/templateLineSpacing
		
		var i = 0
		while i < Int(numberOfLines) - 1
		{
			let positionY = pointTarget.frame.origin.y + ( CGFloat(i+1) * templateLineSpacing)
			let lineView = UIView(frame: CGRect(x: 0.0, y: positionY, width: screenWidth-(2*tileSize), height: 1))
			lineView.backgroundColor = UIColor.white
			lineView.tag = 100
			self.gridView.addSubview(lineView)
			i = i + 1
		}
        
        if( Float(numberOfLines) != Float(lastLineCount) ){
            AudioServicesPlaySystemSound(barSound!)
        }
        
        lastLineCount = Float(numberOfLines)
		
		// If it goes over midnight
		if( numberOfLines < 0 ){
			
			// Lines above
			var limitLines = (24-CGFloat(timeNow.hour!)) * templateLineSpacing * 4
            
//            if timeNow.minute > 44 { limitLines = limitLines * 3 }
//            else if timeNow.minute > 29 { limitLines = limitLines * 2  }
//            else if timeNow.minute > 14 { limitLines = limitLines * 1  }
//            else { limitLines = limitLines * 4  }
            
			var i = 0
			while i < Int(limitLines)
			{
				let positionY = ((limitLines)) - ( CGFloat(1+i) * templateLineSpacing)
				
				let lineView = UIView(frame: CGRect(x: 0.0, y: positionY, width: screenWidth-(2*tileSize), height: 1))
				lineView.backgroundColor = UIColor.white
				lineView.tag = 100
				if( positionY > (-1 * templateLineSpacing) + templateLineSpacing ){
					self.gridView.addSubview(lineView)
				}
				
				i += 1
			}
			
			// Lines below for swift 3 need to do latter
			//limitLines = (24 * 4 ) - ( (24-CGFloat(timeThen.hour!)) * 4 )
            let a = 24 * 4
            let n = 24-CGFloat(timeThen.hour!)
            limitLines = CGFloat((a)) - ( (n) * 4 )
			i = 0
			while i < Int(24*4)
			{
				let positionY = ((24*4*templateLineSpacing)) - ( CGFloat(1+i) * templateLineSpacing)
				
				let lineView = UIView(frame: CGRect(x: 0.0, y: positionY, width: screenWidth-(2*tileSize), height: 1))
				lineView.backgroundColor = UIColor.white
				lineView.tag = 100
				if( positionY > pointTarget.frame.origin.y ){
					self.gridView.addSubview(lineView)
				}
				
				i += 1
			}
		}
		
	}
	
	func touchValuePerc(_ nowVal: Float,maxVal: Float) -> Float
	{
		var posValue = nowVal/maxVal
		
		if posValue > 1 { posValue = 1.0 }
		if posValue < 0 { posValue = 0.0 }
		
		return 1-posValue
	}
	
	// MARK: - Alarm
	
	func alarmSetup()
	{
		NSLog("! ALARM | Set: %d", incrementMinutes)
		
		UIApplication.shared.cancelAllLocalNotifications()
		
		let localNotification:UILocalNotification = UILocalNotification()
		localNotification.alertAction = "turn off the alarm"
		if( incrementMinutes % 2 == 0){
			localNotification.alertBody = "◉"
		}
		else{
			localNotification.alertBody = "◎"
		}
		let test:TimeInterval = TimeInterval(incrementMinutes)
		localNotification.fireDate = Date(timeIntervalSinceNow: test)
		localNotification.soundName = "alarm_tone.wav"
		UIApplication.shared.scheduleLocalNotification(localNotification)
		
		self.alarmLabel.text = "ALARM SET"
		self.alarmLabel.alpha = 1
		
		UIView.animate(withDuration: 1.0, delay: 1.5, options: .curveEaseOut, animations: { self.alarmLabel.alpha = 0 }, completion: { finished in print("") })
	}
	
	// MARK: - Misc
	
	override var prefersStatusBarHidden : Bool {
		return true
	}

}

