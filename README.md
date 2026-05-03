# imagep.ijm — Image Pattern Processor

## Overview

`imagep.ijm` is an ImageJ macro designed for **computationally intensive artistic image processing**. It transforms any input image into geometric, symmetrical, or pattern-based artwork through a series of automated manipulations.

## Features

### Mandala / Symmetry Slicing
Splits an image into rotational slices and reassembles them into mandala-style compositions:
- 4, 8, 16, 32, 64, and 128 slice modes
- Supports a **Repeat** option to iteratively apply the effect on the previous output

### Seamless Tile
Generates a **seamless/tileable texture** from a source image, suitable for backgrounds and patterns.

### Islamic Geometric Pattern (IGP)
Procedurally draws **Islamic geometric patterns** from scratch, then applies the mandala and tile pipeline on top. Optionally adds a decorative square border around the tile.

### Drawing Tools
- Freeform **drawing** mode
- **Maze** generation
- **Numbered drawing** (A/B/C/D/E labeling)

### Batch / Directory Mode
Processes an entire folder of images automatically, applying the selected features to each file.

## Options

| Option | Description |
|---|---|
| Save Source | Saves the original (pre-processed) image |
| Save Destination | Saves the processed output image |
| Change Selection | Lets you redefine the crop/selection region |
| Rotate Image | Rotates the source before applying the selection |
| Reduce Resolution | Downscales the image to speed up processing |
| Silent Mode | Runs without displaying intermediate windows |
| Debug Mode | Draws colored outlines around selections for inspection |

## Requirements

- **ImageJ** version 1.52o or later (or Fiji)
- Output images are saved to `C:\Temp.Images` by default

## Usage

### From Command Line
Open a terminal in `.\ImageProcessing` and run:

```bat
.\Fiji\fiji.bat --run imagep.ijm
```

### From Inside ImageJ/Fiji
Press **F9** to launch the macro. A menu will appear to configure the desired features, then the macro runs in a loop until cancelled.
