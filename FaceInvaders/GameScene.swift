//
//  FaceInvaders
//
//  Created by Carlos Bueno on 24/09/16.
//  Copyright (c) 2016 Sennit. All rights reserved.
//

import SpriteKit
import CoreMotion
import CoreData

@available(iOS 10.0, *)
class GameScene: SKScene, SKPhysicsContactDelegate {
  
	fileprivate var friendList:Array<Friends> = []
	fileprivate var friendsAPI: FriendsAPI!
    var gameBegim: Bool = false;
	let kMinInvaderBottomHeight: Float = 32.0
	var gameEnding: Bool = false
	var gameLevel: Int = 1
	var score: Int = 0
	var shipHealth: Float = 1.0

  var contactQueue = [SKPhysicsContact]()
  
  let kInvaderCategory: UInt32 = 0x1 << 0
  let kShipFiredBulletCategory: UInt32 = 0x1 << 1
  let kShipCategory: UInt32 = 0x1 << 2
  let kSceneEdgeCategory: UInt32 = 0x1 << 3
  let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4

  enum BulletType {
    case shipFired
    case invaderFired
  }
  
  let kShipFiredBulletName = "shipFiredBullet"
  let kInvaderFiredBulletName = "invaderFiredBullet"
  let kBulletSize = CGSize(width:4, height: 8)

  var tapQueue = [Int]()
  
  let motionManager: CMMotionManager = CMMotionManager()
 
  var contentCreated = false
  
  // 1
  var invaderMovementDirection: InvaderMovementDirection = .right
  // 2
  var timeOfLastMove: CFTimeInterval = 0.0
  // 3
  var timePerMove: CFTimeInterval = 1.0
  
  enum InvaderMovementDirection {
    case right
    case left
    case downThenRight
    case downThenLeft
    case none
  }

  enum InvaderType {
    case a
    case b
    case c
    
    static var size: CGSize {
      return CGSize(width: 24, height: 24)
    }
    
    static var name: String {
      return "invader"
    }
  }
  
  let kInvaderGridSpacing = CGSize(width: 12, height: 12)
  var kInvaderRowCount = 1
  var kInvaderColCount = 4
  
  let kShipSize = CGSize(width: 30, height: 24)
  let kShipName = "ship"
  
  let kScoreHudName = "scoreHud"
  let kHealthHudName = "healthHud"
  let kHealthUserName = "userHud"
 
  override func didMove(to view: SKView) {
     self.friendsAPI = FriendsAPI.sharedInstance
    
       
    if (!self.contentCreated) {
      self.createContent()
      self.contentCreated = true
      motionManager.startAccelerometerUpdates()
    }
    
    physicsWorld.contactDelegate = self
  }
  
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: 24))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: 24))
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
 
    
    
   
  
  func createContent() {
	

	self.friendList = self.friendsAPI.getAllFriends()
	if(self.friendList.count > 0){
		var pictureArray = [String]()
		
		self.setupInvaders(pictureArray: pictureArray)
		self.setupShip()
		self.setupHud()
	}else{
		let fbRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: nil)
		fbRequest.start(completionHandler: { (connection, result, error) -> Void in
			if ((error) != nil)
			{
			}
			else
			{
				
				
				
				var pictureArray = [String]()
				
				let resultdict = result as! NSDictionary
				let data : NSArray = resultdict.object(forKey: "data") as! NSArray
				
				for i in 0..<data.count {
					let valueDict : NSDictionary = data[i] as! NSDictionary
					
					let pictureDict = valueDict.object(forKey: "picture") as! NSDictionary
					let pictureData = pictureDict.object(forKey: "data") as! NSDictionary
					let pictureURL = pictureData.object(forKey: "url") as! String
					
					pictureArray.append(pictureURL)
				}
				
				self.setupInvaders(pictureArray: pictureArray)
				self.setupShip()
				self.setupHud()
				
				
			}
			
		})
	
	}
	
	
    physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    physicsBody!.categoryBitMask = kSceneEdgeCategory
	
	
	
    self.backgroundColor = SKColor.black
  }
	
	
	
	
	func getProfilePic(fid: String) -> [SKTexture] {
 
               let url = NSURL(string: fid)
        let data = NSData(contentsOf: url! as URL)
		var retrievedEvents:[Dictionary<String,AnyObject>] = []
		
		var eventItem:Dictionary<String, AnyObject> = [:];
		
		eventItem[FriendsAttributes.id.rawValue] = "1" as AnyObject?
		
		//Generate event UUID
		eventItem[FriendsAttributes.image.rawValue] = data as NSData?
		
		retrievedEvents.append(eventItem)
		
		
		//Call Event API to persist Event list to Datastore
		self.friendsAPI.saveFriendsList(retrievedEvents as Array<AnyObject>)
        let imageUI =  UIImage(data: data! as Data)
        let image = SKTexture(image: resizeImage(image: imageUI!, newWidth: 24))
                return [image]
    }

   

	
	func makeInvaderOfType(_ invaderType: InvaderType, id: Int ) -> SKNode {
		
		
		
		
		
		
		let imageUI =  UIImage(data: self.friendList[id].image as Data)
		let image = SKTexture(image: resizeImage(image: imageUI!, newWidth: 24))
	
		

		let invader = SKSpriteNode(texture: image)
		invader.name = InvaderType.name
		invader.run(SKAction.repeatForever(SKAction.animate(with: [image], timePerFrame: timePerMove)))
		invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
		invader.physicsBody!.isDynamic = false
		invader.physicsBody!.categoryBitMask = kInvaderCategory
		invader.physicsBody!.contactTestBitMask = 0x0
		invader.physicsBody!.collisionBitMask = 0x0
		
		return invader
	}
	
    func makeInvaderOfType(_ invaderType: InvaderType, userId: String ) -> SKNode {
		
		let invaderTextures = getProfilePic(fid: userId)
		
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = InvaderType.name
        invader.run(SKAction.repeatForever(SKAction.animate(with: invaderTextures, timePerFrame: timePerMove)))
        invader.physicsBody = SKPhysicsBody(rectangleOf: invader.frame.size)
        invader.physicsBody!.isDynamic = false
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0
      
        return invader
    }
  
  func setupInvaders(pictureArray: [String]) {
    
    

    let baseOrigin = CGPoint(x: size.width / 3, y: size.height / 2)
   var contador = 0;
    for row in 0..<kInvaderRowCount {
   
      var invaderType: InvaderType
   
      if row % 3 == 0 {
        invaderType = .a
      } else if row % 3 == 1 {
        invaderType = .b
      } else {
        invaderType = .c
      }
   
    
      let invaderPositionY = CGFloat(row) * ((InvaderType.size.height * 4)/3) + baseOrigin.y
   
      var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
   
        
      
      
        contador = kInvaderColCount*row;
        if (contador > 17){
            contador = 5;
        }
        
        
        for col in 1...kInvaderColCount {
			
			let invader: SKNode ;
			if(self.friendList.count > 0){
				
			    invader = self.makeInvaderOfType(invaderType, id: col+contador)
				
			}else {
				
				invader = self.makeInvaderOfType(invaderType, userId: pictureArray[col+contador])

			}
            print("contador \(col+contador)")
			
            
            invader.position = invaderPosition
            
            self.addChild(invader)
            
            
            print("tamanho 1 \(InvaderType.size.width)")
            
            print("tamanho 2 \(self.kInvaderGridSpacing.width)")
            
            print("tamanho 3 \(invaderPosition.x)")
            
            invaderPosition = CGPoint(
                x: invaderPosition.x + InvaderType.size.width + self.kInvaderGridSpacing.width,
                y: invaderPositionY
            )
            
            self.gameBegim = true
            
          
         
        
        
        
   
      
      }
        
    }
  }
  
  func setupShip() {
    // 1
    let ship = makeShip()
   
    // 2
    ship.position = CGPoint(x: size.width / 2.0, y: kShipSize.height / 2.0)
    addChild(ship)
  }
   
  func makeShip() -> SKNode {
    let ship = SKSpriteNode(imageNamed: "Ship.png")
    ship.name = kShipName
    
    // 1
    ship.physicsBody = SKPhysicsBody(rectangleOf: ship.frame.size)
     
    // 2
    ship.physicsBody!.isDynamic = true
     
    // 3
    ship.physicsBody!.affectedByGravity = false
     
    // 4
    ship.physicsBody!.mass = 0.02
    
    // 1
    ship.physicsBody!.categoryBitMask = kShipCategory
    // 2
    ship.physicsBody!.contactTestBitMask = 0x0
    // 3
    ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
    
    return ship
  }
  
  func setupHud() {

    
    let usernameLabel = SKLabelNode(fontNamed: "Courier")
    usernameLabel.name = kHealthUserName
    usernameLabel.fontSize = 15
    
    
    let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
    graphRequest.start(completionHandler: { (connection, result, error) -> Void in
        
        
        
        
        if ((error) != nil)
        {
        }
        else
        {
            if let user : NSString = (result! as AnyObject).value(forKey: "name") as? NSString {
                //print("user2: \(user)")
                usernameLabel.text = String(format: "\(user)", 0)
            }
            
            
        }
    })
    
    usernameLabel.fontColor = SKColor.white
    
    
    
    
    
    // 3
    usernameLabel.position = CGPoint(
        x: 75,
        y: size.height - (25 + usernameLabel.frame.size.height/2)
    )
    
    
        addChild(usernameLabel)
    
    // 1
    let scoreLabel = SKLabelNode(fontNamed: "Courier")
    scoreLabel.name = kScoreHudName
    scoreLabel.fontSize = 15
   
    // 2
    scoreLabel.fontColor = SKColor.green
    
   
    
   
    // 3
    scoreLabel.position = CGPoint(
      x: 60,
      y: size.height - (45 + scoreLabel.frame.size.height/2)
    )
    addChild(scoreLabel)
   
    // 4
    let healthLabel = SKLabelNode(fontNamed: "Courier")
    healthLabel.name = kHealthHudName
    healthLabel.fontSize = 15
   
    // 5
    healthLabel.fontColor = SKColor.red
    healthLabel.text = String(format: "Energia: %.1f%%", shipHealth * 100.0)
   
    // 6
    healthLabel.position = CGPoint(
      x: 60,
      y: size.height - (65 + healthLabel.frame.size.height/2)
    )
    addChild(healthLabel)
  }
  
  func adjustScoreBy(_ points: Int) {
    score += points
   
    if let score = childNode(withName: kScoreHudName) as? SKLabelNode {
      score.text = String(format: "Pontos: %04u", self.score)
    }
  }
   
  func adjustShipHealthBy(_ healthAdjustment: Float) {
    // 1
    shipHealth = max(shipHealth + healthAdjustment, 0)
   
    if let health = childNode(withName: kHealthHudName) as? SKLabelNode {
      health.text = String(format: "Energia: %.1f%%", self.shipHealth * 100)
    }
  }
  
  func makeBulletOfType(_ bulletType: BulletType) -> SKNode {
    var bullet: SKNode
   
    switch bulletType {
    case .shipFired:
      bullet = SKSpriteNode(color: SKColor.green, size: kBulletSize)
      bullet.name = kShipFiredBulletName
      
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = kInvaderCategory
      bullet.physicsBody!.collisionBitMask = 0x0
      
    case .invaderFired:
      bullet = SKSpriteNode(color: SKColor.magenta, size: kBulletSize)
      bullet.name = kInvaderFiredBulletName
      
      bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.frame.size)
      bullet.physicsBody!.isDynamic = true
      bullet.physicsBody!.affectedByGravity = false
      bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
      bullet.physicsBody!.contactTestBitMask = kShipCategory
      bullet.physicsBody!.collisionBitMask = 0x0
      
      break
    }
   
    return bullet
  }
  
  // Scene Update
  
  override func update(_ currentTime: TimeInterval) {
    /* Called before each frame is rendered */
    if isGameOver() {
      endGame()
    }
	
	if isNextLevel(){
		nextLevel()
	}
    processContactsForUpdate(currentTime)
    processUserMotionForUpdate(currentTime)
    moveInvadersForUpdate(currentTime)
    processUserTapsForUpdate(currentTime)
    fireInvaderBulletsForUpdate(currentTime)
  }
  
  func moveInvadersForUpdate(_ currentTime: CFTimeInterval) {
    // 1
    if (currentTime - timeOfLastMove < timePerMove) {
      return
    }
    
    determineInvaderMovementDirection()
   
    // 2
    enumerateChildNodes(withName: InvaderType.name) {
      node, stop in
   
      switch self.invaderMovementDirection {
      case .right:
        node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
      case .left:
        node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
      case .downThenLeft, .downThenRight:
        node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
      case .none:
        break
      }
   
      // 3
      self.timeOfLastMove = currentTime
    }
  }
  
  func adjustInvaderMovementToTimePerMove(_ newTimerPerMove: CFTimeInterval) {
    // 1
    if newTimerPerMove <= 0 {
      return
    }
   
    // 2
    let ratio: CGFloat = CGFloat(timePerMove / newTimerPerMove)
    timePerMove = newTimerPerMove
   
    // 3
    enumerateChildNodes(withName: InvaderType.name) {
      node, stop in
      node.speed = node.speed * ratio
    }
  }
  
  func processUserMotionForUpdate(_ currentTime: CFTimeInterval) {
    // 1
    if let ship = childNode(withName: kShipName) as? SKSpriteNode {
      // 2
      if let data = motionManager.accelerometerData {
        // 3
        if fabs(data.acceleration.x) > 0.2 {
          // 4 How do you move the ship?
          ship.physicsBody!.applyForce(CGVector(dx: 40.0 * CGFloat(data.acceleration.x), dy: 0))
        }
      }
    }
  }
  
  // Scene Update Helpers
  func processUserTapsForUpdate(_ currentTime: CFTimeInterval) {
    // 1
    for tapCount in tapQueue {
      if tapCount == 1 {
        // 2
        fireShipBullets()
      }
      // 3
      tapQueue.remove(at: 0)
    }
  }
  
  // Invader Movement Helpers
  func determineInvaderMovementDirection() {
    // 1
    var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
   
    // 2
    enumerateChildNodes(withName: InvaderType.name) {
      node, stop in
   
      switch self.invaderMovementDirection {
        case .right:
          //3
          if (node.frame.maxX >= node.scene!.size.width - 1.0) {
            proposedMovementDirection = .downThenLeft
         
            // Add the following line
            self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
         
            stop.pointee = true
          }
        case .left:
          //4
          if (node.frame.minX <= 1.0) {
            proposedMovementDirection = .downThenRight
         
            // Add the following line
            self.adjustInvaderMovementToTimePerMove(self.timePerMove * 0.8)
         
            stop.pointee = true
          }
   
      case .downThenLeft:
        proposedMovementDirection = .left
   
        stop.pointee = true
   
      case .downThenRight:
        proposedMovementDirection = .right
   
        stop.pointee = true
   
      default:
        break
      }
   
    }
   
    //7
    if (proposedMovementDirection != invaderMovementDirection) {
      invaderMovementDirection = proposedMovementDirection
    }
  }
  
  func fireInvaderBulletsForUpdate(_ currentTime: CFTimeInterval) {
    let existingBullet = childNode(withName: kInvaderFiredBulletName)
   
    // 1
    if existingBullet == nil {
      var allInvaders = Array<SKNode>()
   
      // 2
      enumerateChildNodes(withName: InvaderType.name) {
        node, stop in
   
        allInvaders.append(node)
      }
   
      if allInvaders.count > 0 {
        // 3
        let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
   
        let invader = allInvaders[allInvadersIndex]
   
        // 4
        let bullet = makeBulletOfType(.invaderFired)
        bullet.position = CGPoint(
          x: invader.position.x,
          y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
        )
   
        // 5
        let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
   
        // 6
        fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
      }
    }
  }
  
  // Bullet Helpers
  func fireBullet(_ bullet: SKNode, toDestination destination: CGPoint, withDuration duration: CFTimeInterval, andSoundFileName soundName: String) {
    // 1
    let bulletAction = SKAction.sequence([
      SKAction.move(to: destination, duration: duration),
      SKAction.wait(forDuration: 3.0 / 60.0), SKAction.removeFromParent()
    ])
    
    // 2
    let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
    
    // 3
    bullet.run(SKAction.group([bulletAction, soundAction]))
    
    // 4
    addChild(bullet)
  }

  func fireShipBullets() {
    let existingBullet = childNode(withName: kShipFiredBulletName)
    
    // 1
    if existingBullet == nil {
      if let ship = childNode(withName: kShipName) {
        let bullet = makeBulletOfType(.shipFired)
          // 2
          bullet.position = CGPoint(
            x: ship.position.x,
            y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
        )
        // 3
        let bulletDestination = CGPoint(
          x: ship.position.x,
          y: frame.size.height + bullet.frame.size.height / 2
        )
        // 4
        fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
      }
    }
  }
  
  func processContactsForUpdate(_ currentTime: CFTimeInterval) {
    for contact in contactQueue {
      handleContact(contact)
   
      if let index = contactQueue.index(of: contact) {
        contactQueue.remove(at: index)
      }
    }
  }


  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      if (touch.tapCount == 1) {
        tapQueue.append(1)
      }
    }
  }
  


  func didBegin(_ contact: SKPhysicsContact) {
    contactQueue.append(contact)
  }
  
  func handleContact(_ contact: SKPhysicsContact) {

    if contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil {
      return
    }
   
    let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
   
    if nodeNames.contains(kShipName) && nodeNames.contains(kInvaderFiredBulletName) {
     
      run(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
   
      // 1
      adjustShipHealthBy(-0.334)
   
      if shipHealth <= 0.0 {
        // 2
        contact.bodyA.node!.removeFromParent()
        contact.bodyB.node!.removeFromParent()
      } else {
        // 3
        if let ship = self.childNode(withName: kShipName) {
          ship.alpha = CGFloat(shipHealth)
   
          if contact.bodyA.node == ship {
            contact.bodyB.node!.removeFromParent()
   
          } else {
            contact.bodyA.node!.removeFromParent()
          }
        }
      }
   
    } else if nodeNames.contains(InvaderType.name) && nodeNames.contains(kShipFiredBulletName) {
    
      run(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
      contact.bodyA.node!.removeFromParent()
      contact.bodyB.node!.removeFromParent()
   
      // 4
      adjustScoreBy(100)
    }
  }
  
  func isGameOver() -> Bool {

    var invaderTooLow = false
   
    enumerateChildNodes(withName: InvaderType.name) {
      node, stop in
   
      if (Float(node.frame.minY) <= self.kMinInvaderBottomHeight)   {
        invaderTooLow = true
        stop.pointee = true
      }
    }
   
    // 3
    let ship = childNode(withName: kShipName)
 
    // 4
    return  ( invaderTooLow || ship == nil ) && gameBegim
  }
	
	func isNextLevel() -> Bool {
		// 1
		let invader = childNode(withName: InvaderType.name)
		
		
		
		// 4
		return  (invader == nil ) && gameBegim
	}
	
  func endGame() {
    // 1
    if !gameEnding {
   
      gameEnding = true
   
      // 2
      motionManager.stopAccelerometerUpdates()
   
      // 3
      let gameOverScene: GameOverScene = GameOverScene(size: size)
   
      view?.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
    }
  }
  
	func nextLevel() {
		// 1
		if !gameEnding {
   
			if(gameLevel > 7)
			{
				endGame()
				
			}
			
			gameEnding = true
   
			// 2
			motionManager.stopAccelerometerUpdates()
   
			// 3
			let nextLevelScene: NextLevelScene = NextLevelScene(size: size)
			nextLevelScene.level = gameLevel + 1;
			nextLevelScene.pontos = score;
			print("Level:  \(nextLevelScene.level)")
			view?.presentScene(nextLevelScene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
		}
	}
	
}
