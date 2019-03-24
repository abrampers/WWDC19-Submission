/*:
 # **Part 4**:
 # Do you know that `Metal` is not only used for graphics?
 ---
 - note: Don't forget to open your assistant editor to see the `liveView`
 ---
 
 In the rise of General Purpose Computing on Graphical Processing Unit, GPU is not only used for rendering. The fact that GPU has plenty of cores for us to use, enables us to do computing tasks on GPU, especially tasks that needs high level paralellism.
 
 And because of there's another functionality of GPU, there's also another type of `shader` to accomodate this functionality. It's called the `kernel shader`. This `shader` enables programmer to run multiple parallel tasks to GPU and utilize GPU for general purpose computing.
 
 In this section, we'll cover how to actually run computing task on GPU by creating an eclipse like effect just by doing computation in the `shader`.
 */

import PlaygroundSupport
import MetalKit

PlaygroundPage.current.needsIndefiniteExecution = true

public class MetalView: MTKView {
    
/*:
---
Notice that instead of creating a `MTLRenderPipelineState`, we create `MTLComputePipelineState`
 */
    var cps: MTLComputePipelineState!
//:---
    var queue: MTLCommandQueue!
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
        queue = device!.makeCommandQueue()
        registerShaders()
    }
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        queue = device!.makeCommandQueue()
        registerShaders()
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let drawable = currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeComputeCommandEncoder() {
            
            commandEncoder.setComputePipelineState(cps)
//:---
//: Instead of giving `vertex buffer`, now we give the GPU a `texture` to work with and create `threadGroups` to work on it.
//: The `shader` will compute colors according to each pixel's location relative to the point of origin.
            commandEncoder.setTexture(drawable.texture, index: 0)
            let threadGroupCount = MTLSizeMake(8, 8, 1)
            let threadGroups = MTLSizeMake(drawable.texture.width / threadGroupCount.width, drawable.texture.height / threadGroupCount.height, 1)
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
//:---
            
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
    
    func registerShaders() {
        let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
        do {
            let input = try String(contentsOfFile: path!, encoding: .utf8)
            let library = try device!.makeLibrary(source: input, options: nil)
            let kernel = library.makeFunction(name: "compute")!
            cps = try device!.makeComputePipelineState(function: kernel)
        } catch let e {
            Swift.print("\(e)")
        }
    }
}

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view

//: It's not that hard right? Now we know `Metal`'s other superpower! [I'm ready to go forward](@next)
