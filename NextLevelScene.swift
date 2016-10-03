

import UIKit
import SpriteKit
import CoreData

class NextLevelScene: SKScene {
	
	
	
	var contentCreated = false
	
	var level  = 0
	var pontos  = 0
	override func didMove(to view: SKView) {
		
		if (!self.contentCreated) {
			self.createContent()
			self.contentCreated = true
		}
	}
	
	func createContent() {
		
		let gameOverLabel = SKLabelNode(fontNamed: "Courier")
		gameOverLabel.fontSize = 48
		gameOverLabel.fontColor = SKColor.white
		gameOverLabel.text = "Next Level!"
		gameOverLabel.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.0 * self.size.height);
		
		self.addChild(gameOverLabel)
		
		let tapLabel = SKLabelNode(fontNamed: "Courier")
		tapLabel.fontSize = 13
		tapLabel.fontColor = SKColor.white
		tapLabel.text = "(Toque para jogar o proximo nivel)"
		tapLabel.position = CGPoint(x: self.size.width/2, y: gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
		
		self.addChild(tapLabel)
		
		
		self.backgroundColor = SKColor.black
		
	}
	
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)  {
		
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
		
		let gameScene = GameScene(size: self.size)
		
		
		
		gameScene.scaleMode = .aspectFill
		if(level == 2){
			gameScene.kInvaderRowCount = 1
			gameScene.kInvaderColCount = 6
			
		}
		if(level == 3){
			gameScene.kInvaderRowCount = 2
			gameScene.kInvaderColCount = 6
			
		}
		if(level == 4){
			gameScene.kInvaderRowCount = 3
			gameScene.kInvaderColCount = 6
			
		}
		if(level == 5){
			gameScene.kInvaderRowCount = 4
			gameScene.kInvaderColCount = 6
			
		}
		if(level == 6){
			gameScene.kInvaderRowCount = 5
			gameScene.kInvaderColCount = 6
			
		}
		if(level == 7){
			gameScene.kInvaderRowCount = 6
			gameScene.kInvaderColCount = 6
			
		}
		gameScene.gameLevel = self.level
		
		gameScene.score = self.pontos
		
		
		self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
		
	}
}
