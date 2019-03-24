/*:
 # Quick Recap!
 
 - note: There's no runnable code here, so don't bother to run.
 
 We've covered a lot of new and fancy things in our previous section. There are many concept that are pretty hard to grasp, it's normal, you're not alone in this.
 
 In the previous section, we met a few new terms such as:
 1. `device`: GPU abstraction
 2. `commandQueue`: Where we put our commands for the GPU
 3. `buffers`: Where we put our data for the GPU
 4. `shaders`: The GPU's custom 'executor'
 
 We haven't know much about `shaders`, now we'll see what `shaders` really are. `Shaders` is actually a little program that runs on the GPU. `Shaders` enable programmers to interfere and modify what should be done on the graphics pipeline (We'll get into this in a minute). Since it runs on the GPU, it must be lightweight and fast. In `Metal`, there are a few types of `shader`, two of them are `vertex shader` and `fragment shader`. What's the difference between those two? `Vertex shader` is responsible for giving the position of the vertices in space, so `vertex shader` gets called once per vertex. On the other side, `fragment shader` is responsible for coloring every pixel that should be colored, this means `fragment shader` can be called thousands of times.
 
 - note: In this playground, you don't have to bother about editing or creating the `shaders`, I've implemented the `shader` needed for running the playground.
 
 ---
 
 Still confused? No problem, we'll get a better understanding when we understand the graphics pipeline (where everything connects)
 
 Now, let's get into the flow of graphics processing in `Metal` or usually called graphics pipeline.
 
 `Metal`'s `graphics pipeline` and every other typical `graphics pipeline` consists of many parts that some executes on CPU and other in GPU.
 1. Before everything goes into the GPU, we start off by running the CPU program we've written to create the data.
 2. The data from CPU moved into the GPU and the GPU starts to execute the `vertex shader` to process the vertices. `Vertex shader` may transform the position of vertices relative to `camera`, `world space`, or even do some `clipping`.
 3. After vertices are set, the GPU assembles the `triangles`, `quads`, `lines`, or `points`.
 4. Next, the GPU will do some `Rasterization` do some `multisampling` and `smoothing`. `Rasterization` also determines which pixel are going to be given to the `fragment shader`.
 5. `Fragment shader` will do it's work by running the `shader function` on every pixel needed.
 6. Finally, all the results go into the `framebuffer` or simply the screen.
 
 ---
 
 
 In the bigger picture, to build a `Metal` application, there are two stages `Initialization` and `Drawing` stage.
 
 - `Initialization` stage:
    - First, we get the `device` that resembles the direct connection to the GPU hardware and driver and the source of all objects we're going to use in `Metal`.
    - Next, we create the `commandQueue` from the device which will be our way to submit work to GPU.
    - We need to create a new place for our data to reside on our GPU. We allocate `buffers` in the GPU and move our data to that `buffer`
    - Setup the `RenderPipelines` by loading up the `shaders`, compiling it, and give assign the `shader` to the pipeline.
    - Create the view for `Metal` to draw. We did this by subclassing the `MTKView` in our `MetalView` class.
 
 
 - `Drawing` stage:
    - Create the `commandBuffer` to store all the command we're going to send to the GPU.
    - Start a render pass by encoding the `RenderPassDescriptor`.
    - Draw by passing the `drawPrimitives` to the `commandBuffer`.
    - Commit the `commandBuffer`.
 
 
 I hope this recap gives more clarity about the general `graphics pipeline` and `Metal`'s pipeline! Now we're ready to hit our [first 3D Object](@next)
 
 */

