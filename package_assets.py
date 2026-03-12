import os
import json
import shutil

assets_dir = '/Users/foundation26/Downloads/New project/BudgetPlanner/Assets.xcassets'

images = [
    'MapBackground.png',
    'LevelLocked.png',
    'LevelActive.png',
    'LevelCompleted.png'
]

for img_name in images:
    base_name = os.path.splitext(img_name)[0]
    imageset_dir = os.path.join(assets_dir, f'{base_name}.imageset')
    os.makedirs(imageset_dir, exist_ok=True)
    
    # Copy image
    target_img = os.path.join(imageset_dir, img_name)
    shutil.copy(img_name, target_img)
    
    # Create Contents.json
    contents = {
      "images" : [
        {
          "filename" : img_name,
          "idiom" : "universal",
          "scale" : "1x"
        },
        {
          "idiom" : "universal",
          "scale" : "2x"
        },
        {
          "idiom" : "universal",
          "scale" : "3x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    
    with open(os.path.join(imageset_dir, 'Contents.json'), 'w') as f:
        json.dump(contents, f, indent=2)

print("Added imagesets to Assets.xcassets")
