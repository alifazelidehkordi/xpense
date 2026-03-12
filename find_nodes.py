from PIL import Image

img = Image.open('MapBackground.png')
w, h = img.size
pixels = img.load()

# Strategy: Find groups of pixels that are gray and have the lock icon color in the middle
# The gray circle rim is roughly (180, 180, 180) to (210, 210, 210).
# Let's just create a brightness map and see if we can find them.
# A simpler approach: I will literally print a grid of the image in a downscaled way to see the path if need be, but let's try to detect the grey.
nodes = []

def is_gray(c):
    r,g,b = c[:3]
    return abs(r-g) < 10 and abs(g-b) < 10 and abs(r-b) < 10

def is_node_center(x, y):
    c = pixels[x, y]
    # Center locking iron is darker grey
    if is_gray(c) and 80 < c[0] < 160:
        return True
    return False

# naive clustering
for y in range(0, h, 5):
    for x in range(0, w, 5):
        if is_node_center(x, y):
            # check if it forms a large enough blob
            match = 0
            for dy in range(-10, 11, 2):
                for dx in range(-10, 11, 2):
                    if 0 <= x+dx < w and 0 <= y+dy < h:
                        if is_gray(pixels[x+dx, y+dy]):
                            match += 1
            if match > 50:
                nodes.append((x, y))

# Group close nodes
final_nodes = []
for n in nodes:
    if not any(abs(n[0]-f[0]) < 30 and abs(n[1]-f[1]) < 30 for f in final_nodes):
        final_nodes.append(n)

# sort by y descending (bottom to top is level 1 to level N)
final_nodes.sort(key=lambda p: p[1], reverse=True)

print(f"Found {len(final_nodes)} nodes:")
for i, n in enumerate(final_nodes):
    print(f"Level {i+1}: x={n[0]/w:.3f}, y={n[1]/h:.3f}")
