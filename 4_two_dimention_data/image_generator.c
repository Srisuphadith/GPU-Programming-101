#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>

void save_bmp(const char *filename,
              const uint8_t *rgb,
              int width,
              int height)
{
    FILE *fp = fopen(filename, "wb");

    if (!fp)
        return;

    int row_size = (width * 3 + 3) & ~3;
    int pixel_data_size = row_size * height;
    int file_size = 54 + pixel_data_size;

    // BMP File Header
    uint8_t file_header[14] = {
        'B', 'M',
        (uint8_t)file_size, (uint8_t)(file_size >> 8), (uint8_t)(file_size >> 16), (uint8_t)(file_size >> 24),
        0, 0,
        0, 0,
        54, 0, 0, 0
    };

    // DIB Header
    uint8_t dib_header[40] = {
        40, 0, 0, 0,
        (uint8_t)width, (uint8_t)(width >> 8), (uint8_t)(width >> 16), (uint8_t)(width >> 24),
        (uint8_t)height, (uint8_t)(height >> 8), (uint8_t)(height >> 16), (uint8_t)(height >> 24),
        1, 0,
        24, 0,
        0, 0, 0, 0,
        (uint8_t)pixel_data_size,
        (uint8_t)(pixel_data_size >> 8),
        (uint8_t)(pixel_data_size >> 16),
        (uint8_t)(pixel_data_size >> 24),
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0
    };

    fwrite(file_header, 1, 14, fp);
    fwrite(dib_header, 1, 40, fp);

    uint8_t padding[3] = {0, 0, 0};
    int padding_size = row_size - width * 3;

    for (int y = height - 1; y >= 0; y--)
    {
        for (int x = 0; x < width; x++)
        {
            int index = (y * width + x) * 3;

            uint8_t R = rgb[index + 0];
            uint8_t G = rgb[index + 1];
            uint8_t B = rgb[index + 2];

            // BMP = BGR
            fputc(B, fp);
            fputc(G, fp);
            fputc(R, fp);
        }

        fwrite(padding, 1, padding_size, fp);
    }

    fclose(fp);
}

int main(int argc, char *argv[]){
  int width = atoi(argv[1]);
  int height = atoi(argv[2]);
  int imgArraySize = 3*width*height;
  uint8_t *imgBuffer = (uint8_t *)malloc(imgArraySize * sizeof(uint8_t));

  //for(int i = 0;i<imgArraySize;i++){
  //  if(i%36 == 0){
  //    imgBuffer[i] = 255;
  //    imgBuffer[i+1] = 255;
  //    imgBuffer[i+2] = 0;
  //  }
  // }
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {

        int i = (y * width + x) * 3;

        int squareWidth  = width / 8;
        int squareHeight = height / 8;

        int chessX = x / squareWidth;
        int chessY = y / squareHeight;

        if ((chessX + chessY) % 2 == 0) {
            imgBuffer[i]     = 51; // R
            imgBuffer[i + 1] = 200; // G
            imgBuffer[i + 2] = 120; // B
        }
        else {
            imgBuffer[i]     = 120;
            imgBuffer[i + 1] = 43;
            imgBuffer[i + 2] = 90;
        }
    }
}


  save_bmp(argv[3],imgBuffer,width,height);
  free(imgBuffer);
}