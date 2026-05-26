#neu loi cai them thu vien trong term cua VSCODE: pip install scikit-image
import cv2
import numpy as np
from skimage.metrics import peak_signal_noise_ratio as compute_psnr
from skimage.metrics import structural_similarity as compute_ssim
# SV ĐIỀU CHỈNH PATH CHO ĐÚNG
file_anh_goc = 'original.jpg'
file_anh_ket_qua = 'output.jpg'

img_original = cv2.imread(file_anh_goc, cv2.IMREAD_GRAYSCALE)
img_reconstructed = cv2.imread(file_anh_ket_qua, cv2.IMREAD_GRAYSCALE)

# Kiểm tra xem ảnh có tồn tại không
if img_original is None:
    print(f"Lỗi: Không tìm thấy file {file_anh_goc}")
elif img_reconstructed is None:
    print(f"Lỗi: Không tìm thấy file {file_anh_ket_qua}")
else:
    # Kiểm tra kích thước (2 ảnh phải có cùng chiều rộng x chiều cao)
    if img_original.shape != img_reconstructed.shape:
        print("Lỗi: Kích thước hai ảnh không khớp nhau. Hãy kiểm tra lại!")
        print(f"Kích thước ảnh gốc: {img_original.shape}")
        print(f"Kích thước ảnh kết quả: {img_reconstructed.shape}")
    else:
        # Tính PSNR trên phần lõi ảnh đã cắt
        psnr_value = compute_psnr(img_original, img_reconstructed, data_range=255)

        # Tính SSIM trên phần lõi ảnh đã cắt
        ssim_value = compute_ssim(img_original, img_reconstructed, data_range=255)

        # BƯỚC 3: IN KẾT QUẢ
        print("-" * 30)
        print("KẾT QUẢ CHẤM LẠI SAU KHI CẮT VIỀN NHIỄU")
        print("-" * 30)
        print(f"1. PSNR : {psnr_value:.2f} dB")
        print(f"2. SSIM : {ssim_value:.4f}")
        print("-" * 30)