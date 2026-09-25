
all: image_generator image_greyscale output.bmp

image_generator: image_generator.c
	gcc -o image_generator image_generator.c

image_greyscale: image_greyscale.cu
	nvcc -ccbin g++-10 -O3 image_greyscale.cu -o image_greyscale
output.bmp: image_generator
	./image_generator 1024 1024 output.bmp
run: image_greyscale output.bmp
	./image_greyscale output.bmp output_gray.bmp
clean:
	rm -f image_generator image_greyscale output.bmp output_gray.bmp
