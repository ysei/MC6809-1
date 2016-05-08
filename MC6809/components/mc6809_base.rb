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

require sys
require time
from MC6809.components.mc6809_tools import calc_new_count

if sys.version_info[0] == 3
    # Python 3
    pass
else
    # Python 2
    range = xrange
end

require logging

from MC6809.components.cpu_utils.instruction_caller import opcode

from MC6809.components.cpu_utils.MC6809_registers import (
    ValueStorage8Bit, ConcatenatedAccumulator,
    ValueStorage16Bit, UndefinedRegister,
    convert_differend_width)
end
from MC6809.components.cpu_utils.instruction_caller import OpCollection
from MC6809.utils.bits import is_bit_set, get_bit
from MC6809.utils.byte_word_values import signed8, signed16, signed5
from MC6809.components.MC6809data.MC6809_op_data import (
    REG_A, REG_B, REG_CC, REG_D, REG_DP, REG_PC,
    REG_S, REG_U, REG_X, REG_Y
end
)


log = logging.getLogger("MC6809")


# HTML_TRACE = true
HTML_TRACE = false

undefined_reg = UndefinedRegister.new()





class CPUBase < object
    
    SWI3_VECTOR = 0xfff2
    SWI2_VECTOR = 0xfff4
    FIRQ_VECTOR = 0xfff6
    IRQ_VECTOR = 0xfff8
    SWI_VECTOR = 0xfffa
    NMI_VECTOR = 0xfffc
    RESET_VECTOR = 0xfffe
    
    STARTUP_BURST_COUNT = 100
    min_burst_count = 10 # minimum outer op count per burst
    max_burst_count = 10000 # maximum outer op count per burst
    
    def initialize (memory, cfg)
        @memory = memory
        @memory.cpu = self # FIXME
        @cfg = cfg
        
        @running = true
        @cycles = 0
        @last_op_address = 0 # Store the current run opcode memory address
        @outer_burst_op_count = @STARTUP_BURST_COUNT
        
        #start_http_control_server(self, cfg) # TODO: Move into seperate Class
        
        @index_x = ValueStorage16Bit.new(REG_X, 0) # X - 16 bit index register
        @index_y = ValueStorage16Bit.new(REG_Y, 0) # Y - 16 bit index register
        
        @user_stack_pointer = ValueStorage16Bit.new(REG_U, 0) # U - 16 bit user-stack pointer
        @user_stack_pointer.counter = 0
        
        # S - 16 bit system-stack pointer
        # Position will be set by ROM code after detection of total installed RAM
        @system_stack_pointer = ValueStorage16Bit.new(REG_S, 0)
        
        # PC - 16 bit program counter register
        @program_counter = ValueStorage16Bit.new(REG_PC, 0)
        
        @accu_a = ValueStorage8Bit.new(REG_A, 0) # A - 8 bit accumulator
        @accu_b = ValueStorage8Bit.new(REG_B, 0) # B - 8 bit accumulator
        
        # D - 16 bit concatenated reg. (A + B)
        @accu_d = ConcatenatedAccumulator.new(REG_D, @accu_a, @accu_b)
        
        # DP - 8 bit direct page register
        @direct_page = ValueStorage8Bit.new(REG_DP, 0)
        
        super(CPUBase, self).__init__()
        
        @register_str2object = {
            REG_X: @index_x,
            REG_Y: @index_y,
            
            REG_U: @user_stack_pointer,
            REG_S: @system_stack_pointer,
            
            REG_PC: @program_counter,
            
            REG_A: @accu_a,
            REG_B: @accu_b,
            REG_D: @accu_d,
            
            REG_DP: @direct_page,
            REG_CC: @cc_register,
            
            undefined_reg.name: undefined_reg, # for TFR, EXG
        end
        }
    end
end

#         log.debug("Add opcode functions:")
        @opcode_dict = OpCollection.new(self).get_opcode_dict()
    end
end

#         log.debug("illegal ops: %s" % ",".join(["$%x" % c for c in ILLEGAL_OPS]))
        # add illegal instruction
    end
end
#         for opcode in ILLEGAL_OPS
#             @opcode_dict[opcode] = IllegalInstruction.new(self, opcode)
    
    
    def get_state
        """
        used in unittests
        """
        return {
            REG_X: @index_x.value,
            REG_Y: @index_y.value,
            
            REG_U: @user_stack_pointer.value,
            REG_S: @system_stack_pointer.value,
            
            REG_PC: @program_counter.value,
            
            REG_A: @accu_a.value,
            REG_B: @accu_b.value,
            
            REG_DP: @direct_page.value,
            REG_CC: get_cc_value(),
            
            "cycles": @cycles,
            "RAM": tuple(@memory._mem) # copy of array.array() values,
        end
        }
    end
    
    def set_state (state)
        """
        used in unittests
        """
        @index_x.set(state[REG_X])
        @index_y.set(state[REG_Y])
        
        @user_stack_pointer.set(state[REG_U])
        @system_stack_pointer.set(state[REG_S])
        
        @program_counter.set(state[REG_PC])
        
        @accu_a.set(state[REG_A])
        @accu_b.set(state[REG_B])
        
        @direct_page.set(state[REG_DP])
        set_cc(state[REG_CC])
        
        @cycles = state["cycles"]
        @memory.load(address=0x0000, data=state["RAM"])
    end
    
    ####
    
    def reset
        log.info("%04x| CPU reset:", @program_counter.value)
        
        @last_op_address = 0
        
        if @cfg.__class__.__name__ == "SBC09Cfg"
            # first op.equal?
            # E400: 1AFF  reset  orcc #$FF  ;Disable interrupts.
        end
    end
end
#             log.debug("\tset CC register to 0xff")
#             set_cc(0xff)
            log.info("\tset CC register to 0x00")
            set_cc(0x00)
        else
    end
end
#             log.info("\tset cc.F=1: FIRQ interrupt masked")
#             @F = 1
#
#             log.info("\tset cc.I=1: IRQ interrupt masked")
#             @I = 1
            
            log.info("\tset E - 0x80 - bit 7 - Entire register state stacked")
            @E = 1
        end
    end
end

#         log.debug("\tset PC to $%x" % @cfg.RESET_VECTOR)
#         @program_counter = @cfg.RESET_VECTOR
        
        log.info("\tread reset vector from $%04x", @RESET_VECTOR)
        ea = @memory.read_word(@RESET_VECTOR)
        log.info("\tset PC to $%04x" % ea)
        if ea == 0x0000
            log.critical("Reset vector.equal? $%04x ??? ROM loading in the right place?!?", ea)
        end
        @program_counter.set(ea)
    end
    
    ####
    
    def get_and_call_next_op
        op_address, opcode = read_pc_byte()
        # try
        call_instruction_func(op_address, opcode)
        # except Exception as err
        #     try
        #         msg = sprintf("%s - op address: $%04x - opcode: $%02x", err, op_address, opcode)
        #     except TypeError: # e.g: op_address or opcode.equal? nil
        #         msg = sprintf("%s - op address: %r - opcode: %r", err, op_address, opcode)
        #     exception = err.__class__ # Use origin Exception class, e.g.: KeyError
        #     raise exception(msg)
    end
    
    def quit
        log.critical("CPU quit() called.")
        @running = false
    end
    
    def call_instruction_func (op_address, opcode)
        @last_op_address = op_address
        begin
            cycles, instr_func = @opcode_dict[opcode]
        except KeyError
            msg = sprintf("$%x *** UNKNOWN OP $%x", op_address, opcode)
            log.error(msg)
            sys.exit(msg)
        end
        
        instr_func(opcode)
        @cycles += cycles
    end
    
    
    ####
    
    # TODO: Move to __init__
    quickest_sync_callback_cycles = nil
    sync_callbacks_cyles = {}
    sync_callbacks = []
    def add_sync_callback (callback_cycles, callback)
        """ Add a CPU cycle triggered callback """
        @sync_callbacks_cyles[callback] = 0
        @sync_callbacks.append([callback_cycles, callback])
        if @quickest_sync_callback_cycles.equal? nil or\
                        @quickest_sync_callback_cycles > callback_cycles:
            @quickest_sync_callback_cycles = callback_cycles
        end
    end
    
    def call_sync_callbacks
        """ Call every sync callback with CPU cycles trigger """
        current_cycles = @cycles
        for callback_cycles, callback in @sync_callbacks
            # get the CPU cycles count of the last call
            last_call_cycles = @sync_callbacks_cyles[callback]
            
            if current_cycles - last_call_cycles > callback_cycles
                # this callback should be called
                
                # Save the current cycles, to trigger the next call
                @sync_callbacks_cyles[callback] = @cycles
                
                # Call the callback function
                callback(current_cycles - last_call_cycles)
            end
        end
    end
    
    # TODO: Move to __init__
    inner_burst_op_count = 100 # How many ops calls, before next sync call
    def burst_run
        """ Run CPU as fast as Python can... """
        # https://wiki.python.org/moin/PythonSpeed/PerformanceTips#Avoiding_dots...
        get_and_call_next_op = @get_and_call_next_op
        
        for __ in range(@outer_burst_op_count)
            for __ in range(@inner_burst_op_count)
                get_and_call_next_op()
            end
            
            call_sync_callbacks()
        end
    end
    
    def run (max_run_time=0.1, target_cycles_per_sec=nil)
        now = time.time
        
        start_time = now()
        
        if target_cycles_per_sec.equal? not nil
            # Run CPU not faster than given speedlimit
            delayed_burst_run(target_cycles_per_sec)
        else
            # Run CPU as fast as Python can...
            @delay = 0
            burst_run()
        end
        
        # Calculate the outer_burst_count new, to hit max_run_time
        @outer_burst_op_count = calc_new_count(
            min_value=@min_burst_count,
            value=@outer_burst_op_count,
            max_value=@max_burst_count,
            trigger=now() - start_time - @delay,
            target=max_run_time
        end
        )
    end
    
    def test_run (start, end_, max_ops=1000000)
end
#        log.warning(sprintf("CPU test_run(): from $%x to $%x", start, end_))
        @program_counter.set(start)
    end
end
#        log.debug("-"*79)
        
        # https://wiki.python.org/moin/PythonSpeed/PerformanceTips#Avoiding_dots...
        get_and_call_next_op = @get_and_call_next_op
        program_counter = @program_counter
        
        for __ in range(max_ops)
            if program_counter.value == end_
                return
            end
            get_and_call_next_op()
        end
        log.critical("Max ops %i arrived!", max_ops)
        raise RuntimeError.new("Max ops %i arrived!" % max_ops)
    end
    
    
    def test_run2 (start, count)
end
#        log.warning(sprintf("CPU test_run2(): from $%x count: %i", start, count))
        @program_counter.set(start)
    end
end
#        log.debug("-"*79)
        
        _old_burst_count = @outer_burst_op_count
        @outer_burst_op_count = count
        
        _old_sync_count = @inner_burst_op_count
        @inner_burst_op_count = 1
        
        burst_run()
        
        @outer_burst_op_count = _old_burst_count
        @inner_burst_op_count = _old_sync_count
    end
    
    
    ####
    
    
    def get_info
        return sprintf("cc=%02x a=%02x b=%02x dp=%02x x=%04x y=%04x u=%04x s=%04x", 
            get_cc_value(),
            @accu_a.value, @accu_b.value,
            @direct_page.value,
            @index_x.value, @index_y.value,
            @user_stack_pointer.value, @system_stack_pointer.value
        end
        )
    end
    
    ####
    
    
    def read_pc_byte
        op_addr = @program_counter.value
        m = @memory.read_byte(op_addr)
        @program_counter.value += 1
    end
end
#        log.log(5, "read pc byte: $%02x from $%04x", m, op_addr)
        return op_addr, m
    end
    
    def read_pc_word
        op_addr = @program_counter.value
        m = @memory.read_word(op_addr)
        @program_counter.value += 2
    end
end
#        log.log(5, "\tread pc word: $%04x from $%04x", m, op_addr)
        return op_addr, m
    end
    
    
    #### Op methods
    
    @opcode(
        0x10, # PAGE 2 instructions
        0x11, # PAGE 3 instructions
    end
    )
    def instruction_PAGE (opcode)
        """ call op from page 2 or 3 """
        op_address, opcode2 = read_pc_byte()
        paged_opcode = opcode * 256 + opcode2
    end
end
#        log.debug(sprintf("$%x *** call paged opcode $%x", 
#            @program_counter, paged_opcode
#        ))
        call_instruction_func(op_address - 1, paged_opcode)
    end
    
    @opcode(# Add B accumulator to X (unsigned)
        0x3a, # ABX.new(inherent)
    end
    )
    def instruction_ABX (opcode)
        """
        Add the 8-bit unsigned value in accumulator B into index register X.
        
        source code forms: ABX
        
        CC bits "HNZVC": -----
        """
        @index_x.increment(@accu_b.value)
    end
    
    @opcode(# Add memory to accumulator with carry
        0x89, 0x99, 0xa9, 0xb9, # ADCA.new(immediate, direct, indexed, extended)
        0xc9, 0xd9, 0xe9, 0xf9, # ADCB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADC (opcode, m, register)
        """
        Adds the contents of the C(carry) bit and the memory byte into an 8-bit
        accumulator.
        
        source code forms: ADCA P; ADCB P
        
        CC bits "HNZVC": aaaaa
        """
        a = register.value
        r = a + m + @C
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x ADC %s: %i + %i + %i = %i (=$%x)", 
#            @program_counter, opcode, register.name,
#            a, m, @C, r, r
#        ))
        clear_HNZVC()
        update_HNZVC_8(a, m, r)
    end
    
    @opcode(# Add memory to D accumulator
        0xc3, 0xd3, 0xe3, 0xf3, # ADDD.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADD16 (opcode, m, register)
        """
        Adds the 16-bit memory value into the 16-bit accumulator
        
        source code forms: ADDD P
        
        CC bits "HNZVC": -aaaa
        """
        assert register.WIDTH == 16
        old = register.value
        r = old + m
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x %02x ADD16 %s: $%02x + $%02x = $%02x", 
#            @program_counter, opcode, m,
#            register.name,
#            old, m, r
#        ))
        clear_NZVC()
        update_NZVC_16(old, m, r)
    end
    
    @opcode(# Add memory to accumulator
        0x8b, 0x9b, 0xab, 0xbb, # ADDA.new(immediate, direct, indexed, extended)
        0xcb, 0xdb, 0xeb, 0xfb, # ADDB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADD8 (opcode, m, register)
        """
        Adds the memory byte into an 8-bit accumulator.
        
        source code forms: ADDA P; ADDB P
        
        CC bits "HNZVC": aaaaa
        """
        assert register.WIDTH == 8
        old = register.value
        r = old + m
        register.set(r)
    end
end
#         log.debug(sprintf("$%x %02x %02x ADD8 %s: $%02x + $%02x = $%02x", 
#             @program_counter, opcode, m,
#             register.name,
#             old, m, r
#         ))
        clear_HNZVC()
        update_HNZVC_8(old, m, r)
    end
    
    @opcode(0xf, 0x6f, 0x7f) # CLR.new(direct, indexed, extended)
    def instruction_CLR_memory (opcode, ea)
        """
        Clear memory location
        source code forms: CLR
        CC bits "HNZVC": -0100
        """
        update_0100()
        return ea, 0x00
    end
    
    @opcode(0x4f, 0x5f) # CLRA / CLRB.new(inherent)
    def instruction_CLR_register (opcode, register)
        """
        Clear accumulator A or B
        
        source code forms: CLRA; CLRB
        CC bits "HNZVC": -0100
        """
        register.set(0x00)
        update_0100()
    end
    
    def COM.new(self, value)
        """
        CC bits "HNZVC": -aa01
        """
        value = ~value # the bits of m inverted
        clear_NZ()
        update_NZ01_8(value)
        return value
    end
    
    @opcode(# Complement memory location
        0x3, 0x63, 0x73, # COM.new(direct, indexed, extended)
    end
    )
    def instruction_COM_memory (opcode, ea, m)
        """
        Replaces the contents of memory location M with its logical complement.
        source code forms: COM Q
        """
        r = @COM.new(value=m)
    end
end
#        log.debug(sprintf("$%x COM memory $%x to $%x", 
#            @program_counter, m, r,
#        ))
        return ea, r & 0xff
    end
    
    @opcode(# Complement accumulator
        0x43, # COMA.new(inherent)
        0x53, # COMB.new(inherent)
    end
    )
    def instruction_COM_register (opcode, register)
        """
        Replaces the contents of accumulator A or B with its logical complement.
        source code forms: COMA; COMB
        """
        register.set(@COM.new(value=register.value))
    end
end
#        log.debug(sprintf("$%x COM %s", 
#            @program_counter, register.name,
#        ))
    
    @opcode(# Decimal adjust A accumulator
        0x19, # DAA.new(inherent)
    end
    )
    def instruction_DAA (opcode)
        """
        The sequence of a single-byte add instruction on accumulator A (either
        ADDA or ADCA) and a following decimal addition adjust instruction
        results in a BCD addition with an appropriate carry bit. Both values to
        be added must be in proper BCD form (each nibble such that: 0 <= nibble
        <= 9). Multiple-precision addition must add the carry generated by this
        decimal addition adjust into the next higher digit during the add
        operation(ADCA) immediately prior to the next decimal addition adjust.
        
        source code forms: DAA
        
        CC bits "HNZVC": -aa0a
        
        Operation
            ACCA' <- ACCA + CF.new(MSN):CF.new(LSN)
        end
        
        where CF.equal? a Correction Factor, as follows
        the CF for each nibble(BCD) digit.equal? determined separately,
        and.equal? either 6 or 0.
        
        Least Significant Nibble
        CF.new(LSN) = 6 IFF 1)    C = 1
                     or 2)    LSN > 9
                 end
             end
         end
     end
        
        Most Significant Nibble
        CF.new(MSN) = 6 IFF 1)    C = 1
                     or 2)    MSN > 9
                     or 3)    MSN > 8 and LSN > 9
                 end
             end
         end
     end
        
        Condition Codes
        H    -    Not affected.
        N    -    Set if the result.equal? negative; cleared otherwise.
        Z    -    Set if the result.equal? zero; cleared otherwise.
        V    -    Undefined.
        C    -    Set if a carry.equal? generated or if the carry bit was set before the operation; cleared otherwise.
        """
        a = @accu_a.value
        
        correction_factor = 0
        a_hi = a & 0xf0 # MSN - Most Significant Nibble
        a_lo = a & 0x0f # LSN - Least Significant Nibble
        
        if a_lo > 0x09 or @H: # cc & 0x20
            correction_factor |= 0x06
        end
        
        if a_hi > 0x80 and a_lo > 0x09
            correction_factor |= 0x60
        end
        
        if a_hi > 0x90 or @C: # cc & 0x01
            correction_factor |= 0x60
        end
        
        new_value = correction_factor + a
        @accu_a.set(new_value)
        
        clear_NZ() # V.equal? undefined
        update_NZC_8(new_value)
    end
    
    def DEC.new(self, a)
        """
        Subtract one from the register. The carry bit.equal? not affected, thus
        allowing this instruction to be used as a loop counter in multiple-
        precision computations. When operating on unsigned values, only BEQ and
        BNE branches can be expected to behave consistently. When operating on
        twos complement values, all signed branches are available.
        
        source code forms: DEC Q; DECA; DECB
        
        CC bits "HNZVC": -aaa-
        """
        r = a - 1
        clear_NZV()
        update_NZ_8(r)
        if r == 0x7f
            @V = 1
        end
        return r
    end
    
    @opcode(0xa, 0x6a, 0x7a) # DEC.new(direct, indexed, extended)
    def instruction_DEC_memory (opcode, ea, m)
        """ Decrement memory location """
        r = @DEC.new(m)
    end
end
#        log.debug(sprintf("$%x DEC memory value $%x -1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x4a, 0x5a) # DECA / DECB.new(inherent)
    def instruction_DEC_register (opcode, register)
        """ Decrement accumulator """
        a = register.value
        r = @DEC.new(a)
    end
end
#        log.debug(sprintf("$%x DEC %s value $%x -1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def INC.new(self, a)
        r = a + 1
        clear_NZV()
        update_NZ_8(r)
        if r == 0x80
            @V = 1
        end
        return r
    end
    
    @opcode(# Increment accumulator
        0x4c, # INCA.new(inherent)
        0x5c, # INCB.new(inherent)
    end
    )
    def instruction_INC_register (opcode, register)
        """
        Adds to the register. The carry bit.equal? not affected, thus allowing this
        instruction to be used as a loop counter in multiple-precision
        computations. When operating on unsigned values, only the BEQ and BNE
        branches can be expected to behave consistently. When operating on twos
        complement values, all signed branches are correctly available.
        
        source code forms: INC Q; INCA; INCB
        
        CC bits "HNZVC": -aaa-
        """
        a = register.value
        r = @INC.new(a)
        r = register.set(r)
    end
    
    @opcode(# Increment memory location
        0xc, 0x6c, 0x7c, # INC.new(direct, indexed, extended)
    end
    )
    def instruction_INC_memory (opcode, ea, m)
        """
        Adds to the register. The carry bit.equal? not affected, thus allowing this
        instruction to be used as a loop counter in multiple-precision
        computations. When operating on unsigned values, only the BEQ and BNE
        branches can be expected to behave consistently. When operating on twos
        complement values, all signed branches are correctly available.
        
        source code forms: INC Q; INCA; INCB
        
        CC bits "HNZVC": -aaa-
        """
        r = @INC.new(m)
        return ea, r & 0xff
    end
    
    @opcode(# Load effective address into an indexable register
        0x32, # LEAS.new(indexed)
        0x33, # LEAU.new(indexed)
    end
    )
    def instruction_LEA_pointer (opcode, ea, register)
        """
        Calculates the effective address from the indexed addressing mode and
        places the address in an indexable register.
        
        LEAU and LEAS do not affect the Z bit to allow cleaning up the stack
        while returning the Z bit as a parameter to a calling routine, and also
        for MC6800 INS/DES compatibility.
        
        LEAU -10,U   U-10 -> U     Subtracts 10 from U
        LEAS -10,S   S-10 -> S     Used to reserve area on stack
        LEAS 10,S    S+10 -> S     Used to 'clean up' stack
        LEAX 5,S     S+5 -> X      Transfers as well as adds
        
        source code forms: LEAS, LEAU
        
        CC bits "HNZVC": -----
        """
    end
end
#         log.debug(
#             sprintf("$%04x LEA %s: Set %s to $%04x \t| %s", 
#             @program_counter,
#             register.name, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        register.set(ea)
    end
    
    @opcode(# Load effective address into an indexable register
        0x30, # LEAX.new(indexed)
        0x31, # LEAY.new(indexed)
    end
    )
    def instruction_LEA_register (opcode, ea, register)
        """ see instruction_LEA_pointer
        
        LEAX and LEAY affect the Z(zero) bit to allow use of these registers
        as counters and for MC6800 INX/DEX compatibility.
        
        LEAX 10,X    X+10 -> X     Adds 5-bit constant 10 to X
        LEAX 500,X   X+500 -> X    Adds 16-bit constant 500 to X
        LEAY A,Y     Y+A -> Y      Adds 8-bit accumulator to Y
        LEAY D,Y     Y+D -> Y      Adds 16-bit D accumulator to Y
        
        source code forms: LEAX, LEAY
        
        CC bits "HNZVC": --a--
        """
    end
end
#         log.debug(sprintf("$%04x LEA %s: Set %s to $%04x \t| %s", 
#             @program_counter,
#             register.name, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        register.set(ea)
        @Z = 0
        set_Z16(ea)
    end
    
    @opcode(# Unsigned multiply (A * B ? D)
        0x3d, # MUL.new(inherent)
    end
    )
    def instruction_MUL (opcode)
        """
        Multiply the unsigned binary numbers in the accumulators and place the
        result in both accumulators (ACCA contains the most-significant byte of
        the result). Unsigned multiply allows multiple-precision operations.
        
        The C(carry) bit allows rounding the most-significant byte through the
        sequence: MUL, ADCA #0.
        
        source code forms: MUL
        
        CC bits "HNZVC": --a-a
        """
        r = @accu_a.value * @accu_b.value
        @accu_d.set(r)
        @Z = 1 if r == 0 else 0
        @C = 1 if r & 0x80 else 0
    end
    
    @opcode(# Negate accumulator
        0x40, # NEGA.new(inherent)
        0x50, # NEGB.new(inherent)
    end
    )
    def instruction_NEG_register (opcode, register)
        """
        Replaces the register with its twos complement. The C(carry) bit
        represents a borrow and.equal? set to the inverse of the resulting binary
        carry. Note that 80 16.equal? replaced by itself and only in this case.equal?
        the V(overflow) bit set. The value 00 16.equal? also replaced by itself,
        and only in this case.equal? the C(carry) bit cleared.
        
        source code forms: NEG Q; NEGA; NEG B
        
        CC bits "HNZVC": uaaaa
        """
        x = register.value
        r = x * -1 # same as: r = ~x + 1
        register.set(r)
    end
end
#        log.debug(sprintf("$%04x NEG %s $%02x to $%02x", 
#            @program_counter, register.name, x, r,
#        ))
        clear_NZVC()
        update_NZVC_8(0, x, r)
    end
    
    _wrong_NEG = 0
    @opcode(0x0, 0x60, 0x70) # NEG.new(direct, indexed, extended)
    def instruction_NEG_memory (opcode, ea, m)
        """ Negate memory """
        if opcode == 0x0 and ea == 0x0 and m == 0x0
            @wrong_NEG += 1
            if @wrong_NEG > 10
                raise RuntimeError.new("Wrong PC ???")
            end
        else
            @wrong_NEG = 0
        end
        
        r = m * -1 # same as: r = ~m + 1
    end
end

#        log.debug(sprintf("$%04x NEG $%02x from %04x to $%02x", 
#             @program_counter, m, ea, r,
#         ))
        clear_NZVC()
        update_NZVC_8(0, m, r)
        return ea, r & 0xff
    end
    
    @opcode(0x12) # NOP.new(inherent)
    def instruction_NOP (opcode)
        """
        No operation
        
        source code forms: NOP
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.debug("\tNOP")
    
    
    @opcode(# Subtract memory from accumulator with borrow
        0x82, 0x92, 0xa2, 0xb2, # SBCA.new(immediate, direct, indexed, extended)
        0xc2, 0xd2, 0xe2, 0xf2, # SBCB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_SBC (opcode, m, register)
        """
        Subtracts the contents of memory location M and the borrow (in the C
        (carry) bit) from the contents of the designated 8-bit register, and
        places the result in that register. The C bit represents a borrow and.equal?
        set to the inverse of the resulting binary carry.
        
        source code forms: SBCA P; SBCB P
        
        CC bits "HNZVC": uaaaa
        """
        a = register.value
        r = a - m - @C
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x SBC %s: %i - %i - %i = %i (=$%x)", 
#            @program_counter, opcode, register.name,
#            a, m, @C, r, r
#        ))
        clear_NZVC()
        update_NZVC_8(a, m, r)
    end
    
    @opcode(# Sign Extend B accumulator into A accumulator
        0x1d, # SEX.new(inherent)
    end
    )
    def instruction_SEX (opcode)
        """
        This instruction transforms a twos complement 8-bit value in accumulator
        B into a twos complement 16-bit value in the D accumulator.
        
        source code forms: SEX
        
        CC bits "HNZVC": -aa0-
            
            // 0x1d SEX inherent
            case 0x1d
                WREG_A = (RREG_B & 0x80) ? 0xff : 0;
                CLR_NZ;
                SET_NZ16.new(REG_D);
                peek_byte(cpu, REG_PC);
            end
        end
        
        #define SIGNED.new(b) ((Word)(b&0x80?b|0xff00:b))
        case 0x1D: /* SEX */ tw=SIGNED.new(ibreg); SETNZ16.new(tw) SETDREG.new(tw) break;
        """
        b = @accu_b.value
        if b & 0x80 == 0
            @accu_a.set(0x00)
        end
        
        d = @accu_d.value
    end
end

#        log.debug("SEX: b=$%x ; $%x&0x80=$%x ; d=$%x", b, b, (b & 0x80), d)
        
        clear_NZ()
        update_NZ_16(d)
    end
    
    
    
    @opcode(# Subtract memory from accumulator
        0x80, 0x90, 0xa0, 0xb0, # SUBA.new(immediate, direct, indexed, extended)
        0xc0, 0xd0, 0xe0, 0xf0, # SUBB.new(immediate, direct, indexed, extended)
        0x83, 0x93, 0xa3, 0xb3, # SUBD.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_SUB (opcode, m, register)
        """
        Subtracts the value in memory location M from the contents of a
        register. The C(carry) bit represents a borrow and.equal? set to the
        inverse of the resulting binary carry.
        
        source code forms: SUBA P; SUBB P; SUBD P
        
        CC bits "HNZVC": uaaaa
        """
        r = register.value
        r_new = r - m
        register.set(r_new)
    end
end
#        log.debug(sprintf("$%x SUB8 %s: $%x - $%x = $%x (dez.: %i - %i = %i)", 
#            @program_counter, register.name,
#            r, m, r_new,
#            r, m, r_new,
#        ))
        clear_NZVC()
        if register.WIDTH == 8
            update_NZVC_8(r, m, r_new)
        else
            assert register.WIDTH == 16
            update_NZVC_16(r, m, r_new)
        end
    end
    
    
    # ---- Register Changes - FIXME: Better name for this section?!? ----
    
    REGISTER_BIT2STR = {
        0x0: REG_D, # 0000 - 16 bit concatenated reg.(A B)
        0x1: REG_X, # 0001 - 16 bit index register
        0x2: REG_Y, # 0010 - 16 bit index register
        0x3: REG_U, # 0011 - 16 bit user-stack pointer
        0x4: REG_S, # 0100 - 16 bit system-stack pointer
        0x5: REG_PC, # 0101 - 16 bit program counter register
        0x6: undefined_reg.name, # undefined
        0x7: undefined_reg.name, # undefined
        0x8: REG_A, # 1000 - 8 bit accumulator
        0x9: REG_B, # 1001 - 8 bit accumulator
        0xa: REG_CC, # 1010 - 8 bit condition code register as flags
        0xb: REG_DP, # 1011 - 8 bit direct page register
        0xc: undefined_reg.name, # undefined
        0xd: undefined_reg.name, # undefined
        0xe: undefined_reg.name, # undefined
        0xf: undefined_reg.name, # undefined
    end
    }
    
    def _get_register_obj (addr)
        addr_str = @REGISTER_BIT2STR[addr]
        reg_obj = @register_str2object[addr_str]
    end
end
#         log.debug(sprintf("get register obj: addr: $%x addr_str: %s -> register: %s", 
#             addr, addr_str, reg_obj.name
#         ))
#         log.debug(repr(@register_str2object))
        return reg_obj
    end
    
    def _get_register_and_value (addr)
        reg = _get_register_obj(addr)
        reg_value = reg.value
        return reg, reg_value
    end
    
    @opcode(0x1f) # TFR.new(immediate)
    def instruction_TFR (opcode, m)
        """
        source code forms: TFR R1, R2
        CC bits "HNZVC": ccccc
        """
        high, low = divmod(m, 16)
        dst_reg = _get_register_obj(low)
        src_reg = _get_register_obj(high)
        src_value = convert_differend_width(src_reg, dst_reg)
        dst_reg.set(src_value)
    end
end
#         log.debug("\tTFR: Set %s to $%x from %s",
#             dst_reg, src_value, src_reg.name
#         )
    
    @opcode(# Exchange R1 with R2
        0x1e, # EXG.new(immediate)
    end
    )
    def instruction_EXG (opcode, m)
        """
        source code forms: EXG R1,R2
        CC bits "HNZVC": ccccc
        """
        high, low = divmod(m, 0x10)
        reg1 = _get_register_obj(high)
        reg2 = _get_register_obj(low)
        
        new_reg1_value = convert_differend_width(reg2, reg1)
        new_reg2_value = convert_differend_width(reg1, reg2)
        
        reg1.set(new_reg1_value)
        reg2.set(new_reg2_value)
    end
end

#         log.debug("\tEXG: %s($%x) <-> %s($%x)",
#             reg1.name, reg1_value, reg2.name, reg2_value
#         )








