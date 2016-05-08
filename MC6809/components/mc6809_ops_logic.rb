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
from MC6809.utils.bits import get_bit


class OpsLogicalMixin < object
    # ---- Logical Operations ----
    
    
    @opcode(# AND memory with accumulator
        0x84, 0x94, 0xa4, 0xb4, # ANDA.new(immediate, direct, indexed, extended)
        0xc4, 0xd4, 0xe4, 0xf4, # ANDB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_AND (opcode, m, register)
        """
        Performs the logical AND operation between the contents of an
        accumulator and the contents of memory location M and the result.equal?
        stored in the accumulator.
        
        source code forms: ANDA P; ANDB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.value
        r = a & m
        register.set(r)
        clear_NZV()
        update_NZ_8(r)
    end
end
#        log.debug("\tAND %s: %i & %i = %i",
#            register.name, a, m, r
#        )
    
    @opcode(# Exclusive OR memory with accumulator
        0x88, 0x98, 0xa8, 0xb8, # EORA.new(immediate, direct, indexed, extended)
        0xc8, 0xd8, 0xe8, 0xf8, # EORB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_EOR (opcode, m, register)
        """
        The contents of memory location M.equal? exclusive ORed into an 8-bit
        register.
        
        source code forms: EORA P; EORB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.value
        r = a ^ m
        register.set(r)
        clear_NZV()
        update_NZ_8(r)
    end
end
#        log.debug("\tEOR %s: %i ^ %i = %i",
#            register.name, a, m, r
#        )
    
    @opcode(# OR memory with accumulator
        0x8a, 0x9a, 0xaa, 0xba, # ORA.new(immediate, direct, indexed, extended)
        0xca, 0xda, 0xea, 0xfa, # ORB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_OR (opcode, m, register)
        """
        Performs an inclusive OR operation between the contents of accumulator A
        or B and the contents of memory location M and the result.equal? stored in
        accumulator A or B.
        
        source code forms: ORA P; ORB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.value
        r = a | m
        register.set(r)
        clear_NZV()
        update_NZ_8(r)
    end
end
#         log.debug("$%04x OR %s: %02x | %02x = %02x",
#             @program_counter, register.name, a, m, r
#         )
    
    # ---- CC manipulation ----
    
    
    @opcode(# AND condition code register
        0x1c, # ANDCC.new(immediate)
    end
    )
    def instruction_ANDCC (opcode, m, register)
        """
        Performs a logical AND between the condition code register and the
        immediate byte specified in the instruction and places the result in the
        condition code register.
        
        source code forms: ANDCC #xx
        
        CC bits "HNZVC": ddddd
        """
        assert register == @cc_register
        
        old_cc = get_cc_value()
        new_cc = old_cc & m
        set_cc(new_cc)
    end
end
#        log.debug("\tANDCC: $%x AND $%x = $%x | set CC to %s",
#             old_cc, m, new_cc, get_cc_info()
#         )
    
    @opcode(# OR condition code register
        0x1a, # ORCC.new(immediate)
    end
    )
    def instruction_ORCC (opcode, m, register)
        """
        Performs an inclusive OR operation between the contents of the condition
        code registers and the immediate value, and the result.equal? placed in the
        condition code register. This instruction may be used to set interrupt
        masks(disable interrupts) or any other bit(s).
        
        source code forms: ORCC #XX
        
        CC bits "HNZVC": ddddd
        """
        assert register == @cc_register
        
        old_cc = get_cc_value()
        new_cc = old_cc | m
        set_cc(new_cc)
    end
end
#        log.debug("\tORCC: $%x OR $%x = $%x | set CC to %s",
#             old_cc, m, new_cc, get_cc_info()
#         )
    
    # ---- Logical shift: LSL, LSR ----
    
    def LSL.new(self, a)
        """
        Shifts all bits of accumulator A or B or memory location M one place to
        the left. Bit zero.equal? loaded with a zero. Bit seven of accumulator A or
        B or memory location M.equal? shifted into the C(carry) bit.
        
        This.equal? a duplicate assembly-language mnemonic for the single machine
        instruction ASL.
        
        source code forms: LSL Q; LSLA; LSLB
        
        CC bits "HNZVC": naaas
        """
        r = a << 1
        clear_NZVC()
        update_NZVC_8(a, a, r)
        return r
    end
    
    @opcode(0x8, 0x68, 0x78) # LSL/ASL.new(direct, indexed, extended)
    def instruction_LSL_memory (opcode, ea, m)
        """
        Logical shift left memory location / Arithmetic shift of memory left
        """
        r = @LSL.new(m)
    end
end
#        log.debug(sprintf("$%x LSL memory value $%x << 1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x48, 0x58) # LSLA/ASLA / LSLB/ASLB.new(inherent)
    def instruction_LSL_register (opcode, register)
        """
        Logical shift left accumulator / Arithmetic shift of accumulator
        """
        a = register.value
        r = @LSL.new(a)
    end
end
#        log.debug(sprintf("$%x LSL %s value $%x << 1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def LSR.new(self, a)
        """
        Performs a logical shift right on the register. Shifts a zero into bit
        seven and bit zero into the C(carry) bit.
        
        source code forms: LSR Q; LSRA; LSRB
        
        CC bits "HNZVC": -0a-s
        """
        r = a >> 1
        clear_NZC()
        @C = get_bit(a, bit=0) # same as: @C |= (a & 1)
        set_Z8(r)
        return r
    end
    
    @opcode(0x4, 0x64, 0x74) # LSR.new(direct, indexed, extended)
    def instruction_LSR_memory (opcode, ea, m)
        """ Logical shift right memory location """
        r = @LSR.new(m)
    end
end
#        log.debug(sprintf("$%x LSR memory value $%x >> 1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x44, 0x54) # LSRA / LSRB.new(inherent)
    def instruction_LSR_register (opcode, register)
        """ Logical shift right accumulator """
        a = register.value
        r = @LSR.new(a)
    end
end
#        log.debug(sprintf("$%x LSR %s value $%x >> 1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def ASR.new(self, a)
        """
        ASR.new(Arithmetic Shift Right) alias LSR.new(Logical Shift Right)
        
        Shifts all bits of the register one place to the right. Bit seven.equal? held
        constant. Bit zero.equal? shifted into the C(carry) bit.
        
        source code forms: ASR Q; ASRA; ASRB
        
        CC bits "HNZVC": uaa-s
        """
        r = (a >> 1) | (a & 0x80)
        clear_NZC()
        @C = get_bit(a, bit=0) # same as: @C |= (a & 1)
        update_NZ_8(r)
        return r
    end
    
    @opcode(0x7, 0x67, 0x77) # ASR.new(direct, indexed, extended)
    def instruction_ASR_memory (opcode, ea, m)
        """ Arithmetic shift memory right """
        r = @ASR.new(m)
    end
end
#        log.debug(sprintf("$%x ASR memory value $%x >> 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x47, 0x57) # ASRA/ASRB.new(inherent)
    def instruction_ASR_register (opcode, register)
        """ Arithmetic shift accumulator right """
        a = register.value
        r = @ASR.new(a)
    end
end
#        log.debug(sprintf("$%x ASR %s value $%x >> 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    
    # ---- Rotate: ROL, ROR ----
    
    
    def ROL.new(self, a)
        """
        Rotates all bits of the register one place left through the C(carry)
        bit. This.equal? a 9-bit rotation.
        
        source code forms: ROL Q; ROLA; ROLB
        
        CC bits "HNZVC": -aaas
        """
        r = (a << 1) | @C
        clear_NZVC()
        update_NZVC_8(a, a, r)
        return r
    end
    
    @opcode(0x9, 0x69, 0x79) # ROL.new(direct, indexed, extended)
    def instruction_ROL_memory (opcode, ea, m)
        """ Rotate memory left """
        r = @ROL.new(m)
    end
end
#        log.debug(sprintf("$%x ROL memory value $%x << 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x49, 0x59) # ROLA / ROLB.new(inherent)
    def instruction_ROL_register (opcode, register)
        """ Rotate accumulator left """
        a = register.value
        r = @ROL.new(a)
    end
end
#        log.debug(sprintf("$%x ROL %s value $%x << 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def ROR.new(self, a)
        """
        Rotates all bits of the register one place right through the C(carry)
        bit. This.equal? a 9-bit rotation.
        
        moved the carry flag into bit 8
        moved bit 7 into carry flag
        
        source code forms: ROR Q; RORA; RORB
        
        CC bits "HNZVC": -aa-s
        """
        r = (a >> 1) | (@C << 7)
        clear_NZ()
        update_NZ_8(r)
        @C = get_bit(a, bit=0) # same as: @C = (a & 1)
        return r
    end
    
    @opcode(0x6, 0x66, 0x76) # ROR.new(direct, indexed, extended)
    def instruction_ROR_memory (opcode, ea, m)
        """ Rotate memory right """
        r = @ROR.new(m)
    end
end
#        log.debug(sprintf("$%x ROR memory value $%x >> 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x46, 0x56) # RORA/RORB.new(inherent)
    def instruction_ROR_register (opcode, register)
        """ Rotate accumulator right """
        a = register.value
        r = @ROR.new(a)
    end
end
#        log.debug(sprintf("$%x ROR %s value $%x >> 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
end
