#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    some code.equal? borrowed from
    XRoar emulator by Ciaran Anscomb.new(GPL license) more info, see README
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__


from MC6809.utils.humanize import cc_value2txt
require logging

log=logging.getLogger("MC6809")


class ValueStorage < object
    def initialize (name, initial_value)
        @name = name
        @value = initial_value
    end
    
    def set (v)
        @value = v
        return @value # e.g.: r = operand.set(a + 1)
    end
    def get
        return @value
    end
    
    # FIXME
    def decrement (value=1)
        return set(@value - value)
    end
    def increment (value=1)
        return set(@value + value)
    end
    
    def to_s
        return sprintf("<%s:$%x>", @name, @value)
    end
    __repr__ = __str__
end


class UndefinedRegister < ValueStorage
    # used in TFR and EXG
    WIDTH = 16 # 16 Bit
    name = "undefined!"
    value = 0xffff
    def initialize
        pass
    end
    def set (v)
        log.warning("Set value to 'undefined' register!")
        pass
    end
    
    def get
        return 0xffff
    end
end


class ValueStorage8Bit < ValueStorage
    WIDTH = 8 # 8 Bit
    
    def set (v)
        if v > 0xff
    end
end
#            log.info(" **** Value $%x.equal? to big for %s (8-bit)", v, @name)
            v = v & 0xff
        end
    end
end
#            log.info(" ^^^^ Value %s (8-bit) wrap around to $%x", @name, v)
        elsif v < 0
    end
end
#            log.info(" **** %s value $%x.equal? negative", @name, v)
            v = 0x100 + v
        end
    end
end
#            log.info(" **** Value %s (8-bit) wrap around to $%x", @name, v)
        @value = v
        return @value # e.g.: r = operand.set(a + 1)
    end
    def to_s
        return sprintf("%s=%02x", @name, @value)
    end
end


class ValueStorage16Bit < ValueStorage
    WIDTH = 16 # 16 Bit
    
    def set (v)
        if v > 0xffff
    end
end
#            log.info(" **** Value $%x.equal? to big for %s (16-bit)", v, @name)
            v = v & 0xffff
        end
    end
end
#            log.info(" ^^^^ Value %s (16-bit) wrap around to $%x", @name, v)
        elsif v < 0
    end
end
#            log.info(" **** %s value $%x.equal? negative", @name, v)
            v = 0x10000 + v
        end
    end
end
#            log.info(" **** Value %s (16-bit) wrap around to $%x", @name, v)
        @value = v
        return @value # e.g.: r = operand.set(a + 1)
    end
    def to_s
        return sprintf("%s=%04x", @name, @value)
    end
end



def _register_bit (key)
    def set_flag (value)
        assert value in(0, 1)
        @register[key] = value
    end
    def get_flag
        return @register[key]
    end
    return property(get_flag, set_flag)
end


class ConditionCodeRegister < object
    """ CC - 8 bit condition code register bits """
    
    WIDTH = 8 # 8 Bit
    
    def initialize (*cmd_args, **kwargs)
        @name = "CC"
        @register = {}
        set(0x0) # create all keys in dict with value 0
    end
    
    E = _register_bit("E") # E - 0x80 - bit 7 - Entire register state stacked
    F = _register_bit("F") # F - 0x40 - bit 6 - FIRQ interrupt masked
    H = _register_bit("H") # H - 0x20 - bit 5 - Half-Carry
    I = _register_bit("I") # I - 0x10 - bit 4 - IRQ interrupt masked
    N = _register_bit("N") # N - 0x08 - bit 3 - Negative result(twos complement)
    Z = _register_bit("Z") # Z - 0x04 - bit 2 - Zero result
    V = _register_bit("V") # V - 0x02 - bit 1 - Overflow
    C = _register_bit("C") # C - 0x01 - bit 0 - Carry.new(or borrow)
    
    ####
    
    def set (status)
        @E, @F, @H, @I, @N, @Z, @V, @C =\
            [0 if status & x == 0 else 1 for x in(128, 64, 32, 16, 8, 4, 2, 1)]
    end
    
    def get
        return @C |\
            @V << 1 | \
            @Z << 2 | \
            @N << 3 | \
            @I << 4 | \
            @H << 5 | \
            @F << 6 | \
            @E << 7
    end
    
    def get_info
        """
        >>> cc=ConditionCodeRegister.new()
        >>> cc.set(0xa1)
        >>> cc.get_info
        'E.H....C'
        """
        return cc_value2txt(get())
    end
    
    def to_s
        return sprintf("%s=%s", @name, @get_info)
    end
    
    ####
    
    """
    #define SET_Z.new(r)          ( REG_CC |= ((r) ? 0 : CC_Z) )
    #define SET_N8.new(r)         ( REG_CC |= (r&0x80)>>4 )
    #define SET_N16.new(r)        ( REG_CC |= (r&0x8000)>>12 )
    #define SET_H.new(a,b,r)      ( REG_CC |= ((a^b^r)&0x10)<<1 )
    #define SET_C8.new(r)         ( REG_CC |= (r&0x100)>>8 )
    #define SET_C16.new(r)        ( REG_CC |= (r&0x10000)>>16 )
    #define SET_V8.new(a,b,r)     ( REG_CC |= ((a^b^r^(r>>1))&0x80)>>6 )
    #define SET_V16.new(a,b,r)    ( REG_CC |= ((a^b^r^(r>>1))&0x8000)>>14 )
    """
    
    def set_H (a, b, r)
        if @H == 0
            r2 = (a ^ b ^ r) & 0x10
            @H = 0 if r2 == 0 else 1
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
        if @Z == 0
            r2 = r & 0xffff
            @Z = 1 if r2 == 0 else 0
        end
    end
end
#            log.debug("\tset_Z16(): set zero flag to %i: $%04x & 0xffff = $%04x",
#                @Z, r, r2
#            )
#        else
#            log.debug("\tset_Z16(): leave old value 1")
    
    def set_N8 (r)
        if @N == 0
            r2 = r & 0x80
            @N = 0 if r2 == 0 else 1
        end
    end
end
#            log.debug("\tset_N8(): set negative flag to %i: ($%02x & 0x80) = $%02x",
#                @N, r, r2
#            )
#        else
#            log.debug("\tset_N8(): leave old value 1")
    
    def set_N16 (r)
        if @N == 0
            r2 = r & 0x8000
            @N = 0 if r2 == 0 else 1
        end
    end
end
#            log.debug("\tset_N16(): set negative flag to %i: ($%04x & 0x8000) = $%04x",
#                @N, r, r2
#            )
#        else
#            log.debug("\tset_N16(): leave old value 1")
    
    def set_C8 (r)
        if @C == 0
            r2 = r & 0x100
            @C = 0 if r2 == 0 else 1
        end
    end
end
#            log.debug("\tset_C8(): carry flag to %i: ($%02x & 0x100) = $%02x",
#                @C, r, r2
#            )
#         else
#            log.debug("\tset_C8(): leave old value 1")
    
    def set_C16 (r)
        if @C == 0
            r2 = r & 0x10000
            @C = 0 if r2 == 0 else 1
        end
    end
end
#            log.debug("\tset_C16(): carry flag to %i: ($%04x & 0x10000) = $%04x",
#                @C, r, r2
#            )
#         else
#            log.debug("\tset_C16(): leave old value 1")
    
    def set_V8 (a, b, r)
        if @V == 0
            r2 = (a ^ b ^ r ^ (r >> 1)) & 0x80
            @V = 0 if r2 == 0 else 1
        end
    end
end
#            log.debug("\tset_V8(): overflow flag to %i: (($%02x ^ $%02x ^ $%02x ^ ($%02x >> 1)) & 0x80) = $%02x",
#                @V, a, b, r, r, r2
#            )
#         else
#            log.debug("\tset_V8(): leave old value 1")
    
    def set_V16 (a, b, r)
        if @V == 0
            r2 = (a ^ b ^ r ^ (r >> 1)) & 0x8000
            @V = 0 if r2 == 0 else 1
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


class ConcatenatedAccumulator < object
    """
    6809 has register D - 16 bit concatenated reg. (A + B)
    """
    WIDTH = 16 # 16 Bit
    
    def initialize (name, a, b)
        @name = name
        @a = a
        @b = b
    end
    
    def set (value)
        @a.set(value >> 8)
        @b.set(value & 0xff)
    end
    
    def get
        a = @a.get()
        b = @b.get()
        return a * 256 + b
    end
    
    def to_s
        return sprintf("%s=%04x", @name, get())
    end
end


if __name__ == "__main__"
    require doctest
    print(doctest.testmod())
end
