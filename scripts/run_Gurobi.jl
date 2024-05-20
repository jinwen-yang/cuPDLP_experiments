using JuMP, Gurobi
import JLD2
import ArgParse

function parse_command_line()
    arg_parse = ArgParse.ArgParseSettings()

    ArgParse.@add_arg_table! arg_parse begin
        "--problem_name"
        help = "The instance to solve."
        arg_type = String
        required = true

        "--tolerance"
        help = "KKT tolerance of the solution"
        arg_type = Float64
        default = 1e-4

        "--time_sec_limit"
        help = "Time limit."
        arg_type = Float64
        default = 3600.0

        "--problem_folder"
        help = "The directory for input instances."
        arg_type = String
        required = true

        "--output_directory"
        help = "The directory for output files."
        arg_type = String
        required = true

        "--gurobi_presolve"
        help = "Use presolve. 0: off; 1: default."
        arg_type = Int64
        default = 1

        "--gurobi_method"
        help = "Method of Gurobi. 0: primal simplex; 1: dual simplex; 2: barrier."
        arg_type = Int64
        required = true

        "--gurobi_threads"
        help = "Threads for Gurobi."
        arg_type = Int64
        required = true
    end

    return ArgParse.parse_args(arg_parse)
end

function main()
    parsed_args = parse_command_line()
    problem_name = parsed_args["problem_name"]
    tolerance = parsed_args["tolerance"]
    time_sec_limit = parsed_args["time_sec_limit"]
    problem_folder = parsed_args["problem_folder"]
    output_directory = parsed_args["output_directory"]
    gurobi_presolve = parsed_args["gurobi_presolve"]
    gurobi_method = parsed_args["gurobi_method"]
    gurobi_threads = parsed_args["gurobi_threads"]
    

    instance_path = joinpath("$(problem_folder)", "$(problem_name).mps")
    model = Model()
    model = read_from_file(instance_path)

    set_optimizer(model, Gurobi.Optimizer)
    set_optimizer_attribute(model, "TimeLimit", time_sec_limit)
    set_optimizer_attribute(model, "OptimalityTol", tolerance)
    set_optimizer_attribute(model, "FeasibilityTol", tolerance)
    set_optimizer_attribute(model, "BarConvTol", tolerance)
    if gurobi_presolve == 0
        set_optimizer_attribute(model, "Presolve", 0)
    end

    # 0: primal simplex; 1: dual simplex; 2: barrier;
    set_optimizer_attribute(model, "Method", gurobi_method)
    if gurobi_method == 2
        set_optimizer_attribute(model, "Crossover", 0) # off
    end
    set_optimizer_attribute(model, "Threads", gurobi_threads)

    optimize!(model)

    res_time = solve_time(model)
    res_term = termination_status(model)

    res = [res_time, res_term]

    JLD2.jldsave(joinpath("$(output_directory)","$(problem_name)_$(tolerance).jld2"); res)
end

main()
