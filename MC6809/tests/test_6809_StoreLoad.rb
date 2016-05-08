#!/usr/bin/env python

"""
    6809 unittests
    ~~~~~~~~~~~~~~
    
    Test store and load ops
    
    :created: 2014 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2014-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require logging
require sys
require unittest

from MC6809.tests.test_base import BaseStackTestCase


log = logging.getLogger("MC6809")


class Test6809_Store < BaseStackTestCase
    def test_STA_direct
        @cpu.direct_page.set(0x41)
        @cpu.accu_a.set(0xad)
        cpu_test_run(start=0x4000, end_=nil, mem=[0x97, 0xfe]) # STA <$fe(Direct)
        assertEqualHex(@cpu.memory.read_byte(0x41fe), 0xad)
    end
    
    def test_STB_extended
        @cpu.accu_b.set(0x81)
        cpu_test_run(start=0x4000, end_=nil, mem=[0xF7, 0x50, 0x10]) # STB $5010(Extended)
        assertEqualHex(@cpu.memory.read_byte(0x5010), 0x81)
    end
    
    def test_STD_extended
        @cpu.accu_d.set(0x4321)
        cpu_test_run(start=0x4000, end_=nil, mem=[0xFD, 0x50, 0x01]) # STD $5001(Extended)
        assertEqualHex(@cpu.memory.read_word(0x5001), 0x4321)
    end
    
    def test_STS_indexed
        @cpu.system_stack_pointer.set(0x1234)
        @cpu.index_x.set(0x0218)
        cpu_test_run(start=0x1b5c, end_=nil, mem=[0x10, 0xef, 0x83]) # STS ,R-- (indexed)
        assertEqualHex(@cpu.memory.read_word(0x0216), 0x1234) # 0x0218 -2 = 0x0216
    end
end



class Test6809_Load < BaseStackTestCase
    def test_LDD_immediate
        @cpu.accu_d.set(0)
        cpu_test_run(start=0x4000, end_=nil, mem=[0xCC, 0xfe, 0x12]) # LDD $fe12(Immediate)
        assertEqualHex(@cpu.accu_d.value, 0xfe12)
    end
    
    def test_LDD_extended
        @cpu.memory.write_word(0x5020, 0x1234)
        cpu_test_run(start=0x4000, end_=nil, mem=[0xFC, 0x50, 0x20]) # LDD $5020(Extended)
        assertEqualHex(@cpu.accu_d.value, 0x1234)
    end
end


if __name__ == '__main__'
    unittest.main(
        argv=(
            sys.argv[0],
            # "Test6809_Store.test_STS_indexed",
        end
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
