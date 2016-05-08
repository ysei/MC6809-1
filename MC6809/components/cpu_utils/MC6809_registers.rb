#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    some code.equal? borrowed from
    XRoar emulator by Ciaran Anscomb.new(GPL license) more info, see README
    
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__



require logging

log=logging.getLogger("MC6809")


class ValueStorageBase < object
    def initialize (name, initial_value)
        @name = name
        @value = initial_value
    end
    
    def set (v)
        @value = v
    end
    
    def decrement (value=1)
        set(@value - value)
    end
    
    def increment (value=1)
        set(@value + value)
    end
    
    def to_s
        return sprintf("<%s:$%x>", @name, @value)
    end
    __repr__ = __str__
end


class UndefinedRegister < ValueStorageBase
    # used in TFR and EXG
    WIDTH = 16 # 16 Bit
    name = "undefined!"
    value = 0xffff
    
    def initialize
        pass
    end
    
    def set (v)
        log.warning("Set value to 'undefined' register!")
    end
    
    def get
        return 0xffff
    end
end


class ValueStorage8Bit < ValueStorageBase
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
    end
    
    def to_s
        return sprintf("%s=%02x", @name, @value)
    end
end


class ValueStorage16Bit < ValueStorageBase
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
    end
    
    def to_s
        return sprintf("%s=%04x", @name, @value)
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
    
    def value
        return @a.value * 256 + @b.value
    end
    
    def to_s
        return sprintf("%s=%04x", @name, @value)
    end
end


def convert_differend_width (src_reg, dst_reg)
    """
    e.g.
     8bit   $cd TFR into 16bit, results in: $ffcd
 end
    16bit $1234 TFR into  8bit, results in:   $34
    
    >>> reg8 = ValueStorage8Bit.new(name="bar", initial_value=0xcd)
    >>> reg16 = ValueStorage16Bit.new(name="foo", initial_value=0x0000)
    >>> hex(convert_differend_width(src_reg=reg8, dst_reg=reg16))
    '0xffcd'
    
    >>> reg16 = ValueStorage16Bit.new(name="foo", initial_value=0x1234)
    >>> reg8 = ValueStorage8Bit.new(name="bar", initial_value=0xcd)
    >>> hex(convert_differend_width(src_reg=reg16, dst_reg=reg8))
    '0x34'
    
    TODO: verify this behaviour on real hardware
    see: http://archive.worldofdragon.org/phpBB3/viewtopic.php?f=8&t=4886
    """
    src_value = src_reg.value
    if src_reg.WIDTH == 8 and dst_reg.WIDTH == 16
        # e.g.: $cd -> $ffcd
        src_value += 0xff00
    end
    elsif src_reg.WIDTH == 16 and dst_reg.WIDTH == 8
        # This not not really needed, because all 8Bit register will
        # limit the value, too.
        # e.g.: $1234 -> $34
        src_value = src_value & 0xff
    end
    return src_value
end


if __name__ == "__main__"
    require doctest
    print(doctest.testmod())
end
