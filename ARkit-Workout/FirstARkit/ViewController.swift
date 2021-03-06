

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var leftBottomView: UIView!
    @IBOutlet weak var radarImageView: UIImageView!
    
    var aircraftNode = SCNNode()
    var changeDotX = CGFloat()
    var changeDotY = CGFloat()
    var angle = Float()
    var cameraNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        aircraftNode = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        sceneView.scene.rootNode.addChildNode(aircraftNode)
        
        //let scene = SCNScene(named: "art.scnassets/sci_fi5-sunnyrooftop-exp-minus1.8.usdz")!
        //scene.rootNode.childNode
        
        
        /* let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(gestureRecognize:)))
         view.addGestureRecognizer(tapGesture)*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
  
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        // AR Kameran??n d??n???? a????lar??n??n tan??mlanmas??, teknik ad??yla raw, pitch, yaw denilen euler a????lar??
        let cameraEulerAngle = sceneView.session.currentFrame?.camera.eulerAngles
        // AR Kameran??n konum ve d??n???? a????lar??n?? i??eren 4x4 float matristir. Konum bilgisine ula??man??n yolu transform matrisini elde etmekten ge??iyor veya sceneview.scene.pointOfView.position property den de ula????labilir konuma.
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraNode = SCNNode()
        // camera transform matrisi, 4x4 float matristir. Bu matriste 4. s??tunun ilk 3 eleman?? (columns.3  ile kodda belirtilen) koordinat bilgisini i??ermektedir.
        cameraNode.position = SCNVector3((cameraTransform?.columns.3.x ?? 0)!, (cameraTransform?.columns.3.y ?? 0)!, (cameraTransform?.columns.3.z ?? 0)!)
        
        aircraftNode.position = SCNVector3(0,0,-0.5)

        //3 boyutlu uzayda x-z d??zlemindeki hareketin, telefon ekran??nda x - y d??zleminde nereye kar????l??k geldi??i hesaplanm???? changeDotX, changeDotY de??i??kenlerine atanm????t??r. Bu hesab?? yaparken kullan??lan 150, Xcode da x ve y ekseninde 150x150 nokta ile temsil edilen radar imaj??n??n ??l????leridir. 3 ise 3 metre ??apta alan?? ifade etmektedir, gereksinime g??re de??i??tirilebilir.

        let changeDotX = ((((aircraftNode.position.x-cameraNode.position.x)*(150.0))/3.0))
        let changeDotY = ((((aircraftNode.position.z-cameraNode.position.z)*(150.0))/3.0))
        let positionAngle = atan2(changeDotY, changeDotX) // changeDotY ve changeDotX de??i??kenlerinin bir dik ????geni olu??turan kenarlar oldu??u d??????n??l??rse kar????/kom??u nun arctanjant?? ile telefonun modele g??re konum a????s?? hesaplanm????t??r.
        let rotationAngle = cameraEulerAngle?.y ?? 0 // Kameran??n kendi ekseni etraf??nda d??n???? a????s??n??n (pitch) hesaplanmas?? ve tan??mlanmas??
        let angle = positionAngle + rotationAngle // Telefonun hem nesne etraf??nda d??nmesi(position) hem de kendi ekseni etraf??nda(rotation) d??nmesi ile olu??an a????sal de??i??imin tan??m??
        
        // Bu k??s??m  x-y d??zlemindeki hareketin yar????ap ve a???? cinsinden hesab??n?? tarifler. Radardaki nokta g??r??nt??s??n??n bulundu??u merkezden itibaren ne kadarl??k yar????apta hareket etti??i tan??mlanm????t??r.
        
        let radius = CGFloat(sqrtf(powf(Float(changeDotX), 2.0)+powf(Float(changeDotY), 2.0)))
       
    
        // A????s?? ve yar????ap?? bilinen hareketin x ve y eksenlerindeki bile??enlerinin hesaplanmas??
        
        let componentY = radius * sin(CGFloat(angle))
        let componentX = radius * cos(CGFloat(angle))
        
        
        DispatchQueue.main.async { [self] in
            
            // x ve y eksenindeki g??rsel hareketin matematiksel hesab??
            
            dotImageView.center.x = radarImageView.center.x + componentX
            dotImageView.center.y = radarImageView.center.y + componentY
            
        }
        
    }
    
}



