# Creating a standard make file

all:
	gcc main.c -o main

clean:
	rm -f main *.o
