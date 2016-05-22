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
from MC6809.tests.test_base import BaseCPUTestCase


class CC_AccumulatorTestCase < BaseCPUTestCase
    def test_A_01
        @cpu.accu_a.set(0xff)
        assertEqualHex(@cpu.accu_a.get(), 0xff)
    end
    
    def test_A_02
        @cpu.accu_a.set(0xff + 1)
        assertEqualHex(@cpu.accu_a.get(), 0x00)
    end
    
    def test_B_01
        @cpu.accu_b.set(0x5a)
        assertEqualHex(@cpu.accu_b.get(), 0x5a)
        assertEqual(@cpu.cc.V, 0)
    end
    
    def test_B_02
        @cpu.accu_b.set(0xff + 10)
        assertEqualHex(@cpu.accu_b.get(), 0x09)
    end
    
    def test_D_01
        @cpu.accu_a.set(0x12)
        @cpu.accu_b.set(0xab)
        assertEqualHex(@cpu.accu_d.get(), 0x12ab)
    end
    
    def test_D_02
        @cpu.accu_d.set(0xfd89)
        assertEqualHex(@cpu.accu_a.get(), 0xfd)
        assertEqualHex(@cpu.accu_b.get(), 0x89)
    end
    
    def test_D_03
        @cpu.accu_d.set(0xffff + 1)
        assertEqualHex(@cpu.accu_a.get(), 0x00)
        assertEqualHex(@cpu.accu_b.get(), 0x00)
    end
end


if __name__ == '__main__'
    unittest.main(verbosity=2)
end
