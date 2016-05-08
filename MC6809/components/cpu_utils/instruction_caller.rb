#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require inspect

from MC6809.components.MC6809data.MC6809_data_utils import MC6809OP_DATA_DICT
from MC6809.components.cpu_utils.Instruction_generator import func_name_from_op_code
from MC6809.components.cpu_utils.instruction_call import PrepagedInstructions
from MC6809.components.cpu6809_trace import InstructionTrace

def opcode (*opcodes)
    """A decorator for opcodes"""
    def decorator (func)
        setattr(func, "_is_opcode", true)
        setattr(func, "_opcodes", opcodes)
        return func
    end
    return decorator
end


class OpCollection < object
    def initialize (cpu)
        @cpu = cpu
        @opcode_dict = {}
        collect_ops()
    end
    
    def get_opcode_dict
        return @opcode_dict
    end
    
    def collect_ops
        # Get the members not from class instance, so that's possible to
        # exclude properties without "activate" them.
        cls = type(@cpu)
        for name, cls_method in inspect.getmembers(cls)
            if name.startswith("_") or isinstance(cls_method, property)
                continue
            end
            
            begin
                opcodes = getattr(cls_method, "_opcodes")
            except AttributeError
                continue
            end
            
            instr_func = getattr(@cpu, name)
            _add_ops(opcodes, instr_func)
        end
    end
    
    def _add_ops (opcodes, instr_func)
end
#         log.debug(sprintf("%20s: %s", 
#             instr_func.__name__, ",".join(["$%x" % c for c in opcodes])
#         ))
        for op_code in opcodes
            assert op_code not in @opcode_dict,\
                sprintf("Opcode $%x (%s) defined more then one time!", 
                    op_code, instr_func.__name__
                end
            end
            )
            
            op_code_data = MC6809OP_DATA_DICT[op_code]
            
            func_name = func_name_from_op_code(op_code)
            
            if @cpu.cfg.trace
                InstructionClass = InstructionTrace
            else
                InstructionClass = PrepagedInstructions
            end
            
            instrution_class = InstructionClass.new(@cpu, instr_func)
            begin
                func = getattr(instrution_class, func_name)
            rescue AttributeError => err
                raise AttributeError.new(sprintf("%s (op code: $%02x)", err, op_code))
            end
            
            @opcode_dict[op_code] = (op_code_data["cycles"], func)
        end
    end
end


if __name__ == "__main__"
    from MC6809.components.cpu6809 import CPU
    from MC6809.tests.test_base import BaseCPUTestCase
    from dragonpy.Dragon32.config import Dragon32Cfg
    from MC6809.components.memory import Memory
    
    cmd_args = BaseCPUTestCase.UNITTEST_CFG_DICT
    cfg = Dragon32Cfg.new(cmd_args)
    memory = Memory.new(cfg)
    cpu = CPU.new(memory, cfg)
    
    for op_code, data in sorted(cpu.opcode_dict.items())
        cycles, func = data
        if op_code > 0xff
            op_code = "$%04x" % op_code
        else
            op_code = "  $%02x" % op_code
        end
        
        print(sprintf("Op %s - cycles: %2i - func: %s", op_code, cycles, func.__name__))
    end
    
    print(" --- END --- ")
end


