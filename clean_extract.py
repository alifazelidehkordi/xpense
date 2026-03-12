from PIL import Image

def clean_extract(img_path, crop_box, output_name):
    img = Image.open(img_path).convert("RGBA")
    cropped = img.crop(crop_box)
    
    # The background in the image is a solid grey. Let's find its exact color
    # by sampling the top-left corner of the crop.
    bg_color = cropped.getpixel((0, 0))
    
    # We will iterate through all pixels. If a pixel is close to bg_color, we make it transparent.
    # To handle the anti-aliased edges and drop shadows, we need a slight tolerance.
    # But a simple color replacement might destroy the drop shadow.
    # Actually, PIL doesn't have a great flood fill for alpha like OpenCV.
    # Let's use a soft threshold based on distance to background color.
    
    pixels = cropped.load()
    width, height = cropped.size
    
    # bg_color is like (234, 234, 234, 255)
    
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            
            # Distance from pure background
            dist = sum((c1 - c2)**2 for c1, c2 in zip((r,g,b), bg_color[:3])) ** 0.5
            
            # If it's very close to background, make it fully transparent
            if dist < 5:
                pixels[x, y] = (r, g, b, 0)
            elif dist < 30:
                # Soft blend for shadow/edges
                alpha = int(((dist - 5) / 25.0) * 255)
                pixels[x, y] = (r, g, b, alpha)
                
    cropped.save(output_name)

img_path = '/Users/foundation26/.gemini/antigravity/brain/f1b38f80-8986-49b6-a189-c824ee8d7c5a/media__1773171032560.jpg'

# Coordinates for the 3 large icons on the right (x=770 to 980)
clean_extract(img_path, (770, 130, 980, 340), 'LevelLocked.png')
clean_extract(img_path, (770, 380, 980, 590), 'LevelActive.png')
clean_extract(img_path, (770, 600, 980, 810), 'LevelCompleted.png')

# The background map crop - if we aren't using the snake path, what background do we use?
# User says "if you need longer background make it yourself".
# The user map background is `MapBackground.png`. Let's just use it as a scrolling repeating pattern or stretch it less.
# Actually, the user specifically hated the "monopoly style thing" and the "background too".
# If we change to a vertical list, let's just make the background tiled properly or use a simpler gradient!
# Wait, the user provided a full image including the background. Let's check the map part.
img = Image.open(img_path)
map_crop = img.crop((350, 0, 740, 765))
map_crop.save('MapBackground.png')

print("Extraction complete")
