from PIL import Image

img = Image.open('MapBackground.png')
w, h = img.size

print(f"Image size is {w}x{h}")

# The gray marker centers are roughly grey (140, 140, 140) to (180, 180, 180).
# Let's do a simple connected component or bounding box search, or just let me print out some coordinates manually if detection fails.
# Since finding them visually via script is hard without OpenCV, let me just print the dimensions and I'll rough it out, or try to detect pixels matching the center of those grey circles.
# Or better yet, write a script to generate swift code with these hardcoded points if I can estimate them.
# I'll just manually guess the path roughly since I can see it:
# It starts at the bottom left (piggy bank), winds up, then right, then left...
