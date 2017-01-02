//
//  Game.swift
//  BoutTime
//
//  Created by Dan on 12/27/16.
//  Copyright © 2016 sypho. All rights reserved.
//

import GameKit
import Foundation
import AudioToolbox

struct Event: Equatable {
    let description: String
    let year: Int
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        if lhs.description == rhs.description && lhs.year == rhs.year {
            return true
        }
        return false
    }
}

enum MoveDirection {
    case up, down
}

enum GameError: Error {
    case eventsError
    case invalidResource
    case conversionFailure
}

enum AnswerSwitch {
    case firstSecond
    case secondThird
    case thirdFourth
}

class PlistConverter {
    static func dictionary(fromFile name: String, ofType type: String) throws -> [String: Int] {
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw GameError.invalidResource
        }
        
        guard let dictionary = NSDictionary(contentsOfFile: path) as? [String: Int] else {
            throw GameError.conversionFailure
        }
        
        return dictionary
    }
}

class DictionaryConverter {
    static func eventsArray(fromDictionary dictionary: [String: Int]) -> [Event] {
        var eventsArray: [Event] = []
        
        for (key, value) in dictionary {
            eventsArray.append(Event(description: key, year: value))
        }
        
        return eventsArray
    }
}

class GameSounds {
    var correctSound: SystemSoundID = 0
    var incorrectSound: SystemSoundID = 0
    
    // Locate sound files and bind them to variables
    init() {
        
        let pathToCorrectSoundFile = Bundle.main.path(forResource: "CorrectDing", ofType: "wav")
        let correctSoundURL = URL(fileURLWithPath: pathToCorrectSoundFile!)
        AudioServicesCreateSystemSoundID(correctSoundURL as CFURL, &correctSound)
        
        let pathToIncorrectSoundFile = Bundle.main.path(forResource: "IncorrectBuzz", ofType: "wav")
        let incorrectSoundURL = URL(fileURLWithPath: pathToIncorrectSoundFile!)
        AudioServicesCreateSystemSoundID(incorrectSoundURL as CFURL, &incorrectSound)
        
    }
    
    // Play sounds (Game start, Correct answer, Incorrect answer, Timeout)
    func playCorrectSound() {
        AudioServicesPlaySystemSound(correctSound)
    }
    
    func playIncorrectSound() {
        AudioServicesPlaySystemSound(incorrectSound)
    }
}

class Game {
    
    let events: [Event]
    let timerCountdown = 60
    let roundsPerGame = 6
    var currectRoundEvents: [Event]?
    var currentRound = 0
    var totalScore = 0
    let sounds = GameSounds()
    
    init(eventsArray events: [Event]) {
        self.events = events
    }
    
    func startRound() throws -> [Event] {
        if isOver() {
            currentRound = 1
            totalScore = 0
        } else {
            currentRound += 1
        }
        var currectRoundEvents: [Event] = []
        var randEvent: Event
        repeat {
            repeat {
                randEvent = events[GKRandomSource.sharedRandom().nextInt(upperBound: events.count)]
            } while currectRoundEvents.contains(randEvent)
            currectRoundEvents.append(randEvent)
        } while currectRoundEvents.count < 4
        self.currectRoundEvents = currectRoundEvents
        return currectRoundEvents
    }
    
    func switchAnswer(_ answerSwitch: AnswerSwitch) throws {
        if var currectRoundEvents = currectRoundEvents {
            var temp: Event
            switch answerSwitch {
            case .firstSecond:
                temp = currectRoundEvents[0]
                currectRoundEvents[0] = currectRoundEvents[1]
                currectRoundEvents[1] = temp
            case .secondThird:
                temp = currectRoundEvents[1]
                currectRoundEvents[1] = currectRoundEvents[2]
                currectRoundEvents[2] = temp
            case .thirdFourth:
                temp = currectRoundEvents[2]
                currectRoundEvents[2] = currectRoundEvents[3]
                currectRoundEvents[3] = temp
            }
            self.currectRoundEvents = currectRoundEvents
        } else {
            // FIXME: Error handling
            throw GameError.eventsError
        }
    }
    
    func checkAnswer() throws -> Bool {
        if let currectRoundEvents = currectRoundEvents {
            var lastEvent: Event?
            for event in currectRoundEvents {
                if let lastEvent = lastEvent {
                    if event.year < lastEvent.year {
                        return false
                    }
                } else {
                    lastEvent = event
                }
            }
            totalScore += 1
            return true
        } else {
            // FIXME: Error handling
            throw GameError.eventsError
        }
    }
    
    func isOver() -> Bool {
        if currentRound == roundsPerGame {
            return true
        }
        return false
    }
    
}
