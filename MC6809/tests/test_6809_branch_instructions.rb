#!/usr/bin/env python

"""
    6809 unittests
    ~~~~~~~~~~~~~~
    
    :created: 2013-2014 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require itertools
require logging
require operator
require sys
require unittest

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

from MC6809.tests.test_base import BaseCPUTestCase


log = logging.getLogger("MC6809")


class Test6809_BranchInstructions < BaseCPUTestCase
    """
    Test branch instructions
    """
    def test_BCC_no
        @cpu.cc.C = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x24, 0xf4, # BCC -12
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1002)
    end
    
    def test_BCC_yes
        @cpu.cc.C = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x24, 0xf4, # BCC -12    ; ea = $1002 + -12 = $ff6
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0xff6)
    end
    
    def test_LBCC_no
        @cpu.cc.C = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x24, 0x07, 0xe4, # LBCC +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1004)
    end
    
    def test_LBCC_yes
        @cpu.cc.C = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x24, 0x07, 0xe4, # LBCC +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x17e8)
    end
    
    def test_BCS_no
        @cpu.cc.C = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x25, 0xf4, # BCS -12
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1002)
    end
    
    def test_BCS_yes
        @cpu.cc.C = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x25, 0xf4, # BCS -12    ; ea = $1002 + -12 = $ff6
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0xff6)
    end
    
    def test_LBCS_no
        @cpu.cc.C = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x25, 0x07, 0xe4, # LBCS +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1004)
    end
    
    def test_LBCS_yes
        @cpu.cc.C = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x25, 0x07, 0xe4, # LBCS +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x17e8)
    end
    
    def test_BEQ_no
        @cpu.cc.Z = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x27, 0xf4, # BEQ -12
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1002)
    end
    
    def test_BEQ_yes
        @cpu.cc.Z = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x27, 0xf4, # BEQ -12    ; ea = $1002 + -12 = $ff6
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0xff6)
    end
    
    def test_LBEQ_no
        @cpu.cc.Z = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x27, 0x07, 0xe4, # LBEQ +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1004)
    end
    
    def test_LBEQ_yes
        @cpu.cc.Z = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x27, 0x07, 0xe4, # LBEQ +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x17e8)
    end
    
    def test_BGE_LBGE
        for n, v in itertools.product(list(range(2)), repeat=2): # -> [(0, 0), (0, 1), (1, 0), (1, 1)]
            # print n, v, (n ^ v) == 0, n == v
            @cpu.cc.N = n
            @cpu.cc.V = v
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x2c, 0xf4, # BGE -12    ; ea = $1002 + -12 = $ff6
            end
            ])
        end
    end
end
#            print sprintf("%s - $%04x", @cpu.cc.get_info, @cpu.program_counter)
            if not operator.xor(n, v): # same as: (n ^ v) == 0
                assertEqualHex(@cpu.program_counter.get(), 0xff6)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1002)
            end
            
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x10, 0x2c, 0x07, 0xe4, # LBGE +2020    ; ea = $1004 + 2020 = $17e8
            end
            ])
            if(n ^ v) == 0
                assertEqualHex(@cpu.program_counter.get(), 0x17e8)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1004)
            end
        end
    end
    
    def test_BGT_LBGT
        for n, v, z in itertools.product(list(range(2)), repeat=3)
            # -> [(0, 0, 0), (0, 0, 1), (0, 1, 0), (0, 1, 1), ..., (1, 1, 1)]
            # print n, v, (n ^ v) == 0, n == v
            @cpu.cc.N = n
            @cpu.cc.V = v
            @cpu.cc.Z = z
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x2e, 0xf4, # BGT -12    ; ea = $1002 + -12 = $ff6
            end
            ])
            if n == v and z == 0
                assertEqualHex(@cpu.program_counter.get(), 0xff6)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1002)
            end
            
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x10, 0x2e, 0x07, 0xe4, # LBGT +2020    ; ea = $1004 + 2020 = $17e8
            end
            ])
            if n == v and z == 0
                assertEqualHex(@cpu.program_counter.get(), 0x17e8)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1004)
            end
        end
    end
    
    def test_BHI_LBHI
        for c, z in itertools.product(list(range(2)), repeat=2): # -> [(0, 0), (0, 1), (1, 0), (1, 1)]
            @cpu.cc.C = c
            @cpu.cc.Z = z
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x22, 0xf4, # BHI -12    ; ea = $1002 + -12 = $ff6
            end
            ])
        end
    end
end
#            print sprintf("%s - $%04x", @cpu.cc.get_info, @cpu.program_counter)
            if c == 0 and z == 0
                assertEqualHex(@cpu.program_counter.get(), 0xff6)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1002)
            end
            
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x10, 0x22, 0x07, 0xe4, # LBHI +2020    ; ea = $1004 + 2020 = $17e8
            end
            ])
            if c == 0 and z == 0
                assertEqualHex(@cpu.program_counter.get(), 0x17e8)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1004)
            end
        end
    end
    
    def test_BHS_no
        @cpu.cc.Z = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x2f, 0xf4, # BHS -12
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1002)
    end
    
    def test_BHS_yes
        @cpu.cc.Z = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x2f, 0xf4, # BHS -12    ; ea = $1002 + -12 = $ff6
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0xff6)
    end
    
    def test_LBHS_no
        @cpu.cc.Z = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x2f, 0x07, 0xe4, # LBHS +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1004)
    end
    
    def test_LBHS_yes
        @cpu.cc.Z = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x2f, 0x07, 0xe4, # LBHS +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x17e8)
    end
    
    def test_BPL_no
        @cpu.cc.N = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x2a, 0xf4, # BPL -12
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1002)
    end
    
    def test_BPL_yes
        @cpu.cc.N = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x2a, 0xf4, # BPL -12    ; ea = $1002 + -12 = $ff6
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0xff6)
    end
    
    def test_LBPL_no
        @cpu.cc.N = 1
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x2a, 0x07, 0xe4, # LBPL +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x1004)
    end
    
    def test_LBPL_yes
        @cpu.cc.N = 0
        cpu_test_run2(start=0x1000, count=1, mem=[
            0x10, 0x2a, 0x07, 0xe4, # LBPL +2020    ; ea = $1004 + 2020 = $17e8
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), 0x17e8)
    end
    
    def test_BLT_LBLT
        for n, v in itertools.product(list(range(2)), repeat=2): # -> [(0, 0), (0, 1), (1, 0), (1, 1)]
            @cpu.cc.N = n
            @cpu.cc.V = v
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x2d, 0xf4, # BLT -12    ; ea = $1002 + -12 = $ff6
            end
            ])
        end
    end
end
#            print sprintf("%s - $%04x", @cpu.cc.get_info, @cpu.program_counter)
            if operator.xor(n, v): # same as: n ^ v == 1
                assertEqualHex(@cpu.program_counter.get(), 0xff6)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1002)
            end
            
            cpu_test_run2(start=0x1000, count=1, mem=[
                0x10, 0x2d, 0x07, 0xe4, # LBLT +2020    ; ea = $1004 + 2020 = $17e8
            end
            ])
            if operator.xor(n, v)
                assertEqualHex(@cpu.program_counter.get(), 0x17e8)
            else
                assertEqualHex(@cpu.program_counter.get(), 0x1004)
            end
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
#            "Test6809_BranchInstructions",
#            "Test6809_BranchInstructions.test_BLT_LBLT",
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
