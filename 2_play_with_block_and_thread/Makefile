
FILE_NAME = three_vector_addition_with_block_and_thread

all: $(FILE_NAME)

$(FILE_NAME): $(FILE_NAME).cu
	nvcc -ccbin g++-10 -O3 $(FILE_NAME).cu -o $(FILE_NAME)
run: $(FILE_NAME)
	./$(FILE_NAME)
clean:
	rm -f $(FILE_NAME)