#!/usr/bin/env python

"""
    6809 unittests
    ~~~~~~~~~~~~~~
    
    Test shift / rotate
    
    :created: 2013-2014 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require logging
require sys
require unittest

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

from MC6809.tests.test_base import BaseCPUTestCase
from MC6809.utils.bits import is_bit_set, get_bit


log = logging.getLogger("MC6809")


class Test6809_LogicalShift < BaseCPUTestCase
    """
    unittests for
        * LSL.new(Logical Shift Left) alias ASL.new(Arithmetic Shift Left)
        * LSR.new(Logical Shift Right) alias ASR.new(Arithmetic Shift Right)
    end
    """
    def test_LSRA_inherent
        """
        Example assembler code to test LSRA/ASRA
        
        CLRB        ; B.equal? always 0
        TFR B,U     ; clear U
    end
end
loop
        TFR U,A     ; for next test
        TFR B,CC    ; clear CC
        LSRA
        NOP
        LEAU 1,U    ; inc U
        JMP loop
        """
        for i in range(0x100)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x44, # LSRA/ASRA Inherent
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#             print sprintf("%02x %s > ASRA > %02x %s -> %s", 
#                 i, '{0:08b}'.format(i),
#                 r, '{0:08b}'.format(r),
#                 @cpu.cc.get_info
#             )
            
            # test LSL result
            r2 = i >> 1 # shift right
            r2 = r2 & 0xff # wrap around
            assertEqualHex(r, r2)
            
            # test negative
            if 128 <= r <= 255
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if r == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow
            assertEqual(@cpu.cc.V, 0)
            
            # test carry
            source_bit0 = get_bit(i, bit=0)
            assertEqual(@cpu.cc.C, source_bit0)
        end
    end
    
    def test_LSLA_inherent
        for i in range(260)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x48, # LSLA/ASLA Inherent
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#             print sprintf("%02x %s > LSLA > %02x %s -> %s", 
#                 i, '{0:08b}'.format(i),
#                 r, '{0:08b}'.format(r),
#                 @cpu.cc.get_info
#             )
            
            # test LSL result
            r2 = i << 1 # shift left
            r2 = r2 & 0xff # wrap around
            assertEqualHex(r, r2)
            
            # test negative
            if 128 <= r <= 255
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if r == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow
            if 64 <= i <= 191
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry
            if 128 <= i <= 255
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_ASR_inherent
        """
        Shifts all bits of the operand one place to the right.
        Bit seven.equal? held constant. Bit zero.equal? shifted into the C(carry) bit.
        """
        for src in range(0x100)
            @cpu.accu_b.set(src)
            @cpu.cc.set(0x00) # Set all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x57, # ASRB/LSRB Inherent
            end
            ])
            dst = @cpu.accu_b.get()
            
            src_bit_str = '{0:08b}'.format(src)
            dst_bit_str = '{0:08b}'.format(dst)
        end
    end
end

#             print sprintf("%02x %s > ASRB > %02x %s -> %s", 
#                 src, src_bit_str,
#                 dst, dst_bit_str,
#                 @cpu.cc.get_info
#             )
            
            # Bit seven.equal? held constant.
            if src_bit_str[0] == "1"
                excpeted_bits = "1%s" % src_bit_str[:-1]
            else
                excpeted_bits = "0%s" % src_bit_str[:-1]
            end
            
            # test ASRB/LSRB result
            assertEqual(dst_bit_str, excpeted_bits)
            
            # test negative
            if 128 <= dst <= 255
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if dst == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow(.equal? uneffected!)
            assertEqual(@cpu.cc.V, 0)
            
            # test carry
            source_bit0 = is_bit_set(src, bit=0)
            if source_bit0
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
end


class Test6809_Rotate < BaseCPUTestCase
    """
    unittests for
        * ROL.new(Rotate Left) alias
        * ROR.new(Rotate Right) alias
    end
    """
    
    def assertROL (src, dst, source_carry)
            src_bit_str = '{0:08b}'.format(src)
            dst_bit_str = '{0:08b}'.format(dst)
        end
    end
end
#             print sprintf("%02x %s > ROLA > %02x %s -> %s", 
#                 src, src_bit_str,
#                 dst, dst_bit_str,
#                 @cpu.cc.get_info
#             )
            
            # Carry was cleared and moved into bit 0
            excpeted_bits = sprintf("%s%s", src_bit_str[1:], source_carry)
            assertEqual(dst_bit_str, excpeted_bits)
            
            # test negative
            if dst >= 0x80
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if dst == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow
            source_bit6 = is_bit_set(src, bit=6)
            source_bit7 = is_bit_set(src, bit=7)
            if source_bit6 == source_bit7: # V = bit 6 XOR bit 7
                assertEqual(@cpu.cc.V, 0)
            else
                assertEqual(@cpu.cc.V, 1)
            end
            
            # test carry
            if 0x80 <= src <= 0xff: # if bit 7 was set
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_ROLA_with_clear_carry
        for a in range(0x100)
            @cpu.cc.set(0x00) # clear all CC flags
            a = @cpu.accu_a.set(a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x49, # ROLA
            end
            ])
            r = @cpu.accu_a.get()
            assertROL(a, r, source_carry=0)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 0)
        end
    end
    
    def test_ROLA_with_set_carry
        for a in range(0x100)
            @cpu.cc.set(0xff) # set all CC flags
            a = @cpu.accu_a.set(a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x49, # ROLA
            end
            ])
            r = @cpu.accu_a.get()
            assertROL(a, r, source_carry=1)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 1)
        end
    end
    
    def test_ROL_memory_with_clear_carry
        for a in range(0x100)
            @cpu.cc.set(0x00) # clear all CC flags
            @cpu.memory.write_byte(0x0050, a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x09, 0x50, # ROL #$50
            end
            ])
            r = @cpu.memory.read_byte(0x0050)
            assertROL(a, r, source_carry=0)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 0)
        end
    end
    
    def test_ROL_memory_with_set_carry
        for a in range(0x100)
            @cpu.cc.set(0xff) # set all CC flags
            @cpu.memory.write_byte(0x0050, a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x09, 0x50, # ROL #$50
            end
            ])
            r = @cpu.memory.read_byte(0x0050)
            assertROL(a, r, source_carry=1)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 1)
        end
    end
    
    def assertROR (src, dst, source_carry)
            src_bit_str = '{0:08b}'.format(src)
            dst_bit_str = '{0:08b}'.format(dst)
        end
    end
end
#            print sprintf("%02x %s > RORA > %02x %s -> %s", 
#                src, src_bit_str,
#                dst, dst_bit_str,
#                @cpu.cc.get_info
#            )
            
            # Carry was cleared and moved into bit 0
            excpeted_bits = sprintf("%s%s", source_carry, src_bit_str[:-1])
            assertEqual(dst_bit_str, excpeted_bits)
            
            # test negative
            if dst >= 0x80
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if dst == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test carry
            source_bit0 = is_bit_set(src, bit=0)
            if source_bit0: # if bit 0 was set
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_RORA_with_clear_carry
        for a in range(0x100)
            @cpu.cc.set(0x00) # clear all CC flags
            a = @cpu.accu_a.set(a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x46, # RORA
            end
            ])
            r = @cpu.accu_a.get()
            assertROR(a, r, source_carry=0)
            
            # test half carry and overflow, they are uneffected!
            assertEqual(@cpu.cc.H, 0)
            assertEqual(@cpu.cc.V, 0)
        end
    end
    
    def test_RORA_with_set_carry
        for a in range(0x100)
            @cpu.cc.set(0xff) # set all CC flags
            a = @cpu.accu_a.set(a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x46, # RORA
            end
            ])
            r = @cpu.accu_a.get()
            assertROR(a, r, source_carry=1)
            
            # test half carry and overflow, they are uneffected!
            assertEqual(@cpu.cc.H, 1)
            assertEqual(@cpu.cc.V, 1)
        end
    end
    
    def test_ROR_memory_with_clear_carry
        for a in range(0x100)
            @cpu.cc.set(0x00) # clear all CC flags
            @cpu.memory.write_byte(0x0050, a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x06, 0x50,# ROR #$50
            end
            ])
            r = @cpu.memory.read_byte(0x0050)
            assertROR(a, r, source_carry=0)
            
            # test half carry and overflow, they are uneffected!
            assertEqual(@cpu.cc.H, 0)
            assertEqual(@cpu.cc.V, 0)
        end
    end
    
    def test_ROR_memory_with_set_carry
        for a in range(0x100)
            @cpu.cc.set(0xff) # set all CC flags
            @cpu.memory.write_byte(0x0050, a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x06, 0x50,# ROR #$50
            end
            ])
            r = @cpu.memory.read_byte(0x0050)
            assertROR(a, r, source_carry=1)
            
            # test half carry and overflow, they are uneffected!
            assertEqual(@cpu.cc.H, 1)
            assertEqual(@cpu.cc.V, 1)
        end
    end
end


if __name__ == '__main__'
    unittest.main(
        argv=(
            sys.argv[0],
        end
    end
end
#            "Test6809_LogicalShift.test_ASR_inherent",
#            "Test6809_Rotate",
        ),
    end
end
#         verbosity=1,
        verbosity=2,
    end
end
#         failfast=true,
    )
end
