# cuPDLP_experiments

This repository contains code to reproduce the numerical experiments in the paper. 

## Setup

A one-time step is required to set up the necessary packages in Julia on the local machine. Assume the current directory is the working directory.

```shell
$ julia --project -e 'import Pkg; Pkg.instantiate()'
```

OR-Tools/PDLP is used through its Python interface. OR-Tools can be installed as follows:
```shell
$ python -m pip install ortools
```

## Running

All commands below assume that the current directory is the working directory.

### cuPDLP 
```shell
$ julia --project scripts/run_cuPDLP.jl \
--problem_name=PROBLEM_NAME \
--problem_folder=PROBLEM_FOLDER \
--output_directory=OUTPUT_DIRECTORY \
--tolerance=TOLERANCE \
--time_sec_limit=TIME_SEC_LIMIT
```

### Gurobi
```shell
$ julia --project scripts/run_Gurobi.jl \
--problem_name=PROBLEM_NAME \
--problem_folder=PROBLEM_FOLDER \
--output_directory=OUTPUT_DIRECTORY \
--tolerance=TOLERANCE \
--time_sec_limit=TIME_SEC_LIMIT \
--gurobi_presolve=USE_PRESOLVE \
--gurobi_method=GUROBI_METHOD \
--gurobi_threads=GUROBI_THREADS
```

### PDLP (Julia and C++)
```shell
$ julia --project scripts/run_FirstOrderLp.jl \
--problem_name=PROBLEM_NAME \
--problem_folder=PROBLEM_FOLDER \
--output_directory=OUTPUT_DIRECTORY \
--tolerance=TOLERANCE \
--time_sec_limit=TIME_SEC_LIMIT
```

```shell
$ python scripts/run_PDLP.py \
--problem_name=PROBLEM_NAME \
--problem_folder=PROBLEM_FOLDER \
--output_directory=OUTPUT_DIRECTORY \
--high_accuracy=USE_HIGH_ACCURACY \
--time_sec_limit=TIME_SEC_LIMIT \
--num_threads=NUM_THREADS \       
```

