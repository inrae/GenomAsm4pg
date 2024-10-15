rule start_time:
    output: 
        temp(res_path + "/{runid}/runtime.txt")
    priority: 20
    run:
        import time
        start = time.time()
        with open(output[0], "w") as out:
            out.write(str(start))

rule elasped_time:
    input: 
        rules.start_time.output,
        rules.rename_report.output
    output:
        res_path + "/{runid}/p_runtime.{id}.{lin}.txt"
    run:
        import time
        from datetime import timedelta

        with open(input[0], "r") as inp:
            start = inp.read()
        
        end = time.time()
        elapsed_time = end - float(start)
        td = timedelta(seconds=elapsed_time)

        with open(output[0], "w") as out:
            out.write("Runtime (hh:mm:ss): " + str(td))

rule elasped_time_no_purge:
    input: 
        rules.start_time.output,
        rules.rename_no_purge_report.output
    output:
        res_path + "/{runid}/runtime.{id}.{lin}.txt"
    run:
        import time
        from datetime import timedelta

        with open(input[0], "r") as inp:
            start = inp.read()
        
        end = time.time()
        elapsed_time = end - float(start)
        td = timedelta(seconds=elapsed_time)

        with open(output[0], "w") as out:
            out.write("Runtime (hh:mm:ss): " + str(td))


rule elasped_time_trio:
    input: 
        rules.start_time.output,
        rules.rename_report_trio.output
    output:
        res_path + "/{runid}/p_runtime_trio.{id}.{lin}.txt"
    run:
        import time
        from datetime import timedelta

        with open(input[0], "r") as inp:
            start = inp.read()
        
        end = time.time()
        elapsed_time = end - float(start)
        td = timedelta(seconds=elapsed_time)

        with open(output[0], "w") as out:
            out.write("Runtime (hh:mm:ss): " + str(td))

rule elasped_time_trio_no_purge:
    input: 
        rules.start_time.output,
        rules.no_purge_rename_report_trio.output
    output:
        res_path + "/{runid}/runtime_trio.{id}.{lin}.txt"
    run:
        import time
        from datetime import timedelta

        with open(input[0], "r") as inp:
            start = inp.read()
        
        end = time.time()
        elapsed_time = end - float(start)
        td = timedelta(seconds=elapsed_time)

        with open(output[0], "w") as out:
            out.write("Runtime (hh:mm:ss): " + str(td))