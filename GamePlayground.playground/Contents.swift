import SpriteKit
import PlaygroundSupport

class MainScene: SKScene {
  var player: SKSpriteNode?
  let numMonsters = 10
  var turns = 0
  var turnsLabel: SKLabelNode?
  
  struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
  }
  
  override public func didMove(to view: SKView) {
    super.didMove(to: view)
    self.backgroundColor = .white
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
    addTurnsLabel()
    addPlayer()
    for _ in 1..<numMonsters {
      addMonster()
    }
  }
  
  func addTurnsLabel() {
    let label = SKLabelNode(fontNamed: "Chalkduster")
    label.text = "Start"
    label.fontSize = 40
    label.fontColor = SKColor.black
    label.position = CGPoint(x: self.size.width / 2, y: self.size.height - 40)
    addChild(label)
    self.turnsLabel = label
  }
  
  func addPlayer() {
    let player = SKSpriteNode(imageNamed: "player")
    player.position = CGPoint(x: self.size.width / 2, y: self.size.height - 75)
    let physicsBody = SKPhysicsBody(rectangleOf: player.size)
    projectilePhysics(physicsBody)
    player.physicsBody = physicsBody
    addChild(player)
    self.player = player
  }
  
  func addMonster() {
    let monster = SKSpriteNode(imageNamed: "monster")
    let x = random(min: 0, max: CGFloat(self.size.width))
    let y = random(min: 0, max: CGFloat(self.size.height) - 125)
    monster.position = CGPoint(x: x, y: y)
    let physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
    monsterPhysics(physicsBody)
    monster.physicsBody = physicsBody
    addChild(monster)
  }
  
  func projectilePhysics(_ physicsBody: SKPhysicsBody) {
    physicsBody.isDynamic = true
    physicsBody.categoryBitMask = PhysicsCategory.Projectile
    physicsBody.contactTestBitMask = PhysicsCategory.Monster
    physicsBody.collisionBitMask = PhysicsCategory.None
    physicsBody.usesPreciseCollisionDetection = true
  }
  
  func monsterPhysics(_ physicsBody: SKPhysicsBody) {
    physicsBody.isDynamic = true
    physicsBody.categoryBitMask = PhysicsCategory.Monster
    physicsBody.contactTestBitMask = PhysicsCategory.Projectile
    physicsBody.collisionBitMask = PhysicsCategory.None
  }
  
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    let location = touches.first!.location(in: self)
    let actionMove = SKAction.move(to: location, duration: 1.0)
    self.player!.run(actionMove)
    self.turns += 1
    self.turnsLabel?.text = "Turn \(self.turns)"
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
  
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
}

extension MainScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
      (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode, let
        projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("Hit")
    monster.removeFromParent()
  }
}


let size = CGSize(width: 500, height: 500)
let scene = MainScene(size: size)
let view = SKView(frame: CGRect(origin: CGPoint.zero, size: size))
view.presentScene(scene)
PlaygroundPage.current.liveView = view

