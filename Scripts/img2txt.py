import cv2

# Đọc ảnh grayscale
img = cv2.imread("noisy.jpg", cv2.IMREAD_GRAYSCALE)

# Kiểm tra ảnh có đọc được không
if img is None:
    raise ValueError("Không đọc được ảnh!")

h, w = img.shape

# Ghi ra file hex
with open("pic_input.txt", "w") as f:
    for i in range(h):
        for j in range(w):
            f.write(f"{img[i, j]:02x}\n")   # mỗi pixel 1 dòng hex

print("Đã xuất file pic_input.txt thành công!")