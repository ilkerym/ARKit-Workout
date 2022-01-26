

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
        
        // AR Kameranın dönüş açılarının tanımlanması, teknik adıyla raw, pitch, yaw denilen euler açıları
        let cameraEulerAngle = sceneView.session.currentFrame?.camera.eulerAngles
        // AR Kameranın konum ve dönüş açılarını içeren 4x4 float matristir. Konum bilgisine ulaşmanın yolu transform matrisini elde etmekten geçiyor veya sceneview.scene.pointOfView.position property den de ulaşılabilir konuma.
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraNode = SCNNode()
        // camera transform matrisi, 4x4 float matristir. Bu matriste 4. sütunun ilk 3 elemanı (columns.3  ile kodda belirtilen) koordinat bilgisini içermektedir.
        cameraNode.position = SCNVector3((cameraTransform?.columns.3.x ?? 0)!, (cameraTransform?.columns.3.y ?? 0)!, (cameraTransform?.columns.3.z ?? 0)!)
        
        aircraftNode.position = SCNVector3(0,0,-0.5)

        //3 boyutlu uzayda x-z düzlemindeki hareketin, telefon ekranında x - y düzleminde nereye karşılık geldiği hesaplanmış changeDotX, changeDotY değişkenlerine atanmıştır. Bu hesabı yaparken kullanılan 150, Xcode da x ve y ekseninde 150x150 nokta ile temsil edilen radar imajının ölçüleridir. 3 ise 3 metre çapta alanı ifade etmektedir, gereksinime göre değiştirilebilir.

        let changeDotX = ((((aircraftNode.position.x-cameraNode.position.x)*(150.0))/3.0))
        let changeDotY = ((((aircraftNode.position.z-cameraNode.position.z)*(150.0))/3.0))
        let positionAngle = atan2(changeDotY, changeDotX) // changeDotY ve changeDotX değişkenlerinin bir dik üçgeni oluşturan kenarlar olduğu düşünülürse karşı/komşu nun arctanjantı ile telefonun modele göre konum açısı hesaplanmıştır.
        let rotationAngle = cameraEulerAngle?.y ?? 0 // Kameranın kendi ekseni etrafında dönüş açısının (pitch) hesaplanması ve tanımlanması
        let angle = positionAngle + rotationAngle // Telefonun hem nesne etrafında dönmesi(position) hem de kendi ekseni etrafında(rotation) dönmesi ile oluşan açısal değişimin tanımı
        
        // Bu kısım  x-y düzlemindeki hareketin yarıçap ve açı cinsinden hesabını tarifler. Radardaki nokta görüntüsünün bulunduğu merkezden itibaren ne kadarlık yarıçapta hareket ettiği tanımlanmıştır.
        
        let radius = CGFloat(sqrtf(powf(Float(changeDotX), 2.0)+powf(Float(changeDotY), 2.0)))
       
    
        // Açısı ve yarıçapı bilinen hareketin x ve y eksenlerindeki bileşenlerinin hesaplanması
        
        let componentY = radius * sin(CGFloat(angle))
        let componentX = radius * cos(CGFloat(angle))
        
        
        DispatchQueue.main.async { [self] in
            
            // x ve y eksenindeki görsel hareketin matematiksel hesabı
            
            dotImageView.center.x = radarImageView.center.x + componentX
            dotImageView.center.y = radarImageView.center.y + componentY
            
        }
        
    }
    
}



