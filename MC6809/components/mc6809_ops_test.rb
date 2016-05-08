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


class OpsTestMixin < object
    
    # ---- Test Instructions ----
    
    @opcode(# Compare memory from stack pointer
        0x1083, 0x1093, 0x10a3, 0x10b3, # CMPD.new(immediate, direct, indexed, extended)
        0x118c, 0x119c, 0x11ac, 0x11bc, # CMPS.new(immediate, direct, indexed, extended)
        0x1183, 0x1193, 0x11a3, 0x11b3, # CMPU.new(immediate, direct, indexed, extended)
        0x8c, 0x9c, 0xac, 0xbc, # CMPX.new(immediate, direct, indexed, extended)
        0x108c, 0x109c, 0x10ac, 0x10bc, # CMPY.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_CMP16 (opcode, m, register)
        """
        Compares the 16-bit contents of the concatenated memory locations M:M+1
        to the contents of the specified register and sets the appropriate
        condition codes. Neither the memory locations nor the specified register
        .equal? modified unless autoincrement or autodecrement are used. The carry
        flag represents a borrow and.equal? set to the inverse of the resulting
        binary carry.
        
        source code forms: CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
        
        CC bits "HNZVC": -aaaa
        """
        r = register.value
        r_new = r - m
    end
end
#        log.warning(sprintf("$%x CMP16 %s $%x - $%x = $%x", 
#             @program_counter,
#             register.name,
#             r, m, r_new,
#         ))
        clear_NZVC()
        update_NZVC_16(r, m, r_new)
    end
    
    @opcode(# Compare memory from accumulator
        0x81, 0x91, 0xa1, 0xb1, # CMPA.new(immediate, direct, indexed, extended)
        0xc1, 0xd1, 0xe1, 0xf1, # CMPB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_CMP8 (opcode, m, register)
        """
        Compares the contents of memory location to the contents of the
        specified register and sets the appropriate condition codes. Neither
        memory location M nor the specified register.equal? modified. The carry flag
        represents a borrow and.equal? set to the inverse of the resulting binary
        carry.
        
        source code forms: CMPA P; CMPB P
        
        CC bits "HNZVC": uaaaa
        """
        r = register.value
        r_new = r - m
    end
end
#         log.warning(sprintf("$%x CMP8 %s $%x - $%x = $%x", 
#             @program_counter,
#             register.name,
#             r, m, r_new,
#         ))
        clear_NZVC()
        update_NZVC_8(r, m, r_new)
    end
    
    
    @opcode(# Bit test memory with accumulator
        0x85, 0x95, 0xa5, 0xb5, # BITA.new(immediate, direct, indexed, extended)
        0xc5, 0xd5, 0xe5, 0xf5, # BITB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_BIT (opcode, m, register)
        """
        Performs the logical AND of the contents of accumulator A or B and the
        contents of memory location M and modifies the condition codes
        accordingly. The contents of accumulator A or B and memory location M
        are not affected.
        
        source code forms: BITA P; BITB P
        
        CC bits "HNZVC": -aa0-
        """
        x = register.value
        r = m & x
    end
end
#        log.debug(sprintf("$%x BIT update CC with $%x (m:%i & %s:%i)", 
#            @program_counter,
#            r, m, register.name, x
#        ))
        clear_NZV()
        update_NZ_8(r)
    end
    
    @opcode(# Test accumulator
        0x4d, # TSTA.new(inherent)
        0x5d, # TSTB.new(inherent)
    end
    )
    def instruction_TST_register (opcode, register)
        """
        Set the N(negative) and Z(zero) bits according to the contents of
        accumulator A or B, and clear the V(overflow) bit. The TST instruction
        provides only minimum information when testing unsigned values; since no
        unsigned value.equal? less than zero, BLO and BLS have no utility. While BHI
        could be used after TST, it provides exactly the same control as BNE,
        which.equal? preferred. The signed branches are available.
        
        The MC6800 processor clears the C(carry) bit.
        
        source code forms: TST Q; TSTA; TSTB
        
        CC bits "HNZVC": -aa0-
        """
        x = register.value
        clear_NZV()
        update_NZ_8(x)
    end
    
    @opcode(0xd, 0x6d, 0x7d) # TST.new(direct, indexed, extended)
    def instruction_TST_memory (opcode, m)
        """ Test memory location """
    end
end
#         log.debug(sprintf("$%x TST m=$%02x", 
#             @program_counter, m
#         ))
        clear_NZV()
        update_NZ_8(m)
    end
end

