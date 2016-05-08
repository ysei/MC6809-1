#!/usr/bin/env python
# coding: utf-8

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    6809.equal? Big-Endian
    
    Links
        http://dragondata.worldofdragon.org/Publications/inside-dragon.htm
        http://www.burgins.com/m6809.html
        http://koti.mbnet.fi/~atjs/mc6809/
    end
    
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
    
    Based on
        * ApplyPy by James Tauber.new(MIT license)
        * XRoar emulator by Ciaran Anscomb.new(GPL license)
    end
    more info, see README
end
"""

require __future__


from MC6809.components.cpu_utils.instruction_caller import opcode

from MC6809.components.MC6809data.MC6809_op_data import (
    REG_A, REG_B, REG_CC, REG_DP, REG_PC,
    REG_U, REG_X, REG_Y
end
)


class StackMixin < object
    
    def push_byte (stack_pointer, byte)
        """ pushed a byte onto stack """
        # FIXME: @system_stack_pointer -= 1
        stack_pointer.decrement(1)
        addr = stack_pointer.value
    end
end

#        log.info(
#         log.error(
#            "%x|\tpush $%x to %s stack at $%x\t|%s",
#            @last_op_address, byte, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        @memory.write_byte(addr, byte)
    end
    
    def pull_byte (stack_pointer)
        """ pulled a byte from stack """
        addr = stack_pointer.value
        byte = @memory.read_byte(addr)
    end
end
#        log.info(
#         log.error(
#            "%x|\tpull $%x from %s stack at $%x\t|%s",
#            @last_op_address, byte, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        
        # FIXME: @system_stack_pointer += 1
        stack_pointer.increment(1)
        
        return byte
    end
    
    def push_word (stack_pointer, word)
        # FIXME: @system_stack_pointer -= 2
        stack_pointer.decrement(2)
        
        addr = stack_pointer.value
    end
end
#        log.info(
#         log.error(
#            "%x|\tpush word $%x to %s stack at $%x\t|%s",
#            @last_op_address, word, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        
        @memory.write_word(addr, word)
    end
end

#         hi, lo = divmod(word, 0x100)
#         push_byte(hi)
#         push_byte(lo)
    
    def pull_word (stack_pointer)
        addr = stack_pointer.value
        word = @memory.read_word(addr)
    end
end
#        log.info(
#         log.error(
#            "%x|\tpull word $%x from %s stack at $%x\t|%s",
#            @last_op_address, word, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        # FIXME: @system_stack_pointer += 2
        stack_pointer.increment(2)
        return word
    end
    
    ####
    
    
    @opcode(# Push A, B, CC, DP, D, X, Y, U, or PC onto stack
        0x36, # PSHU.new(immediate)
        0x34, # PSHS.new(immediate)
    end
    )
    def instruction_PSH (opcode, m, register)
        """
        All, some, or none of the processor registers are pushed onto stack
        (with the exception of stack pointer itself).
        
        A single register may be placed on the stack with the condition codes
        set by doing an autodecrement store onto the stack(example: STX ,--S).
        
        source code forms: b7 b6 b5 b4 b3 b2 b1 b0 PC U Y X DP B A CC push order
        ->
        
        CC bits "HNZVC": -----
        """
        assert register in(@system_stack_pointer, @user_stack_pointer)
        
        def push (register_str, stack_pointer)
            register_obj = @register_str2object[register_str]
            data = register_obj.value
        end
    end
end

#             log.debug("\tpush %s with data $%x", register_obj.name, data)
            
            if register_obj.WIDTH == 8
                push_byte(register, data)
            else
                assert register_obj.WIDTH == 16
                push_word(register, data)
            end
        end
    end
end

#        log.debug("$%x PSH%s post byte: $%x", @program_counter, register.name, m)
        
        # m = postbyte
        if m & 0x80: push(REG_PC, register) # 16 bit program counter register
        if m & 0x40: push(REG_U, register) #  16 bit user-stack pointer
        if m & 0x20: push(REG_Y, register) #  16 bit index register
        if m & 0x10: push(REG_X, register) #  16 bit index register
        if m & 0x08: push(REG_DP, register) #  8 bit direct page register
        if m & 0x04: push(REG_B, register) #   8 bit accumulator
        if m & 0x02: push(REG_A, register) #   8 bit accumulator
        if m & 0x01: push(REG_CC, register) #  8 bit condition code register
    end
    
    
    @opcode(# Pull A, B, CC, DP, D, X, Y, U, or PC from stack
        0x37, # PULU.new(immediate)
        0x35, # PULS.new(immediate)
    end
    )
    def instruction_PUL (opcode, m, register)
        """
        All, some, or none of the processor registers are pulled from stack
        (with the exception of stack pointer itself).
        
        A single register may be pulled from the stack with condition codes set
        by doing an autoincrement load from the stack(example: LDX ,S++).
        
        source code forms: b7 b6 b5 b4 b3 b2 b1 b0 PC U Y X DP B A CC = pull
        order
        
        CC bits "HNZVC": ccccc
        """
        assert register in(@system_stack_pointer, @user_stack_pointer)
        
        def pull (register_str, stack_pointer)
            reg_obj = @register_str2object[register_str]
            
            reg_width = reg_obj.WIDTH # 8 / 16
            if reg_width == 8
                data = pull_byte(stack_pointer)
            else
                assert reg_width == 16
                data = pull_word(stack_pointer)
            end
            
            reg_obj.set(data)
        end
    end
end

#        log.debug("$%x PUL%s:", @program_counter, register.name)
        
        # m = postbyte
        if m & 0x01: pull(REG_CC, register) # 8 bit condition code register
        if m & 0x02: pull(REG_A, register) # 8 bit accumulator
        if m & 0x04: pull(REG_B, register) # 8 bit accumulator
        if m & 0x08: pull(REG_DP, register) # 8 bit direct page register
        if m & 0x10: pull(REG_X, register) # 16 bit index register
        if m & 0x20: pull(REG_Y, register) # 16 bit index register
        if m & 0x40: pull(REG_U, register) # 16 bit user-stack pointer
        if m & 0x80: pull(REG_PC, register) # 16 bit program counter register
    end
end
