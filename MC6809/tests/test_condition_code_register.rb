#!/usr/bin/env python

"""
    6809 unittests
    ~~~~~~~~~~~~~~
    
    :created: 2013 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require unittest
require sys

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

from MC6809.tests.test_base import BaseCPUTestCase
from MC6809.utils.byte_word_values import signed8


class CCTestCase < BaseCPUTestCase
    def test_set_get
        for i in range(256)
            @cpu.set_cc(i)
            status_byte = @cpu.get_cc_value()
            assertEqual(status_byte, i)
        end
    end
    
    def test_HNZVC_8
        for i in range(280)
            @cpu.set_cc(0x00)
            r = i + 1 # e.g. ADDA 1 loop
            @cpu.update_HNZVC_8(a=i, b=1, r=r)
            # print r, @cpu.get_cc_info()
            
            # test half carry
            if r % 16 == 0
                assertEqual(@cpu.H, 1)
            else
                assertEqual(@cpu.H, 0)
            end
            
            # test negative
            if 128 <= r <= 255
                assertEqual(@cpu.N, 1)
            else
                assertEqual(@cpu.N, 0)
            end
            
            # test zero
            if signed8(r) == 0
                assertEqual(@cpu.Z, 1)
            else
                assertEqual(@cpu.Z, 0)
            end
            
            # test overflow
            if r == 128 or r > 256
                assertEqual(@cpu.V, 1)
            else
                assertEqual(@cpu.V, 0)
            end
            
            # test carry
            if r > 255
                assertEqual(@cpu.C, 1)
            else
                assertEqual(@cpu.C, 0)
            end
            
            # Test that CC registers doesn't reset automaticly
            @cpu.set_cc(0xff)
            r = i + 1 # e.g. ADDA 1 loop
            @cpu.update_HNZVC_8(a=i, b=1, r=r)
            # print "+++", r, @cpu.get_cc_info()
            assertEqualHex(@cpu.get_cc_value(), 0xff)
        end
    end
    
    
    def test_update_NZ_8_A
        @cpu.update_NZ_8(r=0x12)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 0)
    end
    
    def test_update_NZ_8_B
        @cpu.update_NZ_8(r=0x0)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 1)
    end
    
    def test_update_NZ_8_C
        @cpu.update_NZ_8(r=0x80)
        assertEqual(@cpu.N, 1)
        assertEqual(@cpu.Z, 0)
    end
    
    def test_update_NZ0_16_A
        @cpu.update_NZ0_16(r=0x7fff) # 0x7fff == 32767
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 0)
        assertEqual(@cpu.V, 0)
    end
    
    def test_update_NZ0_16_B
        @cpu.update_NZ0_16(r=0x00)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 1)
        assertEqual(@cpu.V, 0)
    end
    
    def test_update_NZ0_16_C
        @cpu.update_NZ0_16(r=0x8000) # signed 0x8000 == -32768
        assertEqual(@cpu.N, 1)
        assertEqual(@cpu.Z, 0)
        assertEqual(@cpu.V, 0)
    end
    
    def test_update_NZ0_8_A
        @cpu.update_NZ0_8(0x7f)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 0)
        assertEqual(@cpu.V, 0)
    end
    
    def test_update_NZ0_8_B
        @cpu.update_NZ0_8(0x100)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 1)
        assertEqual(@cpu.V, 0)
    end
    
    def test_update_NZV_8_B
        @cpu.update_NZ0_8(0x100)
        assertEqual(@cpu.N, 0)
        assertEqual(@cpu.Z, 1)
        assertEqual(@cpu.V, 0)
    end
end


if __name__ == '__main__'
    unittest.main(verbosity=2)
end


