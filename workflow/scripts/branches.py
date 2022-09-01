### choose hifiasm mode
def hifiasm_mode_hap1(mode):
    if mode == "hi-c":
        return(str(rules.hifiasm_hic.output.hap1))
    elif mode == "trio":
        return(str(rules.hifiasm_trio.output.hap1))
    elif mode == "default":
        return(str(rules.hifiasm.output.hap1))

def hifiasm_mode_hap2(mode):
    if mode == "hi-c":
        return(str(rules.hifiasm_hic.output.hap2))
    elif mode == "trio":
        return(str(rules.hifiasm_trio.output.hap2))
    elif mode == "default":
        return(str(rules.hifiasm.output.hap2))