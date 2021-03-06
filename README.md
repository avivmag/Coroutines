# Coroutines

A simulation of Conway's Game of Life (GOL) with Coroutines.

The development of this simulation was done as part of an assignment in "Computer Architecture" course at Ben-Gurion University in the second semester of 2016.

A detailed description of the simulation can be found in the assignment description attached.

## Gol coroutines 

From Wikipedia (link attached below): "Coroutines are computer-program components that generalize subroutines for non-preemptive multitasking, by allowing multiple entry points for suspending and resuming execution at certain locations."

Every subroutine has its own stack, flags and register's data.</br>
Every subroutine defines its own phase for a decision to yield.</br>
This simulation is built from 3 types of subroutines: scheduler, printer and cell.</br>
The role of each and every one of them is slightly different.

### Printer

The printer's role is fairly simple, its just prints the current state of the board grid.</br>
After doing so, it yields back to the scheduler coroutine.

### Scheduler

The scheduler's role is about deciding which subroutine will run next among the array of subroutines.</br>
It does so by choosing the next cell's coroutine in a round robin fashion. After a fixed rounds of cell's coroutines running (as described in details in the Assigment description attached), the scheduler calls the printer's coroutine.</br>
The scheduler holds a structure which pointing to each and every subroutine data holders.</br>
when a subroutine is scheduled for work, its stack, flags and register's data need to be restored. That is done with those data holders mentioned above.

### Cell

In contrast to the other types of coroutines mentioned, this type is replicated for each and every cell on the board grid, meaning, each and every cell has its own coroutine.</br>
This coroutine job is divided to two subjobs:</br>
The first one decides if there should (or shouldn't) be a living organism in its cell in the next round. A detailed description of the decision making can be found in the 'Assigment description' file attached.
The other part of the job is changing the actual state of the cell based on the decision outcome.
This two subjobs are done intermittently.</br>
the cycle in which this two jobs run is as follows:</br>
1. The cell's coroutine done with the first job and yields back to the scheduler coroutine.
2. When the scheduler decides to let the cell's coroutine run once more, it runs the second subjob, then yielding once more.

This mechanism is done this way so every cell coroutine can decide what it's living organism state should be in the next round based on the last known state of the cells around it.

## Getting Started
### Prerequisites

1. Kubuntu - this program was tested only on kubuntu, but it probably can be ran on any other known nasm and gcc compatible operating systems.
	https://kubuntu.org/getkubuntu/</br>
(The followings are for those who want to compile the files themselves)
2. GNU make
	https://www.gnu.org/software/make/
3. gcc compiler
	via ```sudo apt-get install gcc-4.8``` on ubuntu based os (kubuntu included).
4. nasm compiler
	via ```sudo apt-get install nasm``` on ubuntu based os (kubuntu included).
	
Note: this is how I used to build and run the program. There are many other well-known compilers to compile this assembly file for other types of operating systems.

### Running simulation

1. open terminal and navigate to the program directory
2. Do this step only if simulation rebuilt is needed: type `make` and press enter.
3. type `./gol <filename> <length> <width> <t> <k>` and press enter - you can find a detailed description of the needed parameters in the Assignment description file.
4. enjoy :D.

## Built With

* [GNU make](https://www.gnu.org/software/make/) - A framework used for simple code compilation.
* [gcc](https://gcc.gnu.org/)
* [nasm](http://www.nasm.us/)

## Useful links

* The original source of the assignment: https://www.cs.bgu.ac.il/~caspl162/Assignments/Assignment_3.
* https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
* https://en.wikipedia.org/wiki/Coroutine
* https://en.wikipedia.org/wiki/Yield_(multithreading)
