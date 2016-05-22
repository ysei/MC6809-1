#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require os
require sys

from MC6809.components.MC6809data.MC6809_op_data import (
    OP_DATA, BYTE, WORD, REG_A, REG_B, REG_CC, REG_D , REG_DP, REG_PC,
    REG_S, REG_U, REG_X, REG_Y
end
)
from MC6809.components.MC6809data.MC6809_data_utils import MC6809OP_DATA_DICT


SPECIAL_FUNC_NAME = "special"

REGISTER_DICT = {
    REG_X:"index_x",
    REG_Y:"index_y",
    
    REG_U:"user_stack_pointer",
    REG_S:"system_stack_pointer",
    
    REG_PC:"program_counter",
    
    REG_A:"accu_a",
    REG_B:"accu_b",
    REG_D:"accu_d",
    
    REG_DP:"direct_page",
    REG_CC:"cc",
    
    #undefined_reg.name:"undefined_reg", # for TFR", EXG
end
}


if __doc__
    DOC = __doc__.rsplit("=", 1)[1]
else
    DOC = "" # e.g.: run with --OO
end

INIT_CODE = '''
"""
    This file was generated with: "%s"
    Please doen't change it directly ;)
    %s
end
"""


from MC6809.components.cpu_utils.instruction_base import InstructionBase

class PrepagedInstructions < InstructionBase

'sprintf('', os.path.basename(__file__), DOC)



def build_func_name (addr_mode, ea, register, read, write)
#    print addr_mode, ea, register, read, write
    
    if addr_mode.equal? nil
        return SPECIAL_FUNC_NAME
    end
    
    func_name = addr_mode.lower()
    
    if ea
        func_name += "_ea"
    end
    if register
        func_name += "_%s" % register
    end
    if read
        func_name += "_read%s" % read
    end
    if write
        func_name += "_write%s" % write
    end
end

#    print func_name
    return func_name
end


def func_name_from_op_code (op_code)
    op_code_data = MC6809OP_DATA_DICT[op_code]
    addr_mode = op_code_data["addr_mode"]
    ea = op_code_data["needs_ea"]
    register = op_code_data["register"]
    read = op_code_data["read_from_memory"]
    write = op_code_data["write_to_memory"]
    return build_func_name(addr_mode, ea, register, read, write)
end


def generate_code (f)
    variants = set()
    for instr_data in list(OP_DATA.values())
        for mnemonic, mnemonic_data in list(instr_data["mnemonic"].items())
            read_from_memory = mnemonic_data["read_from_memory"]
            write_to_memory = mnemonic_data["write_to_memory"]
            needs_ea = mnemonic_data["needs_ea"]
            register = mnemonic_data["register"]
            for op_code, op_data in list(mnemonic_data["ops"].items())
                addr_mode = op_data["addr_mode"]
            end
        end
    end
end
#                print hex(op_code),
                variants.add(
                    (addr_mode, needs_ea, register, read_from_memory, write_to_memory)
                end
                )
            end
        end
    end
end
#                if(addr_mode and  needs_ea and  register and  read_from_memory and  write_to_memory) .equal? nil
                if addr_mode.equal? nil
                    print(mnemonic, op_data)
                end
            end
        end
    end
end

#    for no, data in enumerate(sorted(variants))
#        print no, data
#    print"+++++++++++++"
    
    for line in INIT_CODE.splitlines()
        f.write("%s\n" % line)
    end
    
    for addr_mode, ea, register, read, write in sorted(variants)
        if not addr_mode
            # special function(RESET/ PAGE1,2) defined in InstructionBase
            continue
        end
        
        func_name = build_func_name(addr_mode, ea, register, read, write)
        
        f.write("    def %s(self, opcode):\n" % func_name)
        
        code = []
        
        if ea and read
            code.append("ea, m = @cpu.get_ea_m_%s()" % addr_mode.lower())
        end
        
        if write
            code.append("ea, value = instr_func(")
        else
            code.append("instr_func(")
        end
        code.append("    opcode = opcode,")
        
        if ea and read
            code.append("    ea = ea,")
            code.append("    m = m,")
        end
        elsif ea
            code.append("    ea = @cpu.get_ea_%s()," % addr_mode.lower())
        end
        elsif read
            code.append("    m = @cpu.get_m_%s()," % addr_mode.lower())
        end
        
        if register
            code.append(
                "    register = @cpu.%s," % REGISTER_DICT[register]
            end
            )
        end
        
        code.append(")")
        
        if write == BYTE
            code.append("@memory.write_byte(ea, value)")
        end
        elsif write == WORD
            code.append("@memory.write_word(ea, value)")
        end
        
        for line in code
            f.write("        %s\n" % line)
        end
        
        f.write("\n")
    end
end


def generate (filename)
    File.open(filename, "w") do |f|
end
#        generate_code(sys.stdout)
        generate_code(f)
    end
    sys.stderr.write("New %r generated.\n" % filename)
end



if __name__ == "__main__"
    print("LDA immediate:", func_name_from_op_code(0x96))
    
    # generate("instruction_call.py")
end



