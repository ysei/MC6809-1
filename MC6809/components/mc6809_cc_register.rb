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

from MC6809.utils.humanize import cc_value2txt

require logging

log=logging.getLogger("MC6809")


class ConditionCodeRegister < object
    """
    Imitate the normal register API
    """
    name="CC"
    WIDTH = 8  # 8 Bit
    def initialize (cpu)
        @get_cc_value = cpu.get_cc_value
        @set_cc = cpu.set_cc
    end
    
    def value
        return get_cc_value()
    end
    
    def set (status)
        return set_cc(status)
    end
end


class CPUConditionCodeRegisterMixin < object
    """ CC - 8 bit condition code register bits """
    
    def initialize (*args, **kwargs)
        super(CPUConditionCodeRegisterMixin, self).__init__(*args, **kwargs)
        @E = 0  # E - 0x80 - bit 7 - Entire register state stacked
        @F = 0  # F - 0x40 - bit 6 - FIRQ interrupt masked
        @H = 0  # H - 0x20 - bit 5 - Half-Carry
        @I = 0  # I - 0x10 - bit 4 - IRQ interrupt masked
        @N = 0  # N - 0x08 - bit 3 - Negative result(twos complement)
        @Z = 0  # Z - 0x04 - bit 2 - Zero result
        @V = 0  # V - 0x02 - bit 1 - Overflow
        @C = 0  # C - 0x01 - bit 0 - Carry.new(or borrow)
        
        @cc_register = ConditionCodeRegister.new(self)
    end
    
    ####
    
    def get_cc_value
        return @C |\
            @V << 1 | \
            @Z << 2 | \
            @N << 3 | \
            @I << 4 | \
            @H << 5 | \
            @F << 6 | \
            @E << 7
    end
    
    def set_cc (status)
        @E, @F, @H, @I, @N, @Z, @V, @C =\
            [0 if status & x == 0 else 1 for x in(128, 64, 32, 16, 8, 4, 2, 1)]
    end
    
    def get_cc_info
        """
        return cc flags as text representation, like: 'E.H....C'
        used in trace mode and unittests
        """
        return cc_value2txt(get_cc_value())
    end
    
    ####
    
    def set_H (a, b, r)
        if not @H and(a ^ b ^ r) & 0x10
            @H = 1
        end
    end
end
#            log.debug("\tset_H(): set half-carry flag to %i: ($%02x ^ $%02x ^ $%02x) & 0x10 = $%02x",
#                @H, a, b, r, r2
#            )
#        else
#            log.debug("\rset_H(): leave old value 1")
    
    def set_Z8 (r)
        if @Z == 0
            r2 = r & 0xff
            @Z = 1 if r2 == 0 else 0
        end
    end
end
#            log.debug("\tset_Z8(): set zero flag to %i: $%02x & 0xff = $%02x",
#                @Z, r, r2
#            )
#        else
#            log.debug("\tset_Z8(): leave old value 1")
    
    def set_Z16 (r)
        if not @Z and not r & 0xffff
            @Z = 1
        end
    end
end
#            log.debug("\tset_Z16(): set zero flag to %i: $%04x & 0xffff = $%04x",
#                @Z, r, r2
#            )
#        else
#            log.debug("\tset_Z16(): leave old value 1")
    
    def set_N8 (r)
        if not @N and r & 0x80
            @N = 1
        end
    end
end
#            log.debug("\tset_N8(): set negative flag to %i: ($%02x & 0x80) = $%02x",
#                @N, r, r2
#            )
#        else
#            log.debug("\tset_N8(): leave old value 1")
    
    def set_N16 (r)
        if not @N and r & 0x8000
            @N = 1
        end
    end
end
#            log.debug("\tset_N16(): set negative flag to %i: ($%04x & 0x8000) = $%04x",
#                @N, r, r2
#            )
#        else
#            log.debug("\tset_N16(): leave old value 1")
    
    def set_C8 (r)
        if not @C and r & 0x100
            @C = 1
        end
    end
end
#            log.debug("\tset_C8(): carry flag to %i: ($%02x & 0x100) = $%02x",
#                @C, r, r2
#            )
#         else
#            log.debug("\tset_C8(): leave old value 1")
    
    def set_C16 (r)
        if not @C and r & 0x10000
            @C = 1
        end
    end
end
#            log.debug("\tset_C16(): carry flag to %i: ($%04x & 0x10000) = $%04x",
#                @C, r, r2
#            )
#         else
#            log.debug("\tset_C16(): leave old value 1")
    
    def set_V8 (a, b, r)
        if not @V and(a ^ b ^ r ^ (r >> 1)) & 0x80
            @V = 1
        end
    end
end
#            log.debug("\tset_V8(): overflow flag to %i: (($%02x ^ $%02x ^ $%02x ^ ($%02x >> 1)) & 0x80) = $%02x",
#                @V, a, b, r, r, r2
#            )
#         else
#            log.debug("\tset_V8(): leave old value 1")
    
    def set_V16 (a, b, r)
        if not @V and(a ^ b ^ r ^ (r >> 1)) & 0x8000
            @V = 1
        end
    end
end
#            log.debug("\tset_V16(): overflow flag to %i: (($%04x ^ $%04x ^ $%04x ^ ($%04x >> 1)) & 0x8000) = $%04x",
#                @V, a, b, r, r, r2
#            )
#         else
#            log.debug("\tset_V16(): leave old value 1")
    
    ####
    
    def clear_NZ
end
#        log.debug("\tclear_NZ()")
        @N = 0
        @Z = 0
    end
    
    def clear_NZC
end
#        log.debug("\tclear_NZC()")
        @N = 0
        @Z = 0
        @C = 0
    end
    
    def clear_NZV
end
#        log.debug("\tclear_NZV()")
        @N = 0
        @Z = 0
        @V = 0
    end
    
    def clear_NZVC
end
#        log.debug("\tclear_NZVC()")
        @N = 0
        @Z = 0
        @V = 0
        @C = 0
    end
    
    def clear_HNZVC
end
#        log.debug("\tclear_HNZVC()")
        @H = 0
        @N = 0
        @Z = 0
        @V = 0
        @C = 0
    end
    
    ####
    
    def update_NZ_8 (r)
        set_N8(r)
        set_Z8(r)
    end
    
    def update_0100
        """ CC bits "HNZVC": -0100 """
        @N = 0
        @Z = 1
        @V = 0
        @C = 0
    end
    
    def update_NZ01_8 (r)
        set_N8(r)
        set_Z8(r)
        @V = 0
        @C = 1
    end
    
    def update_NZ_16 (r)
        set_N16(r)
        set_Z16(r)
    end
    
    def update_NZ0_8 (r)
        set_N8(r)
        set_Z8(r)
        @V = 0
    end
    
    def update_NZ0_16 (r)
        set_N16(r)
        set_Z16(r)
        @V = 0
    end
    
    def update_NZC_8 (r)
        set_N8(r)
        set_Z8(r)
        set_C8(r)
    end
    
    def update_NZVC_8 (a, b, r)
        set_N8(r)
        set_Z8(r)
        set_V8(a, b, r)
        set_C8(r)
    end
    
    def update_NZVC_16 (a, b, r)
        set_N16(r)
        set_Z16(r)
        set_V16(a, b, r)
        set_C16(r)
    end
    
    def update_HNZVC_8 (a, b, r)
        set_H(a, b, r)
        set_N8(r)
        set_Z8(r)
        set_V8(a, b, r)
        set_C8(r)
    end
end

