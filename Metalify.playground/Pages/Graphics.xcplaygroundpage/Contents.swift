/*:
 # **Part 3**:
 # Your first 3D object.
 ---
 - note: Don't forget to open your assistant editor to see the `liveView`
 ---
 - important: "The beginning is the most important part of the work." \
 -Plato. \
 \
 In this section, we'll cover the main concept about our new 3D object, so if you haven't gone through the triangle section, I encourage you to [go back](Triangle) and read those. Believe me, it's worth it.
 
 In this section, we'll draw a cube and we'll make it spin! Isn't it exciting?
 */

import PlaygroundSupport
import MetalKit

PlaygroundPage.current.needsIndefiniteExecution = true

public class MetalView: MTKView {
    
    var rps: MTLRenderPipelineState!
    var vertex_buffer: MTLBuffer!
    var uniform_buffer: MTLBuffer!
    var index_buffer: MTLBuffer!
    var queue: MTLCommandQueue!
    var rotationX: Float = 0
    var rotationY: Float = 0
    var rotationZ: Float = 0
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
        queue = device!.makeCommandQueue()
        createBuffers()
        registerShaders()
    }
    
    public override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        queue = device!.makeCommandQueue()
        createBuffers()
        registerShaders()
    }
    
    func createBuffers() {
/*:
Let's define all 8 vertices for the cube.
         
- experiment: Try to change the color of the vertices or move the vertices around (The cube may look deformed if you choose to move the vertices)
 */
        let vertex_data: [Vertex] = [
            Vertex(pos: [-1.0, -1.0,  1.0, 1.0], col: [1, 1, 0, 1]),
            Vertex(pos: [ 1.0, -1.0,  1.0, 1.0], col: [0, 1, 1, 1]),
            Vertex(pos: [ 1.0,  1.0,  1.0, 1.0], col: [1, 0, 1, 1]),
            Vertex(pos: [-1.0,  1.0,  1.0, 1.0], col: [0, 1, 1, 1]),
            Vertex(pos: [-1.0, -1.0, -1.0, 1.0], col: [0, 0, 1, 1]),
            Vertex(pos: [ 1.0, -1.0, -1.0, 1.0], col: [0, 1, 1, 1]),
            Vertex(pos: [ 1.0,  1.0, -1.0, 1.0], col: [1, 0, 0, 1]),
            Vertex(pos: [-1.0,  1.0, -1.0, 1.0], col: [0, 1, 0, 1])
        ]
        
/*:
Here's the interesting part. Since squares and other complex geometry objects are made from triangles, and most `vertices` belong to **two** or more triangles, we don't need to make multiple copies of the `vertices`, we'll just reuse them via `index buffer`
         
What is `index buffer` actually? `Index buffer` keeps track of the order of which the vertices will be used by storing the index from the `vertex buffer`.
         
- example: In the `index_data` below, we can see that the `front` side of the cube, used 6 vertices to build the square. Index `0`, `1`, `2` creates the bottom right part of the square and index `2`, `3`, `0` creates the upper left part of the square. We also can see that one `vertex` could be used to build multiple `surface`.
         
 */
        
        let index_data: [UInt16] = [
            0, 1, 2, 2, 3, 0,   // front
            1, 5, 6, 6, 2, 1,   // right
            3, 2, 6, 6, 7, 3,   // top
            4, 5, 1, 1, 0, 4,   // bottom
            4, 0, 3, 3, 7, 4,   // left
            7, 6, 5, 5, 4, 7,   // back
        ]
        
        vertex_buffer = device!.makeBuffer(bytes: vertex_data, length: MemoryLayout<Vertex>.size * vertex_data.count, options: [])
        
/*:
---
 Here, we're introducing a new `uniform_buffer` that will store the transformation matrix for the `shader` to compute.
 */
        uniform_buffer = device!.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
/*:
---
 */
        
        index_buffer = device!.makeBuffer(bytes: index_data, length: MemoryLayout<UInt16>.size * index_data.count, options: [])
    }
    
    func registerShaders() {
        let path = Bundle.main.path(forResource: "Shaders", ofType: "metal")
        let input: String?
        let library: MTLLibrary
        let vert_func: MTLFunction
        let frag_func: MTLFunction
        do {
            input = try String(contentsOfFile: path!, encoding: .utf8)
            library = try device!.makeLibrary(source: input!, options: nil)
            vert_func = library.makeFunction(name: "vertex_func")!
            frag_func = library.makeFunction(name: "fragment_func")!
            let rpld = MTLRenderPipelineDescriptor()
            rpld.vertexFunction = vert_func
            rpld.fragmentFunction = frag_func
            rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
            rps = try device!.makeRenderPipelineState(descriptor: rpld)
        } catch let e {
            Swift.print("\(e)")
        }
    }
    
/*:
It's time to animate the cube!
 */
    func update() {
/*:
- experiment: Try to change the scale, rotation on `x`, `y`, `z` axis, and move the camera position.
---
- note: You can animate the cube by adding values to the rotation, or you can also do static transformation by assigning values to rotation.
 */
        let scaled = scalingMatrix(scale: 0.5)
        rotationX = Float.pi / 4
        rotationY += 1 / 100 * Float.pi / 4
        rotationZ = 0
        let cameraPosition = vector_float3(0, 0, -3)
        
/*:
---
*/
        
        let rotatedX = rotationMatrix(angle: rotationX, axis: float3(1, 0, 0))
        let rotatedY = rotationMatrix(angle: rotationY, axis: float3(0, 1, 0))
        let rotatedZ = rotationMatrix(angle: rotationZ, axis: float3(0, 0, 1))
        let modelMatrix = matrix_multiply(matrix_multiply(matrix_multiply(rotatedX, rotatedY), rotatedZ), scaled)
        let viewMatrix = translationMatrix(position: cameraPosition)
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: 1, fovy: 1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        
/*:
---
In this part, we send the new transformation matrix to the `shader` for execution.
 */
        let bufferPointer = uniform_buffer.contents()
        var uniforms = Uniforms(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
/*:
---
 */
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        update()
        if let rpd = currentRenderPassDescriptor,
            let drawable = currentDrawable,
            let commandBuffer = queue.makeCommandBuffer(),
            let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: rpd) {
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
            
            commandEncoder.setRenderPipelineState(rps)
            commandEncoder.setFrontFacing(.counterClockwise)
            commandEncoder.setCullMode(.back)
            commandEncoder.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(uniform_buffer, offset: 0, index: 1)
/*:
 ---
Now instead of calling `drawPrimitives` like before, now we use `drawIndexedPrimitives` to render the vertices and reuse them using `index_buffer`
 */
            commandEncoder.drawIndexedPrimitives(type: .triangle, indexCount: index_buffer.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: index_buffer, indexBufferOffset: 0)
/*:
 ---
 */
            commandEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view

/*:
 It's nice isn't it? [Let's see what else we can do with `Metal`](@next)
 */
