//
//  ViewController.swift
//  PlayingCard
//
//  Created by Victor Smirnov on 03.02.2020.
//  Copyright © 2020 Victor Smirnov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    @IBOutlet var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            guard let card = deck.draw() else { return }
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden }
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 && faceUpCardViews[0].rank == faceUpCardViews[1].rank && faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            guard let chosenCardView = recognizer.view as? PlayingCardView else { return }
            lastChosenCardView = chosenCardView
            cardBehavior.removeItem(chosenCardView)
            UIView.transition(
                with: chosenCardView,
                duration: 0.4,
                options: [.transitionFlipFromLeft],
                animations: {
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
            },
                completion: { finished in
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(
                            withDuration: 0.6,
                            delay: 0,
                            options: [],
                            animations: {
                                self.faceUpCardViews.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 2.0, y: 2.0)
                                }
                        },
                            completion: { position in
                                UIViewPropertyAnimator.runningPropertyAnimator(
                                    withDuration: 0.75,
                                    delay: 0,
                                    options: [],
                                    animations: {
                                        self.faceUpCardViews.forEach {
                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                            $0.alpha = 0
                                        }
                                },
                                    completion: { position in
                                        self.faceUpCardViews.forEach {
                                            $0.isHidden = true
                                            $0.alpha = 1
                                            $0.transform = .identity
                                        }
                                })
                        })
                    } else if self.faceUpCardViews.count == 2 {
                        if chosenCardView == self.lastChosenCardView {
                            self.faceUpCardViews.forEach { cardView in
                                UIView.transition(
                                    with: cardView,
                                    duration: 0.4,
                                    options: [.transitionFlipFromLeft],
                                    animations: {
                                        cardView.isFaceUp = false
                                },
                                    completion: { finished in
                                        self.cardBehavior.addItem(cardView)
                                })
                            }
                        }
                    } else {
                        if !chosenCardView.isFaceUp {
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
            })
        default:
            break
        }
    }
    
    
}

