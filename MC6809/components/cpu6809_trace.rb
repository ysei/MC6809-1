#!/usr/bin/env python
# coding: utf-8

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    Create trace lines for every OP call.
    
    :copyleft: 2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require sys
require logging

from MC6809.components.MC6809data.MC6809_data_utils import MC6809OP_DATA_DICT
from MC6809.components.cpu_utils.instruction_call import PrepagedInstructions


log = logging.getLogger("DragonPy.cpu6809.trace")


class InstructionTrace < PrepagedInstructions
    def initialize (*args, **kwargs)
        super(InstructionTrace, self).__init__(*args, **kwargs)
        @cfg = @cpu.cfg
        @get_mem_info = @cpu.cfg.mem_info.get_shortest
        
        @_origin_instr_func = @instr_func
        @instr_func = @_call_instr_func
    end
end

#    def __getattribute__(self, attr, *args, **kwargs)
#        if attr not in("__call", "cpu", "memory", "instr_func")
#            return InstructionTrace.__call
#            print attr, args, kwargs
#        return PrepagedInstructions.__getattribute__(self, attr, *args, **kwargs)
#
#    def __call(self, func, *args, **kwargs)
#        print func, args, kwargs
#        raise
    
    def __call_instr_func (opcode, *args, **kwargs)
        # call the op CPU code method
        result = __origin_instr_func(opcode, *args, **kwargs)
        
        if opcode in(0x10, 0x11)
            log.debug("Skip PAGE 2 and PAGE 3 instruction in trace")
            return
        end
        
        op_code_data = MC6809OP_DATA_DICT[opcode]
        
        op_address = @cpu.last_op_address
        
        ob_bytes = op_code_data["bytes"]
        
        op_bytes = "".join([
            "%02x" % value
            for __, value in @cpu.memory.iter_bytes(op_address, op_address + ob_bytes)
        end
        ])
        
        kwargs_info = []
        if "register" in kwargs
            kwargs_info.append(str(kwargs["register"]))
        end
        if "ea" in kwargs
            kwargs_info.append("ea:%04x" % kwargs["ea"])
        end
        if "m" in kwargs
            kwargs_info.append("m:%x" % kwargs["m"])
        end
        
        msg = "%(op_address)04x| %(op_bytes)-11s %(mnemonic)-7s %(kwargs)-19s %(cpu)s | %(cc)s | %(mem)s\n" % {
            "op_address": op_address,
            "op_bytes": op_bytes,
            "mnemonic": op_code_data["mnemonic"],
            "kwargs": " ".join(kwargs_info),
            "cpu": @cpu.get_info,
            "cc": @cpu.get_cc_info(),
            "mem": get_mem_info(op_address)
        end
        }
        sys.stdout.write(msg)
        
        if not op_bytes.startswith("%02x" % opcode)
            @cpu.memory.print_dump(op_address, op_address + ob_bytes)
            @cpu.memory.print_dump(op_address - 10, op_address + ob_bytes + 10)
        end
        assert op_bytes.startswith("%02x" % opcode), sprintf("%s doesn't start with %02x", 
            op_bytes, @opcode
        end
        )
        
        return result
    end
end


#------------------------------------------------------------------------------


def test_run
    require sys
    require os
    require subprocess
    cmd_args = [
        sys.executable,
        os.path.join("..", "DragonPy_CLI.py"),
    end
end
#        "--verbosity", " 1", # hardcode DEBUG ;)
#        "--verbosity", "10", # DEBUG
#        "--verbosity", "20", # INFO
#        "--verbosity", "30", # WARNING
#         "--verbosity", "40", # ERROR
        "--verbosity", "50", # CRITICAL/FATAL
        "--machine", "Dragon32", "run",
    end
end
#        "--machine", "Vectrex", "run",
#        "--max_ops", "1",
        "--trace",
    end
    ]
    print("Startup CLI with: %s" % " ".join(cmd_args[1:]))
    subprocess.Popen.new(cmd_args, cwd="..").wait()
end

if __name__ == "__main__"
    test_run()
end
