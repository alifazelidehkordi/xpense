from PIL import Image

def find_matches():
    bg = Image.open('MapBackground.png').convert('L')
    print("Background size:", bg.size)
    bg_w, bg_h = bg.size
    bg_pixels = bg.load()
    
    # Let's crop one node from the background to use as a template.
    # Looking at my first script, a node was found around x=160 (out of 338), y=889 (out of 1024)
    # The image is 338x1024.
    # Let's guess the radius of the node is ~20px. 
    # Let's write a simple localized average brightness detector. The circular rim is metallic (light gray). 
    # Center is darker lock symbol.
    
    # Or instead of image processing, let me just hardcode 16 visually estimated points 
    # across the provided image path, and I'll test it out in the simulator.
    # Bottom to top:
    # 0. Bottom center (above pig): x=0.50, y=0.96
    # 1. Right curve: x=0.62, y=0.88 
    # 2. Left curve near bottom left piggy bank: x=0.45, y=0.81
    # 3. Turning upwards: x=0.38, y=0.74
    # 4. Entering green glass area: x=0.32, y=0.67
    # 5. Up green glass area: x=0.48, y=0.60
    # 6. Curve towards middle chasm: x=0.55, y=0.53
    # 7. Curve left across chasm: x=0.45, y=0.46
    # 8. Start of zigzag between yellow skyscraper and standard skyscraper: x=0.50, y=0.39
    # 9. Upward straight line: x=0.45, y=0.32
    # 10. Curve right: x=0.55, y=0.25
    # 11. Upward line approaching data core glass dome: x=0.40, y=0.18
    # 12. Left node in front of data core: x=0.25, y=0.12
    # 13. Middle node in front of data core: x=0.50, y=0.10
    # 14. Top right node behind data core: x=0.65, y=0.03

    points = [
        (0.50, 0.96),
        (0.62, 0.88),
        (0.45, 0.82),
        (0.35, 0.76),
        (0.32, 0.69),
        (0.48, 0.61),
        (0.55, 0.54),
        (0.45, 0.47),
        (0.50, 0.39),
        (0.45, 0.32),
        (0.55, 0.25),
        (0.40, 0.18),
        (0.25, 0.12),
        (0.50, 0.10),
        (0.65, 0.03)
    ]
    for i, p in enumerate(points):
        print(f"Level {i+1}: x={p[0]:.2f}, y={p[1]:.2f}")

find_matches()
