---
name: blender
description: Control and automate Blender via the command line. Use this skill whenever the user wants to render a .blend file, run a Python script against Blender, batch-process 3D scenes, query scene information, automate animation exports, or do anything involving Blender without opening the GUI. Trigger on phrases like "render this blend file", "run blender", "batch render", "blender script", "export from blender", "blender automation", "headless blender", "render frames", or any mention of .blend files combined with an action.
argument-hint: <task description or .blend file path>
---

# Blender CLI Skill

Automate Blender using its command-line interface. Always run in background mode (`-b`) unless the user explicitly wants the GUI open.

## Blender Binary

Detect the binary automatically:

```bash
# macOS
BLENDER="/Applications/Blender.app/Contents/MacOS/Blender"

# Linux
BLENDER="blender"

# Windows
BLENDER="C:\Program Files\Blender Foundation\Blender 4.x\blender.exe"
```

On macOS, always use the full path. Confirm with `$BLENDER --version` before running tasks.

## Core Argument Rules

**Arguments execute in order — set options BEFORE the action that uses them.**

```bash
# Wrong: output set after render trigger
blender -b file.blend -a -o //render/

# Correct: output set before render trigger
blender -b file.blend -o //render/ -a
```

Use `//` for paths relative to the .blend file. Use `#` chars for zero-padded frame numbers (`####` → `0001`, `0002`...).

## Common Operations

### Render a single frame
```bash
$BLENDER -b scene.blend -o //renders/frame_#### -F PNG -f 1
```

### Render an animation
```bash
$BLENDER -b scene.blend -o //renders/frame_#### -F PNG -s 1 -e 250 -a
```

### Render specific frames
```bash
# Frames 1, 5, 10
$BLENDER -b scene.blend -o //renders/frame_#### -F PNG -f 1 5 10

# Frame range 10-20
$BLENDER -b scene.blend -o //renders/frame_#### -F PNG -f 10..20
```

### Render with engine and threads
```bash
$BLENDER -b scene.blend -E CYCLES -t 8 -o //renders/frame_#### -F OPEN_EXR -a
```

### GPU rendering (Cycles)
```bash
$BLENDER -b scene.blend -E CYCLES -f 1 -- --cycles-device CUDA
# or
$BLENDER -b scene.blend -E CYCLES -f 1 -- --cycles-device METAL   # macOS
$BLENDER -b scene.blend -E CYCLES -f 1 -- --cycles-device OPTIX   # NVIDIA RTX
```

### Run a Python script against a .blend file
```bash
$BLENDER -b scene.blend -P my_script.py
```

### Run inline Python
```bash
$BLENDER -b scene.blend --python-expr 'import bpy; print(bpy.context.scene.name)'
```

### Pass arguments to your Python script
```bash
$BLENDER -b scene.blend -P my_script.py -- --arg1 value1 --arg2 value2
```

In the script, access them with:
```python
import sys
args = sys.argv[sys.argv.index("--") + 1:]
```

### Query scene info (no file needed)
```bash
$BLENDER -b scene.blend --python-expr '
import bpy
scene = bpy.context.scene
print("Scene:", scene.name)
print("Frames:", scene.frame_start, "->", scene.frame_end)
print("Resolution:", scene.render.resolution_x, "x", scene.render.resolution_y)
print("Engine:", scene.render.engine)
for obj in bpy.data.objects:
    print(" -", obj.name, obj.type)
'
```

### List available render engines
```bash
$BLENDER -E help
```

## Python Script Patterns

### Modify and render
```python
import bpy

scene = bpy.context.scene
scene.render.resolution_x = 1920
scene.render.resolution_y = 1080
scene.render.filepath = "//renders/frame_####"
scene.render.image_settings.file_format = "PNG"
bpy.ops.render.render(animation=True)
```

### Enable GPU (Cycles)
```python
import bpy

scene = bpy.context.scene
scene.cycles.device = 'GPU'
prefs = bpy.context.preferences
cycles_prefs = prefs.addons['cycles'].preferences
cycles_prefs.compute_device_type = 'METAL'  # or 'CUDA', 'OPTIX', 'HIP'
for device in cycles_prefs.get_devices()[0]:
    device.use = True
```

### Batch render multiple .blend files
```bash
for file in *.blend; do
  $BLENDER -b "$file" -o "renders/${file%.blend}_####" -F PNG -f 1
done
```

### Export to glTF/FBX/OBJ via Python
```python
import bpy
bpy.ops.export_scene.gltf(filepath="//export/scene.glb", export_format='GLB')
```

## Key Flags Reference

| Flag | Description |
|------|-------------|
| `-b` | Background mode (no GUI) |
| `-f N` | Render frame N (or `N..M` range, or `N M P` list) |
| `-a` | Render full animation |
| `-s N` / `-e N` | Start / end frame |
| `-o path` | Output path (`//` = blend-relative, `#` = frame padding) |
| `-F format` | Output format: `PNG`, `JPEG`, `OPEN_EXR`, `TIFF`, `AVIJPEG` |
| `-E engine` | Render engine: `CYCLES`, `BLENDER_EEVEE`, `BLENDER_WORKBENCH` |
| `-t N` | CPU thread count (0 = all) |
| `-S name` | Set active scene by name |
| `-P script.py` | Run Python script |
| `--python-expr` | Evaluate inline Python |
| `--` | Everything after this goes to the Python script as argv |

## Error Handling

Always check the exit code after rendering:
```bash
$BLENDER -b scene.blend -f 1 && echo "Render succeeded" || echo "Render failed"
```

Common issues:
- **Missing file**: Check the path — use absolute paths when in doubt
- **Engine not available**: Run `-E help` to list available engines; fall back to `BLENDER_EEVEE`
- **GPU not available**: Remove `-- --cycles-device CUDA` to fall back to CPU
- **Argument order**: If output is missing, check that `-o` comes before `-a` or `-f`
