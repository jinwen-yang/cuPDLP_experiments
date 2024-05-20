import FirstOrderLp
import JLD2
using ArgParse

"""
# Returns
A dictionary with the values of the command-line arguments.
"""
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

    instance_path = joinpath("$(problem_folder)", "$(problem_name).mps")
    lp = FirstOrderLp.qps_reader_to_standard_form(instance_path);
    println(problem_name)

    restart_params = FirstOrderLp.construct_restart_parameters(
        FirstOrderLp.ADAPTIVE_NORMALIZED,        # 
        FirstOrderLp.GAP_OVER_DISTANCE_SQUARED,  #
        1000,                                    # restart_frequency_if_fixed
        0.5,                                     # artificial_restart_threshold
        0.1,                                     # sufficient_reduction_for_restart
        0.9,                                     # necessary_reduction_for_restart
        0.5,                                     # primal_weight_update_smoothing
        false,                                   # use_approximate_localized_duality_gap
    )

    warmup_termination_params = FirstOrderLp.construct_termination_criteria(
        eps_optimal_absolute = tolerance,
        eps_optimal_relative = tolerance,
        eps_primal_infeasible = 1.0e-8,
        eps_dual_infeasible = 1.0e-8,
        time_sec_limit = Inf,
        iteration_limit = 100,
        kkt_matrix_pass_limit = Inf,
    )

    warmup_params = FirstOrderLp.PdhgParameters(
        10,
        false,
        1.0,
        1.0,
        true,
        0,
        true,
        40,
        warmup_termination_params,
        restart_params,
        FirstOrderLp.AdaptiveStepsizeParams(0.3,0.6),
    )

    oldstd = stdout
    redirect_stdout(devnull)
    FirstOrderLp.optimize(warmup_params, lp);
    redirect_stdout(oldstd)


    termination_params = FirstOrderLp.construct_termination_criteria(
        eps_optimal_absolute = tolerance,
        eps_optimal_relative = tolerance,
        eps_primal_infeasible = 1.0e-8,
        eps_dual_infeasible = 1.0e-8,
        time_sec_limit = time_sec_limit,
        iteration_limit = typemax(Int32),
        kkt_matrix_pass_limit = Inf,
    )

    params = FirstOrderLp.PdhgParameters(
        10,
        false,
        1.0,
        1.0,
        true,
        2,
        true,
        40,
        termination_params,
        restart_params,
        FirstOrderLp.AdaptiveStepsizeParams(0.3,0.6),
    )

    res = FirstOrderLp.optimize(params, lp)
     
    println()

    JLD2.jldsave(joinpath("$(output_directory)","$(problem_name)_$(tolerance).jld2"); res)
end

main()