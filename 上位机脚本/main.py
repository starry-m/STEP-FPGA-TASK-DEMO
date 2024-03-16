
from PIL import Image
import serial
import time
# 打开串口
ser = serial.Serial('COM12', 96000)  # 更改为你的串口号和波特率

# 准备图片列表
image_files = ["D:/1my_program_study/2024_winter_task/STEP_FPGA/2.jpg", "D:/1my_program_study/2024_winter_task/STEP_FPGA/3.jpg", "D:/1my_program_study/2024_winter_task/STEP_FPGA/4.jpg"]  # 图片文件列表
index_times=0
byte_array_hex1 = ['08', '08', '0C', '0C', '0D', '0D', '0C', '00',
                      '0B', '0B', '0A', '0A', '09', '09', '08', '00',
                      '0C', '0C', '0B', '0B', '0A', '0A', '09', '00',
                      '0C', '0C', '0B', '0B', '0A', '0A', '09', '00',
                      '08', '08', '0C', '0C', '0D', '0D', '0C', '00',
                      '0B', '0B', '0A', '0A', '09', '09', '08', '00']
byte_array_hex2 = ['08', '09', '0A', '08', '08', '09', '0A', '08', '0A', '0B', '0C', '00',
                   '0A', '0B', '0C', '00',
                   '0C', '0D', '0C', '0B', '0A', '08', '0C', '0D',
                   '0C', '0B', '0A', '08', '09', '0C', '09', '08',
                   '09', '0C', '09', '08']

# 发送十六进制数据
def send_hex_data(byte_array_hex):
    try:
        for hex_str in byte_array_hex:
            byte = bytes.fromhex(hex_str)  # 将十六进制字符串转换为字节
            ser.write(byte)
    finally:
        # 关闭串口
       return

send_hex_data(byte_array_hex1)
send_hex_data(byte_array_hex2)

try:
    while True:
        # 发送图像数据
        for image_file in image_files:
            # 打开图像文件
            index_times =index_times+1
            image = Image.open(image_file)

            # 将图像缩放到指定大小并居中
            width, height = 240, 320
            image = image.resize((width, height), Image.LANCZOS)
            left = (width - image.width) // 2
            top = (height - image.height) // 2
            right = left + image.width
            bottom = top + image.height
            cropped_image = image.crop((left, top, right, bottom))

            # 获取图像的尺寸
            width, height = cropped_image.size

            # 将颜色数据转换为字节数组并发送
            try:
                for y in range(height):#height
                    print("index:"+str(index_times)+"num:" + str(y))
                    row_data = bytearray()
                    for x in range(width):
                        r, g, b = cropped_image.getpixel((x, y))
                        # 将RGB值转换为16位整数
                        color = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)
                        # 将颜色数据转换为字节数组
                        row_data.extend(color.to_bytes(2, byteorder='big'))
                    # 发送数据并等待接收字符'A'
                    ser.write(row_data)
                    while ser.read() != b'A':
                        pass
                    # 等待接收到字符'B'后继续发送下一张图片

            finally:
                while ser.read() != b'B':
                    pass
                time.sleep(1)

finally:
    ser.close()



