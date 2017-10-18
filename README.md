# Coroutines

A simulation of Conway's Game of Life (GOL) with Coroutines.

The development of this simulation was done as part of an assignment in "Computer Architecture" course at Ben-Gurion University in the second semester of 2016.

A detailed description of the simulation can be found in the assignment description attached.

## Gol coroutines 

Wikipedia (link attached below): Coroutines are computer-program components that generalize subroutines for non-preemptive multitasking, by allowing multiple entry points for suspending and resuming execution at certain locations.

Every subroutine has its own stack, flags and register's data.
Every subroutine defines its own phase when it decide to yield.
This simulation is built from 3 types of subroutines: scheduler, printer and cell.
The role of each and every one of them is slightly different.

### Printer

The printer's role is fairly simple, its just prints the current state of the board grid.
After doing so, it yields back to the scheduler coroutine.

### Scheduler

The scheduler's role is about deciding which subroutine will run next among the array of subroutines.
It does so by choosing the next cell's coroutine in a round robin fashion, and after fixed rounds of the cell's coroutines running (as described in details in the Assigment description attached), the scheduler calls the printer's coroutine.
The scheduler holds a structure which pointing to each and every subroutine data holders.
when a subroutine is scheduled for work, its stack, flags and register's data need to be restored. that is done with data holders.

### Cell

In constrant to the other kinds of coroutines mentioned, this type is replicated for each and every cell on the board grid, meaning, each and every cell has its own coroutine with this coroutine type.
This coroutine job is divided to two subjobs:
The first one is deciding which if there should be a living organ in it in the next round. A detailed description of the decision making can be found in the 'Assigment description' file attached.
The other part of the job is changing the actual state of the cell.
This two subjobs are done intermittently. Every time the cell has finished one job it then yields back to the scheduler coroutine, when scheduler decides to let the cell's coroutine run once more it runs the other subjob and then yielding once more. This mechanism is done this way so every cell coroutine can decide what it's living organism state should be in the next round based on the last knwon state of the cells around it.

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

A detailed description can be found in the assignment description file attached.

## Built With

* [GNU make](https://www.gnu.org/software/make/) - A framework used for simple code compilation.
* [gcc](https://gcc.gnu.org/)
* [nasm](http://www.nasm.us/)

## Useful links

* The original source of the assignment: https://www.cs.bgu.ac.il/~caspl162/Assignments/Assignment_3.
* https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life
* https://en.wikipedia.org/wiki/Coroutine
* https://en.wikipedia.org/wiki/Yield_(multithreading)
