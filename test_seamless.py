import cv2
import numpy as np
img = cv2.imread("MapBackground.png")
if img is not None:
    top = img[0:10, :]
    bottom = img[-10:, :]
    diff = cv2.absdiff(top, bottom)
    print("Mean diff between top and bottom:", diff.mean())
