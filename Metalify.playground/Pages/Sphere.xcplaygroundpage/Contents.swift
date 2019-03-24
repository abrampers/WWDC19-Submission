/*:
 # Part 5
 # The white ball.
 ---
 - note: Don't forget to open your assistant editor to see the `liveView`
 ---
 
 In this section, we're going to see a demo to animate without using transformation matrix like we did in [Part 3](Graphics). Now we're going to give timer to the `shader`, and the `shader` will do the rest.
 */

import PlaygroundSupport
import MetalKit

PlaygroundPage.current.needsIndefiniteExecution = true

public class MetalView: MTKView {
    
    var cps: MTLComputePipelineState!
    var queue: MTLCommandQueue!
//:---
//: Here we create the timer and it's GPU buffer
    var timer: Float = 0
    var timerBuffer: MTLBuffer!
//:---
    var pos: NSPoint!
    
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
            commandEncoder.setTexture(drawable.texture, index: 0)
            commandEncoder.setBuffer(timerBuffer, offset: 0, index: 1)
//:---
//: We do the update everytime the `draw` function called
            update()
//:---
            
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
//: - experiment: Try to change the timer delta, what will happen?
        timer += 0.01
//: ---
        let bufferPointer = timerBuffer.contents()
        memcpy(bufferPointer, &timer, MemoryLayout<Float>.size)
    }
}

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view

//: Oh my, even the shader can do it's own animation. [Let's see another demo](@next)
