#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__



class InstructionBase < object
    def initialize (cpu, instr_func)
        @cpu = cpu
        @instr_func = instr_func
    end
    
    def special (opcode)
        # e.g: RESET and PAGE 1/2
        return instr_func(opcode)
    end
end


