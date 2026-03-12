import sys
from PIL import Image

def process_icon():
    input_path = "/Users/foundation26/Downloads/New project/icon.png"
    output_path = "/Users/foundation26/Downloads/New project/BudgetPlanner/Assets.xcassets/AppIcon.appiconset/icon_1024.png"
    
    # 1024x1024 white background
    bg = Image.new('RGB', (1024, 1024), (255, 255, 255))
    
    # Load user's icon
    try:
        icon = Image.open(input_path)
    except Exception as e:
        print(f"Error opening image: {e}")
        return
        
    # Resize preserving aspect ratio (leaving some padding, let's use 850x850 max)
    icon.thumbnail((850, 850), Image.Resampling.LANCZOS)
    
    # Calculate position to paste (centered)
    x = (1024 - icon.width) // 2
    y = (1024 - icon.height) // 2
    
    # Paste using alpha channel as mask if available
    if icon.mode in ('RGBA', 'LA') or (icon.mode == 'P' and 'transparency' in icon.info):
        bg.paste(icon, (x, y), icon)
    else:
        bg.paste(icon, (x, y))
        
    bg.save(output_path)
    print("Icon processed and saved.")

if __name__ == '__main__':
    process_icon()
