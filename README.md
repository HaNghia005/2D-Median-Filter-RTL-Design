# Hardware-Based 2D Median Filter Image Processor

A high-throughput, hardware-implemented **2D Median Filter (3x3 Window)** in Verilog RTL for real-time image noise reduction (Salt-and-Pepper noise). 

This project features a complete **Hardware/Software Co-Verification** framework using Python for pre/post-processing and **Intel Quartus Prime** integrated with **ModelSim / Questa Intel FPGA Edition** for RTL simulation.

## Key Hardware Architectures

* **Line Buffer Pipeline:** Implements two internal line buffers using synchronous RAM block structures to stream pixel data sequentially, enabling continuous 3x3 window processing without stalling the input stream.
* **Optimized Sorting Network:** A high-speed, purely combinational sorting logic utilizing minimum/maximum comparator networks (`f_min2`, `f_max2`, `f_max3`) to find the exact median value of 9 pixels within minimal clock cycles.
* **Boundary Handling:** Intelligent edge-detection logic (`top_edge`, `bot_edge`, `left_edge`, `right_edge`) to handle boundary padding seamlessly without image distortion.

## Repository Structure

```text
RTL-Median-Filter/
├── rtl/                        # Verilog RTL Source Code
│   └── mf_core.v               # Main Median Filter Core Logic
├── tb/                         # Simulation Environment
│   └── tb_median.v             # Behavioral Testbench
├── scripts/                    # Python Verification Tools
│   ├── img2txt.py              # Converts input image to Hex Text format
│   ├── txt2img.py              # Converts processed Hex Text back to Image
│   └── evaluate_metrics.py     # Calculates PSNR and SSIM scores
├── data/                       # Test Images & Verification Data
│   ├── input/
│   │   ├── original.jpg        # Clean reference image
│   │   └── noisy.jpg           # Image corrupted with salt-and-pepper noise
│   └── output
|        └── output.jpg           # Destination for processed results
└── README.md
```
## Co-Verification Flow
The design undergoes a robust 3-stage verification loop ensuring hardware correctness against software-level metrics:

Plaintext
 [noisy.jpg] -> (Python: img2txt) -> [pic_input.txt] -> (ModelSim: RTL Core) 
                                                                 |
 [output.jpg] <- (Python: txt2img) <- [pic_output.txt] <---------+
      |
 (Python: evaluate_metrics) -> Compares with [original.jpg] -> PSNR/SSIM Results
1. Pre-Processing (Python)
Run img2txt.py to read the noisy image (data/input/noisy.jpg), convert it into grayscale pixels, and export them into a text file formatted for Verilog $readmemh.

2. RTL Simulation (ModelSim / Questa)
The testbench tb_median.v reads the stream data, feeds it pixel-by-pixel into mf_core.v on every positive clock edge when din_valid is asserted, and writes the filtered output stream back to pic_output.txt.

3. Post-Processing & Evaluation (Python)
Run txt2img.py to reconstruct the processed text array back into a visual .jpg image.

Run evaluate_metrics.py to compute PSNR (Peak Signal-to-Noise Ratio) and SSIM (Structural Similarity Index) against the original clean image to mathematically prove hardware filtering efficiency.

## How to Run
Prepare input data:

Bash
cd scripts
python img2txt.py
Open ModelSim, create a work library, compile rtl/mf_core.v and tb/tb_median.v, then run the simulation to generate the output text.

Reconstruct and evaluate image:

Bash
cd scripts
python txt2img.py
python evaluate_metrics.py

## Verification Results
Target Resolution: 430 x 554 pixels (8-bit Grayscale)

Filter Window: 3x3 Matrix

Output Metric: High PSNR improvement demonstrating successful removal of impulse noise without destroying edge features.
