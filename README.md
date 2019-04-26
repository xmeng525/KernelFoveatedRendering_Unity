# KernelFoveatedRendering_Unity
The unity demo of kernel foveated rendering.

* [Project](https://xiaoxumeng1993.wixsite.com/xiaoxumeng/kernel-foveated-rendering)
* [Paper](https://dl.acm.org/citation.cfm?id=3203199)
* [Video (Youtube)](https://www.youtube.com/watch?v=VOpC-xEaB-Q&feature=youtu.be)
* [Video (Vimeo)](https://vimeo.com/264994635?activityReferer=1)
* [Slides](https://obj.umiacs.umd.edu/aug_slides/Kernel_Foveated_Rendering_I3D_05152018.pptx)

<img src="https://github.com/xmeng525/KernelFoveatedRendering_Unity/blob/master/project_page.jpg" alt="" width="900" height="540" />

## Install

The "Asset" folder contains the Unity project for kernel foveated rendering. 

The "KernelFoveatedRendering.unitypackage" is the unity package of the project (generated with Unity 2017.2.0f3).
## Keyboard Control
You may use the keyboard to control the parameters:

"A": decrease sigma;

"D": increase sigma;

"W": increase alpha;

"D": decrease alpha;

"F1": whether to execute the first KFR pass;

"F2": whether to execute the second KFR pass;

"F9": save the image to the folder "Result".

"left/right/up/down arrows": control the gaze position.
![alt text](https://github.com/xmeng525/KernelFoveatedRendering_Unity/blob/master/keyboard_instruction.png "KeyboardInstruction")

Please note that this project only shows the effect of kernel foveated rendering. 
The speedup cannot be shown in this project because the rendering task here is not complex.
