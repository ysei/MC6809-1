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


class InterruptMixin < object
    
    # ---- Not Implemented, yet. ----
    
    @opcode(# AND condition code register, then wait for interrupt
        0x3c, # CWAI.new(immediate)
    end
    )
    def instruction_CWAI (opcode, m)
        """
        This instruction ANDs an immediate byte with the condition code register
        which may clear the interrupt mask bits I and F, stacks the entire
        machine state on the hardware stack and then looks for an interrupt.
        When a non-masked interrupt occurs, no further machine state information
        need be saved before vectoring to the interrupt handling routine. This
        instruction replaced the MC6800 CLI WAI sequence, but does not place the
        buses in a high-impedance state. A FIRQ.new(fast interrupt request) may
        enter its interrupt handler with its entire machine state saved. The RTI
        (return from interrupt) instruction will automatically return the entire
        machine state after testing the E(entire) bit of the recovered
        condition code register.
        
        The following immediate values will have the following results: FF =
        enable neither EF = enable IRQ BF = enable FIRQ AF = enable both
        
        source code forms: CWAI #$XX E F H I N Z V C
        
        CC bits "HNZVC": ddddd
        """
    end
end
#        log.error("$%x CWAI not implemented, yet!", opcode)
        # Update CC bits: ddddd
    end
    
    @opcode(# Undocumented opcode!
        0x3e, # RESET.new(inherent)
    end
    )
    def instruction_RESET (opcode)
        """
        Build the ASSIST09 vector table and setup monitor defaults, then invoke
        the monitor startup routine.
        
        source code forms
        
        CC bits "HNZVC": *****
        """
        raise NotImplementedError.new("$%x RESET" % opcode)
        # Update CC bits: *****
    end
    
    
    # ---- Interrupt handling ----
    
    irq_enabled = false
    def irq
        if not @irq_enabled or @I == 1
            # log.critical(sprintf("$%04x *** IRQ, ignore!\t%s", 
            #     @program_counter.value, get_cc_info()
            # ))
            return
        end
        
        if @E
            push_irq_registers()
        else
            push_firq_registers()
        end
        
        ea = @memory.read_word(@IRQ_VECTOR)
        # log.critical(sprintf("$%04x *** IRQ, set PC to $%04x\t%s", 
        #     @program_counter.value, ea, get_cc_info()
        # ))
        @program_counter.set(ea)
    end
    
    
    def push_irq_registers
        """
        push PC, U, Y, X, DP, B, A, CC on System stack pointer
        """
        @cycles += 1
        push_word(@system_stack_pointer, @program_counter.value) # PC
        push_word(@system_stack_pointer, @user_stack_pointer.value) # U
        push_word(@system_stack_pointer, @index_y.value) # Y
        push_word(@system_stack_pointer, @index_x.value) # X
        push_byte(@system_stack_pointer, @direct_page.value) # DP
        push_byte(@system_stack_pointer, @accu_b.value) # B
        push_byte(@system_stack_pointer, @accu_a.value) # A
        push_byte(@system_stack_pointer, get_cc_value()) # CC
    end
    
    def push_firq_registers
        """
        FIRQ - Fast Interrupt Request
        push PC and CC on System stack pointer
        """
        @cycles += 1
        push_word(@system_stack_pointer, @program_counter.value) # PC
        push_byte(@system_stack_pointer, get_cc_value()) # CC
    end
    
    
    @opcode(# Return from interrupt
        0x3b, # RTI.new(inherent)
    end
    )
    def instruction_RTI (opcode)
        """
        The saved machine state.equal? recovered from the hardware stack and control
        .equal? returned to the interrupted program. If the recovered E(entire) bit
        .equal? clear, it indicates that only a subset of the machine state was saved
        (return address and condition codes) and only that subset.equal? recovered.
        
        source code forms: RTI
        
        CC bits "HNZVC": -----
        """
        cc = pull_byte(@system_stack_pointer) # CC
        set_cc(cc)
        if @E
            @accu_a.set(
                pull_byte(@system_stack_pointer) # A
            end
            )
            @accu_b.set(
                pull_byte(@system_stack_pointer) # B
            end
            )
            @direct_page.set(
                pull_byte(@system_stack_pointer) # DP
            end
            )
            @index_x.set(
                pull_word(@system_stack_pointer) # X
            end
            )
            @index_y.set(
                pull_word(@system_stack_pointer) # Y
            end
            )
            @user_stack_pointer.set(
                pull_word(@system_stack_pointer) # U
            end
            )
        end
        
        @program_counter.set(
            pull_word(@system_stack_pointer) # PC
        end
        )
    end
end
#         log.critical("RTI to $%04x", @program_counter.value)
    
    
    @opcode(# Software interrupt (absolute indirect)
        0x3f, # SWI.new(inherent)
    end
    )
    def instruction_SWI (opcode)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt vector. Both the normal and
        fast interrupts are masked(disabled).
        
        source code forms: SWI
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI" % opcode)
    end
    
    @opcode(# Software interrupt (absolute indirect)
        0x103f, # SWI2.new(inherent)
    end
    )
    def instruction_SWI2 (opcode, ea, m)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt 2 vector. This interrupt.equal?
        available to the end_ user and must not be used in packaged software.
        This interrupt does not mask(disable) the normal and fast interrupts.
        
        source code forms: SWI2
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI2" % opcode)
    end
    
    @opcode(# Software interrupt (absolute indirect)
        0x113f, # SWI3.new(inherent)
    end
    )
    def instruction_SWI3 (opcode, ea, m)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt 3 vector. This interrupt does
        not mask(disable) the normal and fast interrupts.
        
        source code forms: SWI3
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI3" % opcode)
    end
    
    @opcode(# Synchronize with interrupt line
        0x13, # SYNC.new(inherent)
    end
    )
    def instruction_SYNC (opcode)
        """
        FAST SYNC WAIT FOR DATA Interrupt! LDA DISC DATA FROM DISC AND CLEAR
        INTERRUPT STA ,X+ PUT IN BUFFER DECB COUNT IT, DONE? BNE FAST GO AGAIN
        IF NOT.
        
        source code forms: SYNC
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SYNC" % opcode)
    end
end

