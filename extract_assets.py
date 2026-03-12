from PIL import Image, ImageDraw

def mask_circle(img):
    img = img.convert("RGBA")
    mask = Image.new('L', img.size, 0)
    draw = ImageDraw.Draw(mask)
    padding = 2
    draw.ellipse((padding, padding, img.size[0]-padding, img.size[1]-padding), fill=255)
    
    # Create a transparent background image
    result = Image.new("RGBA", img.size, (0, 0, 0, 0))
    result.paste(img, (0, 0), mask=mask)
    return result

img_path = '/Users/foundation26/.gemini/antigravity/brain/f1b38f80-8986-49b6-a189-c824ee8d7c5a/media__1773171032560.jpg'
try:
    image = Image.open(img_path)
    
    # Map: x=350 to 740, y=0 to 765
    map_crop = image.crop((350, 0, 740, 765))
    map_crop.save('MapBackground.png')
    print("Saved MapBackground")
    
    # Locked: y=130-330, x=775-975
    locked_crop = image.crop((775, 130, 975, 330))
    locked_img = mask_circle(locked_crop)
    locked_img.save('LevelLocked.png')
    print("Saved LevelLocked.png")
    
    # Active: y=380-580, x=775-975
    active_crop = image.crop((775, 380, 975, 580))
    active_img = mask_circle(active_crop)
    active_img.save('LevelActive.png')
    print("Saved LevelActive.png")
    
    # Completed: y=590-750 -> Wait, we need it to be square
    # 775 to 975 is width 200. Height must be 200. y = 600 to 800 - but image is 765 max
    # Let's crop from 565 to 765 for Completed?
    completed_crop = image.crop((775, 555, 975, 755))
    completed_img = mask_circle(completed_crop)
    completed_img.save('LevelCompleted.png')
    print("Saved LevelCompleted.png")
    
except Exception as e:
    print("Error:", e)
