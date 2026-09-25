#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <cuda_runtime.h>
//-----------------read and write bitmap------------------------
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
uint8_t *bmp_to_rgb(const char *filename, int *width, int *height)
{
    FILE *fp = fopen(filename, "rb");

    if (!fp)
        return NULL;

    // =========================
    // BMP File Header
    // =========================

    uint8_t file_header[14];

    if (fread(file_header, 1, 14, fp) != 14)
    {
        fclose(fp);
        return NULL;
    }

    if (file_header[0] != 'B' || file_header[1] != 'M')
    {
        fclose(fp);
        return NULL;
    }

    uint32_t pixel_offset =
        file_header[10] |
        (file_header[11] << 8) |
        (file_header[12] << 16) |
        (file_header[13] << 24);


    // =========================
    // DIB Header
    // =========================

    uint8_t dib_header[40];

    if (fread(dib_header, 1, 40, fp) != 40)
    {
        fclose(fp);
        return NULL;
    }

    // Width
    *width =
        dib_header[4] |
        (dib_header[5] << 8) |
        (dib_header[6] << 16) |
        (dib_header[7] << 24);

    // Height
    *height =
        dib_header[8] |
        (dib_header[9] << 8) |
        (dib_header[10] << 16) |
        (dib_header[11] << 24);

    // Bits per pixel
    uint16_t bits_per_pixel =
        dib_header[14] |
        (dib_header[15] << 8);

    if (bits_per_pixel != 24)
    {
        fclose(fp);
        return NULL;
    }


    // =========================
    // Allocate RGB buffer
    // =========================

    int row_size = ((*width * 3) + 3) & ~3;

    uint8_t *rgb = (uint8_t*)malloc(*width * *height * 3 * sizeof(uint8_t));

    if (!rgb)
    {
        fclose(fp);
        return NULL;
    }


    // =========================
    // Read Pixel Data
    // =========================

    fseek(fp, pixel_offset, SEEK_SET);

    uint8_t *row = (uint8_t*)malloc(row_size*sizeof(uint8_t));

    if (!row)
    {
        free(rgb);
        fclose(fp);
        return NULL;
    }


    for (int y = *height - 1; y >= 0; y--)
    {
        size_t bytes_read = fread(row, 1, row_size, fp);

        for (int x = 0; x < *width; x++)
        {
            int bmp_index = x * 3;

            int rgb_index =
                (y * *width + x) * 3;

            // BMP = BGR
            uint8_t B = row[bmp_index + 0];
            uint8_t G = row[bmp_index + 1];
            uint8_t R = row[bmp_index + 2];

            // Output = RGB
            rgb[rgb_index + 0] = R;
            rgb[rgb_index + 1] = G;
            rgb[rgb_index + 2] = B;
        }
    }

    free(row);
    fclose(fp);

    return rgb;
}
//-----------------read and write bitmap------------------------
__global__ void toGrayScale(uint8_t *Pout,uint8_t *Pin,int width,int height){
  int col = blockIdx.x*blockDim.x + threadIdx.x;
  int row = blockIdx.y*blockDim.y + threadIdx.y;
  if(col < width && row < height){
    int rgbPos = (row * width + col)*3;
    uint8_t grayValue = 0.21f*Pin[rgbPos] + 0.71f*Pin[rgbPos+1] + 0.07f*Pin[rgbPos+2];
    Pout[rgbPos] = grayValue;
    Pout[rgbPos+1] = grayValue;
    Pout[rgbPos+2] = grayValue;
  }


}
int main(int argc,char *argv[]){

  int width,height;
  uint8_t *rgb = bmp_to_rgb(argv[1],&width,&height);
  uint8_t *h_out = (uint8_t *)malloc(width*height*3*sizeof(uint8_t));
  if (!rgb)
  {
      printf("Failed to load BMP\n");
      return 1;
  }


  dim3 dimGrid(ceil(width/16),ceil(height/16),1);
  dim3 dimBlock(16,16,1);

  uint8_t * d_rgb;
  cudaMalloc((void **)&d_rgb, width * height * 3 * sizeof(uint8_t));

  uint8_t * d_out;
  cudaMalloc((void **)&d_out, width * height * 3 * sizeof(uint8_t));
  cudaMemcpy(d_rgb,rgb,width * height* 3 * sizeof(uint8_t),cudaMemcpyHostToDevice);
  toGrayScale<<<dimGrid,dimBlock>>>(d_out,d_rgb,width,height);

  cudaMemcpy(h_out,d_out,width * height* 3 * sizeof(uint8_t),cudaMemcpyDeviceToHost);

  save_bmp(argv[2],h_out,width,height);


}