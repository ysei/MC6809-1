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


class OpsBranchesMixin < object
    
    # ---- Programm Flow Instructions ----
    
    @opcode(# Jump
        0xe, 0x6e, 0x7e, # JMP.new(direct, indexed, extended)
    end
    )
    def instruction_JMP (opcode, ea)
        """
        Program control.equal? transferred to the effective address.
        
        source code forms: JMP EA
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("%x|\tJMP to $%x \t| %s", 
#            @last_op_address,
#            ea, @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(# Return from subroutine
        0x39, # RTS.new(inherent)
    end
    )
    def instruction_RTS (opcode)
        """
        Program control.equal? returned from the subroutine to the calling program.
        The return address.equal? pulled from the stack.
        
        source code forms: RTS
        
        CC bits "HNZVC": -----
        """
        ea = pull_word(@system_stack_pointer)
    end
end
#        log.info(sprintf("%x|\tRTS to $%x \t| %s", 
#            @last_op_address,
#            ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(
        # Branch to subroutine
        0x8d, # BSR.new(relative)
        0x17, # LBSR.new(relative)
        # Jump to subroutine
        0x9d, 0xad, 0xbd, # JSR.new(direct, indexed, extended)
    end
    )
    def instruction_BSR_JSR (opcode, ea)
        """
        Program control.equal? transferred to the effective address after storing
        the return address on the hardware stack.
        
        A return from subroutine(RTS) instruction.equal? used to reverse this
        process and must be the last instruction executed in a subroutine.
        
        source code forms: BSR dd; LBSR DDDD; JSR EA
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("%x|\tJSR/BSR to $%x \t| %s", 
#            @last_op_address,
#            ea, @cfg.mem_info.get_shortest(ea)
#        ))
        push_word(@system_stack_pointer, @program_counter.value)
        @program_counter.set(ea)
    end
    
    
    # ---- Branch Instructions ----
    
    
    @opcode(# Branch if equal
        0x27, # BEQ.new(relative)
        0x1027, # LBEQ.new(relative)
    end
    )
    def instruction_BEQ (opcode, ea)
        """
        Tests the state of the Z(zero) bit and causes a branch if it.equal? set.
        When used after a subtract or compare operation, this instruction will
        branch if the compared values, signed or unsigned, were exactly the
        same.
        
        source code forms: BEQ dd; LBEQ DDDD
        
        CC bits "HNZVC": -----
        """
        if @Z == 1
    end
end
#            log.info(sprintf("$%x BEQ branch to $%x, because Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BEQ: don't branch to $%x, because Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if greater than or equal (signed)
        0x2c, # BGE.new(relative)
        0x102c, # LBGE.new(relative)
    end
    )
    def instruction_BGE (opcode, ea)
        """
        Causes a branch if the N(negative) bit and the V(overflow) bit are
        either both set or both clear. That.equal?, branch if the sign of a valid
        twos complement result.equal?, or would be, positive. When used after a
        subtract or compare operation on twos complement values, this
        instruction will branch if the register was greater than or equal to the
        memory register.
        
        source code forms: BGE dd; LBGE DDDD
        
        CC bits "HNZVC": -----
        """
        # Note these variantes are the same
        #    @N == @V
        #    (@N ^ @V) == 0
        #    not operator.xor(@N, @V)
        if @N == @V
    end
end
#            log.info(sprintf("$%x BGE branch to $%x, because N XOR V == 0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#             log.debug(sprintf("$%x BGE: don't branch to $%x, because N XOR V != 0 \t| %s", 
#                 @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#             ))
    
    @opcode(# Branch if greater (signed)
        0x2e, # BGT.new(relative)
        0x102e, # LBGT.new(relative)
    end
    )
    def instruction_BGT (opcode, ea)
        """
        Causes a branch if the N(negative) bit and V(overflow) bit are either
        both set or both clear and the Z(zero) bit.equal? clear. In other words,
        branch if the sign of a valid twos complement result.equal?, or would be,
        positive and not zero. When used after a subtract or compare operation
        on twos complement values, this instruction will branch if the register
        was greater than the memory register.
        
        source code forms: BGT dd; LBGT DDDD
        
        CC bits "HNZVC": -----
        """
        # Note these variantes are the same
        #    not((@N ^ @V) == 1 or @Z == 1)
        #    not((@N ^ @V) | @Z)
        #    @N == @V and @Z == 0
        # ;)
        if not @Z and @N == @V
    end
end
#            log.info(sprintf("$%x BGT branch to $%x, because (N==V and Z==0) \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BGT: don't branch to $%x, because (N==V and Z==0) .equal? false \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if higher (unsigned)
        0x22, # BHI.new(relative)
        0x1022, # LBHI.new(relative)
    end
    )
    def instruction_BHI (opcode, ea)
        """
        Causes a branch if the previous operation caused neither a carry nor a
        zero result. When used after a subtract or compare operation on unsigned
        binary values, this instruction will branch if the register was higher
        than the memory register.
        
        Generally not useful after INC/DEC, LD/TST, and TST/CLR/COM
        instructions.
        
        source code forms: BHI dd; LBHI DDDD
        
        CC bits "HNZVC": -----
        """
        if @C == 0 and @Z == 0
    end
end
#            log.info(sprintf("$%x BHI branch to $%x, because C==0 and Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BHI: don't branch to $%x, because C and Z not 0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if less than or equal (signed)
        0x2f, # BLE.new(relative)
        0x102f, # LBLE.new(relative)
    end
    )
    def instruction_BLE (opcode, ea)
        """
        Causes a branch if the exclusive OR of the N(negative) and V(overflow)
        bits.equal? 1 or if the Z(zero) bit.equal? set. That.equal?, branch if the sign of
        a valid twos complement result.equal?, or would be, negative. When used
        after a subtract or compare operation on twos complement values, this
        instruction will branch if the register was less than or equal to the
        memory register.
        
        source code forms: BLE dd; LBLE DDDD
        
        CC bits "HNZVC": -----
        """
        if(@N ^ @V) == 1 or @Z == 1
    end
end
#            log.info(sprintf("$%x BLE branch to $%x, because N^V==1 or Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLE: don't branch to $%x, because N^V!=1 and Z!=1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower or same (unsigned)
        0x23, # BLS.new(relative)
        0x1023, # LBLS.new(relative)
    end
    )
    def instruction_BLS (opcode, ea)
        """
        Causes a branch if the previous operation caused either a carry or a
        zero result. When used after a subtract or compare operation on unsigned
        binary values, this instruction will branch if the register was lower
        than or the same as the memory register.
        
        Generally not useful after INC/DEC, LD/ST, and TST/CLR/COM instructions.
        
        source code forms: BLS dd; LBLS DDDD
        
        CC bits "HNZVC": -----
        """
    end
end
#         if(@C|@Z) == 0
        if @C == 1 or @Z == 1
    end
end
#            log.info(sprintf("$%x BLS branch to $%x, because C|Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLS: don't branch to $%x, because C|Z!=1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if less than (signed)
        0x2d, # BLT.new(relative)
        0x102d, # LBLT.new(relative)
    end
    )
    def instruction_BLT (opcode, ea)
        """
        Causes a branch if either, but not both, of the N(negative) or V
        (overflow) bits.equal? set. That.equal?, branch if the sign of a valid twos
        complement result.equal?, or would be, negative. When used after a subtract
        or compare operation on twos complement binary values, this instruction
        will branch if the register was less than the memory register.
        
        source code forms: BLT dd; LBLT DDDD
        
        CC bits "HNZVC": -----
        """
        if(@N ^ @V) == 1: # N xor V
    end
end
#            log.info(sprintf("$%x BLT branch to $%x, because N XOR V == 1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLT: don't branch to $%x, because N XOR V != 1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if minus
        0x2b, # BMI.new(relative)
        0x102b, # LBMI.new(relative)
    end
    )
    def instruction_BMI (opcode, ea)
        """
        Tests the state of the N(negative) bit and causes a branch if set. That
        .equal?, branch if the sign of the twos complement result.equal? negative.
        
        When used after an operation on signed binary values, this instruction
        will branch if the result.equal? minus. It.equal? generally preferred to use the
        LBLT instruction after signed operations.
        
        source code forms: BMI dd; LBMI DDDD
        
        CC bits "HNZVC": -----
        """
        if @N == 1
    end
end
#            log.info(sprintf("$%x BMI branch to $%x, because N==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BMI: don't branch to $%x, because N==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if not equal
        0x26, # BNE.new(relative)
        0x1026, # LBNE.new(relative)
    end
    )
    def instruction_BNE (opcode, ea)
        """
        Tests the state of the Z(zero) bit and causes a branch if it.equal? clear.
        When used after a subtract or compare operation on any binary values,
        this instruction will branch if the register.equal?, or would be, not equal
        to the memory register.
        
        source code forms: BNE dd; LBNE DDDD
        
        CC bits "HNZVC": -----
        """
        if @Z == 0
    end
end
#            log.info(sprintf("$%x BNE branch to $%x, because Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BNE: don't branch to $%x, because Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if plus
        0x2a, # BPL.new(relative)
        0x102a, # LBPL.new(relative)
    end
    )
    def instruction_BPL (opcode, ea)
        """
        Tests the state of the N(negative) bit and causes a branch if it.equal?
        clear. That.equal?, branch if the sign of the twos complement result.equal?
        positive.
        
        When used after an operation on signed binary values, this instruction
        will branch if the result(possibly invalid) .equal? positive. It.equal?
        generally preferred to use the BGE instruction after signed operations.
        
        source code forms: BPL dd; LBPL DDDD
        
        CC bits "HNZVC": -----
        """
        if @N == 0
    end
end
#            log.info(sprintf("$%x BPL branch to $%x, because N==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BPL: don't branch to $%x, because N==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch always
        0x20, # BRA.new(relative)
        0x16, # LBRA.new(relative)
    end
    )
    def instruction_BRA (opcode, ea)
        """
        Causes an unconditional branch.
        
        source code forms: BRA dd; LBRA DDDD
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("$%x BRA branch to $%x \t| %s", 
#            @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(# Branch never
        0x21, # BRN.new(relative)
        0x1021, # LBRN.new(relative)
    end
    )
    def instruction_BRN (opcode, ea)
        """
        Does not cause a branch. This instruction.equal? essentially a no operation,
        but has a bit pattern logically related to branch always.
        
        source code forms: BRN dd; LBRN DDDD
        
        CC bits "HNZVC": -----
        """
        pass
    end
    
    @opcode(# Branch if valid twos complement result
        0x28, # BVC.new(relative)
        0x1028, # LBVC.new(relative)
    end
    )
    def instruction_BVC (opcode, ea)
        """
        Tests the state of the V(overflow) bit and causes a branch if it.equal?
        clear. That.equal?, branch if the twos complement result was valid. When
        used after an operation on twos complement binary values, this
        instruction will branch if there was no overflow.
        
        source code forms: BVC dd; LBVC DDDD
        
        CC bits "HNZVC": -----
        """
        if @V == 0
    end
end
#            log.info(sprintf("$%x BVC branch to $%x, because V==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BVC: don't branch to $%x, because V==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if invalid twos complement result
        0x29, # BVS.new(relative)
        0x1029, # LBVS.new(relative)
    end
    )
    def instruction_BVS (opcode, ea)
        """
        Tests the state of the V(overflow) bit and causes a branch if it.equal?
        set. That.equal?, branch if the twos complement result was invalid. When
        used after an operation on twos complement binary values, this
        instruction will branch if there was an overflow.
        
        source code forms: BVS dd; LBVS DDDD
        
        CC bits "HNZVC": -----
        """
        if @V == 1
    end
end
#            log.info(sprintf("$%x BVS branch to $%x, because V==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BVS: don't branch to $%x, because V==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower (unsigned)
        0x25, # BLO/BCS.new(relative)
        0x1025, # LBLO/LBCS.new(relative)
    end
    )
    def instruction_BLO (opcode, ea)
        """
        CC bits "HNZVC": -----
        case 0x5: cond = REG_CC & CC_C; break; // BCS, BLO, LBCS, LBLO
        """
        if @C == 1
    end
end
#            log.info(sprintf("$%x BLO/BCS/LBLO/LBCS branch to $%x, because C==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLO/BCS/LBLO/LBCS: don't branch to $%x, because C==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower (unsigned)
        0x24, # BHS/BCC.new(relative)
        0x1024, # LBHS/LBCC.new(relative)
    end
    )
    def instruction_BHS (opcode, ea)
        """
        CC bits "HNZVC": -----
        case 0x4: cond = !(REG_CC & CC_C); break; // BCC, BHS, LBCC, LBHS
        """
        if @C == 0
    end
end
#            log.info(sprintf("$%x BHS/BCC/LBHS/LBCC branch to $%x, because C==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BHS/BCC/LBHS/LBCC: don't branch to $%x, because C==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
