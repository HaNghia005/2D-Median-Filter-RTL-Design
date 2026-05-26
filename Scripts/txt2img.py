import numpy as np
import cv2

WIDTH = 430
HEIGHT = 554

data = []
with open("pic_output.txt") as f:
    for line in f:
        data.append(int(line.strip(),16))

img = np.array(data, dtype=np.uint8).reshape((HEIGHT, WIDTH))

cv2.imwrite("output.jpg", img)