//: A Cocoa based Playground to present user interface

import Cocoa
import PlaygroundSupport
import MetalKit

let device = MTLCreateSystemDefaultDevice()!
let frame = NSRect(x: 0, y: 0, width: 600, height: 600)
let view = MetalView(frame: frame, device: device)

PlaygroundPage.current.liveView = view

