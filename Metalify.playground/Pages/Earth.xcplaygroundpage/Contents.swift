/*:
 # Part 6
 # Texture? Why not?
 ---
 - note: Don't forget to open your assistant editor to see the `liveView`
 ---
 
 In this last section, we'll give the clothes to the sphere, so it'll look great! We're going to give texture to the sphere and rotate it.
 */
import PlaygroundSupport
import MetalKit

PlaygroundPage.current.needsIndefiniteExecution = true

public class MetalView: MTKView {
    
    enum TextureType {
        case jupiter
        case mars
        case mercury
        case meat
        case rock
    }
    
    var cps: MTLComputePipelineState!
    var queue: MTLCommandQueue!
    var timer: Float = 0
    var timerBuffer: MTLBuffer!
    var texture: MTLTexture!
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
        queue = device!.makeCommandQueue()
        registerShaders()
        setUpTexture()
    }
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        queue = device!.makeCommandQueue()
        registerShaders()
/*:
- experiment: Try to change the parameter of setUpTexture into one of below: \
`.jupiter`\
`.mars`\
`.mercury`\
`.meat`\
`.rock`
 */
        
        setUpTexture(texture: .jupiter)
    }
    
//:---
//: We create a new function to load the texture for the sphere.
    func setUpTexture(texture type: TextureType = .jupiter) {
        var textureName: String!

        switch type {
        case .jupiter:
            textureName = "jupiter"
            break
        case .mars:
            textureName = "mars"
            break
        case .meat:
            textureName = "meat"
            break
        case .mercury:
            textureName = "mercury"
            break
        case .rock:
            textureName = "rock"
            break
        }
        
        let path = Bundle.main.path(forResource: textureName, ofType: "jpg")
        let textureLoader = MTKTextureLoader(device: device!)
        texture = try! textureLoader.newTexture(URL: URL(fileURLWithPath: path!), options: nil)
    }
//:---
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let drawable = currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            
            commandEncoder.setComputePipelineState(cps)
            commandEncoder.setTexture(drawable.texture, index: 0)
            commandEncoder.setBuffer(timerBuffer, offset: 0, index: 0)
//:---
//: And we pass the texture as a parameter for the `shader`
            commandEncoder.setTexture(texture, index: 1)
//:---
            update()
            
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    func registerShaders() {
        let path = Bundle.main.path(forResource: "Kernel", ofType: "metal")
        do {
            let input = try String(contentsOfFile: path!, encoding: .utf8)
            let library = try device!.makeLibrary(source: input, options: nil)
            let kernel = library.makeFunction(name: "compute")!
            cps = try device!.makeComputePipelineState(function: kernel)
        } catch let e {
            Swift.print("\(e)")
        }
        timerBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: [])
    }
    
    func update() {
        timer += 0.01
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
    }
}

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view

/*:
 This wraps up our `Metal` playground! I hope WWDC 2019 will bring new extraordinary things in the field Graphics processing. Hope to see you guys there!
 
 Abram Situmorang
 
 [Table of contents](Intro)
 */
