/*:
 # **PART 2**:
 # Creating a simple triangle.
 ---
 - note: Don't forget to open your assistant editor to see the `liveView`
 ---

 - Callout(Fun Fact): Everything in graphics, 2D even 3D is constructed by triangles.
 
 It's time for us to get deeper to `Metal`
 */

import PlaygroundSupport

/*:
 In this playground, we'll use MetalKit instead of `Metal` since `MetalKit` provides us with `MTKView` that will make our lives easier 😎, we'll get through this in this page.
 */

import MetalKit

PlaygroundPage.current.needsIndefiniteExecution = true

/*:
 Here we create the view that will be displayed. Here we see the view as `MTKView` which means this view can be rendered by `Metal` with the power of our GPU.
 
 */
public class MetalView: MTKView {
    
    var rps: MTLRenderPipelineState!
    var vertex_buffer: MTLBuffer!
    var queue: MTLCommandQueue!
    var rotation: Float = 0
    
/*:
 We inittialize all the properties needed which is
 - `device`: The abstraction of our GPU.
 - `queue`: This is the part where we actually 'talk' to our GPU. Every GPU will have their own `commandQueue` that acts like a typical queue to run every command we give to our GPU.
 */
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
    
/*:
We have our GPU in our hand, now the time has come for us to prepare the GPU for battle (`Rendering`)
     
- important: Every GPU have their own memory and they only execute commands on the data that they have.
     
That means we have to create a new home for our data in the GPU. How are we gonna do this?
*/
    
    func createBuffers() {
/*:
We start by creating our data in the CPU just like below.
         
- experiment: Try to tweak the vertices and see how it'll affect the triangle. Be creative, change it to your favorite color and put the triangle in the most awkward position you can get!
*/
        let vertex_data: [Vertex] = [Vertex(pos: [-0.5, -0.5, 0.0, 1.0], col: [1, 0, 0, 1]),
                                     Vertex(pos: [ 0.5, -0.5, 0.0, 1.0], col: [0, 1, 0, 1]),
                                     Vertex(pos: [ 0.0,  0.5, 0.0, 1.0], col: [0, 0, 1, 1])]
/*:
 After that, we create a `buffer` place where we can put data in the GPU.
 In creating the new home for our data, we have to specify how much space do we need to put our data.
         
- note: Don't allocate more data than needed or else we'll waste the power of our GPU.
         
In the code below, we allocate the space of `3 vertices = 3 * 8 floating point number = 3 * 8 * 4 bytes = 96 bytes` of memory in the GPU and populate the free space right away with our `vertex_data`
         
We keep our new data's address for future purposes.
 */
        vertex_buffer = device!.makeBuffer(bytes: vertex_data, length: MemoryLayout<Vertex>.size * 3, options:[])
    }
    
/*:
 This part, we register the `Shaders`.
 Well, what's a `shader`? Is it something that 'shades' the triangle? Or maybe giving shadow effect to the triangle?
 
 Patience my friend, we'll cover shaders in depth in next section.
 */
    func registerShaders() {
        let path = Bundle.main.path(forResource: "Triangle", ofType: "metal")
        let input = try! String(contentsOfFile: path!, encoding: .utf8)
        let library = try! device!.makeLibrary(source: input, options: nil)
        let vertex_func = library.makeFunction(name: "vertex_func")
        let frag_func = library.makeFunction(name: "fragment_func")
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        rps = try! device!.makeRenderPipelineState(descriptor: rpld)
    }
    
/*:
 Here comes the part where Metal does the `Rendering`. Finally
*/
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
/*:
 Render descriptor is just a collection of attachments for rendering destination. In this case, the render descriptor tells that the color is `(r: 0.5, g: 0.5, b: 0.5, a: 1.0)`
 */
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.5, 0.5, 0.5, 1.0)
            let commandBuffer = queue!.makeCommandBuffer()
/*:
 Now we make the command encoder. What command encoder does is it translates all the API calss a.k.a our commands to the GPU into a format that the GPU can excecute. Besides that, the command encoder also gives the context to the GPU.
- note: GPU always run within context. Every pass, GPU always running the `shaders` on the data within context
             
Here we set the context buffer at `index` 0 as `vertex_buffer` and give the `drawPrimitives` command to the GPU.
 */
            
            let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
            commandEncoder?.setRenderPipelineState(rps!)
            commandEncoder?.setVertexBuffer(vertex_buffer, offset: 0, index: 0)
            commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            commandEncoder?.endEncoding()
            
/*:
 The last thing is we display the render results and voila, we have our triangle!
 */
            commandBuffer?.present(drawable)
            commandBuffer?.commit()
        }
    }
}

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view
/*:
 Finished tweaking and exploring your triangle? [Let's do some recap](@next)
 */
