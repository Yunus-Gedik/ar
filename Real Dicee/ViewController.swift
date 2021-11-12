import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var onFieldDices = [SCNNode]();
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show work of arkit as yellow points to detect
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        
// BEGIN OF STATIONARY OBJECT PLACEMENT
        // Create sphere
        let sphere = SCNSphere(radius: 0.2)

        let material = SCNMaterial()

        material.diffuse.contents = UIImage(named: "art.scnassets/jupiter.jpeg")

        // Wrap sphere with moon image
        sphere.materials = [material]

        let node = SCNNode()

        // Create Node at position(0,0.1,-0.5)
        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)

        // assign moon sphere to position(node)
        node.geometry = sphere

        // add node to scene
        sceneView.scene.rootNode.addChildNode(node)

        // Give 3d like effect by using lighting
        sceneView.autoenablesDefaultLighting = true
// END OF STATIONARY OBJECT PLACEMENT
        
// INSERT IMAGE BEGIN
        let imageHolder = SCNNode(geometry: SCNPlane(width: 0.08, height: 0.08))

        //imageHolder.eulerAngles.x = -.pi/2

        imageHolder.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/greenart.jpeg");

        sceneView.scene.rootNode.addChildNode(imageHolder)
// INSERT IMAGE END
        
// INSERT VIDEO START

        let videoNode = SKVideoNode(fileNamed: "video.mp4")
                    
        videoNode.play()
         
        
        let videoScene = SKScene(size: CGSize(width: 480, height: 360))
        
        
        videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        
        videoNode.yScale = -1.0
        
        videoScene.addChild(videoNode)
        
        
        
        
// INSERT VIDEO END
        
// TEXT
        // Create text
        let text = SCNText(string: "YUNUS", extrusionDepth: 1)
        text.firstMaterial?.diffuse.contents = UIColor.yellow
        
        // Create node
        
        let textNode = SCNNode(geometry: text)
        
        
        textNode.position = SCNVector3(-0.1, -0.1, -0.1)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
// END TEXT
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Finde horizontal surfaces and place it.
        configuration.planeDetection = .horizontal
        
        // Fetch config to scene
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {

                // Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z
                    )

                    onFieldDices.append(diceNode)
                    
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    rollDice(diceNode)

                }
                
            }
            
        }
    }

    // roll all dices created by user
    @IBAction func rollAllClicked(_ sender: UIBarButtonItem) {
        for dice in onFieldDices{
            rollDice(dice)
        }
    }
    
    // delete all dices created by user
    @IBAction func clearSceneClicked(_ sender: UIBarButtonItem) {
        for dice in onFieldDices{
            dice.removeFromParentNode()
        }
    }
    
    
    
    func rollDice(_ dice: SCNNode){
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        //        let randomY = Double((arc4random_uniform(10) + 11)) * (Double.pi/2)
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.6))
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if anchor is ARPlaneAnchor {
            
            print("plane detected")
            
            let planeAnchor = anchor as! ARPlaneAnchor

            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            
            let planeNode = SCNNode()

            planeNode.geometry = plane
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            node.addChildNode(planeNode)
            
        } else {
            return
        }
        
        //guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
    }


}
