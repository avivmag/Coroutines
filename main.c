#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int debug;
int WorldLength;
int WorldWidth;
int genNum;
int printFreq;
int numco;
int** cors;
int dFlag = 0;
char** cellsCurrentStates;

extern void init_cors(int size);
extern void init_co_from_c(int i);
extern void start_co_from_c();
extern void fill_cells_current_states(char * filename);
extern void print_debug(char* length, char* width, char* genNum, char* printFreq);

int main(int argc, char** argv){
	if (argc == 7)
	{
		dFlag = 1;
		print_debug(argv[3], argv[4], argv[5], argv[6]);
	}
	WorldLength = atoi(argv[dFlag+2]);
	WorldWidth = atoi(argv[dFlag+3]);
	genNum = atoi(argv[dFlag+4]);
	printFreq = atoi(argv[dFlag+5]);
	int i;

	/* number of co-routines needed (scheduler and printer included) */
	numco = WorldWidth*WorldLength + 2;
	
	/* initialize co-routines */
	init_cors(numco*4);
	for(i = 0; i < numco; i++)
	{
		init_co_from_c(i);
	}
	
	fill_cells_current_states(argv[dFlag+1]); /*reads from file*/
	
	/* start a scheduler co-routine*/
	start_co_from_c();

	return 0;
}
