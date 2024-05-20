from ortools.linear_solver import pywraplp
from ortools.linear_solver import linear_solver_pb2
from ortools.linear_solver.python import model_builder

def run(args):
    mps_path = f"{args.problem_folder}/{args.problem_name}.mps"
    model = model_builder.ModelBuilder()
    model.import_from_mps_file(mps_path)
    input_proto = model.export_to_proto()

    solver = pywraplp.Solver.CreateSolver("PDLP")
    solver.LoadModelFromProto(input_proto)
    solver.SetTimeLimit(args.time_sec_limit*1000)
    solver.SetNumThreads(args.num_threads)

    if high_accuracy == 0:
        solver.SetSolverSpecificParametersAsString("termination_criteria {eps_optimal_relative: 1e-4}")
    else:
        solver.SetSolverSpecificParametersAsString("termination_criteria {eps_optimal_relative: 1e-8}")

    status = solver.Solve()

    flag = "NA"
    if status == pywraplp.Solver.OPTIMAL:
        flag = "OPTIMAL"
    elif (status == pywraplp.Solver.INFEASIBLE) or (status == pywraplp.Solver.UNBOUNDED):
        flag = "INFEASIBLE"
    elif status == pywraplp.Solver.NOT_SOLVED:
        flag = "TIME_LIMIT"
    
    res = [flag, f"{solver.iterations()}", f"{solver.wall_time()/1000}"]

    with open(f"{args.output_directory}/{args.problem_name}_{args.num_threads}_{args.high_accuracy}.txt", 'w') as f:
        for line in res:
            f.write(line)
            f.write('\n')

if __name__ == "__main__":
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('--problem_name', type=str)
    parser.add_argument('--time_sec_limit', type=int, default=3600)
    parser.add_argument('--num_threads', type=int, default=1)
    parser.add_argument('--problem_folder', type=str)
    parser.add_argument('--output_directory', type=str)
    parser.add_argument('--high_accuracy', type=int, default=0)

    args = parser.parse_args()
    run(args)
    
