#!/usr/bin/env python

"""
    6809 unittests
    ~~~~~~~~~~~~~~
    
    Register changed Ops: TFR, EXG
    
    :created: 2014 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2014-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require logging
require sys
require unittest

from MC6809.tests.test_base import BaseCPUTestCase


log = logging.getLogger("MC6809")


class Test6809_TFR < BaseCPUTestCase
    def test_TFR_A_B
        @cpu.accu_a.set(0x12)
        @cpu.accu_b.set(0x34)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1F, 0x89, # TFR A,B
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0x12)
        assertEqualHexByte(@cpu.accu_b.value, 0x12)
    end
    
    def test_TFR_B_A
        @cpu.accu_a.set(0x12)
        @cpu.accu_b.set(0x34)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1F, 0x98, # TFR B,A
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0x34)
        assertEqualHexByte(@cpu.accu_b.value, 0x34)
    end
    
    def test_TFR_X_U
        """
        LDX #$1234
        LDU #$abcd
        TFR X,U
        STX $20
        STU $30
        """
        @cpu.index_x.set(0x1234)
        @cpu.user_stack_pointer.set(0xabcd)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1F, 0x13, # TFR X,U
        end
        ])
        assertEqualHexWord(@cpu.index_x.value, 0x1234)
        assertEqualHexWord(@cpu.user_stack_pointer.value, 0x1234)
    end
    
    def test_TFR_CC_X
        """
        transfer 8 bit register in a 16 bit register
        TODO: verify this behaviour on real hardware!
        """
        @cpu.set_cc(0x34)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x1F, 0xA1, # TFR CC,X
        end
        ])
        assertEqualHexByte(@cpu.get_cc_value(), 0x34)
        assertEqualHexWord(@cpu.index_x.value, 0xff34)
    end
    
    def test_TFR_CC_A
        """
        transfer 8 bit register in a 16 bit register
        TODO: verify this behaviour on real hardware!
        """
        @cpu.accu_a.set(0xab)
        @cpu.set_cc(0x89)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x1F, 0xA8, # TFR CC,A
        end
        ])
        assertEqualHexByte(@cpu.get_cc_value(), 0x89)
        assertEqualHexByte(@cpu.accu_a.value, 0x89)
    end
    
    def test_TFR_Y_B
        """
        transfer 16 bit register in a 8 bit register
        TODO: verify this behaviour on real hardware!
        """
        @cpu.index_y.set(0x1234)
        @cpu.accu_b.set(0xab)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x1F, 0x29, # TFR Y,B
        end
        ])
        assertEqualHexWord(@cpu.index_y.value, 0x1234)
        assertEqualHexByte(@cpu.accu_b.value, 0x34)
    end
    
    def test_TFR_undefined_A
        """
        transfer undefined register in a 8 bit register
        TODO: verify this behaviour on real hardware!
        """
        @cpu.accu_a.set(0x12)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x1F, 0x68, # TFR undefined,A
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0xff)
    end
end


class Test6809_EXG < BaseCPUTestCase
    def test_EXG_A_B
        @cpu.accu_a.set(0xab)
        @cpu.accu_b.set(0x12)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1E, 0x89, # EXG A,B
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0x12)
        assertEqualHexByte(@cpu.accu_b.value, 0xab)
    end
    
    def test_EXG_X_Y
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x8E, 0xAB, 0xCD, #       LDX   #$abcd     ; set X to $abcd
            0x10, 0x8E, 0x80, 0x4F, # LDY   #$804f     ; set Y to $804f
            0x1E, 0x12, #             EXG   X,Y        ; y,x=x,y
            0x9F, 0x20, #             STX   $20        ; store X to $20
            0x10, 0x9F, 0x40, #       STY   $40        ; store Y to $40
        end
        ])
        assertEqualHexWord(@cpu.memory.read_word(0x20), 0x804f) # X
        assertEqualHexWord(@cpu.memory.read_word(0x40), 0xabcd) # Y
    end
    
    def test_EXG_A_X
        """
        exange 8 bit register with a 16 bit register
        TODO: verify this behaviour on real hardware!
        """
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x86, 0x56, #             LDA   #$56
            0x8E, 0x12, 0x34, #       LDX   #$1234
            0x1E, 0x81, #             EXG   A,X
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0x34)
        assertEqualHexWord(@cpu.index_x.value, 0xff56)
    end
    
    def test_EXG_A_CC
        """
        TODO: verify this behaviour on real hardware!
        """
        @cpu.accu_a.set(0x1f)
        @cpu.set_cc(0xe2)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1E, 0x8A, # EXG A,CC
        end
        ])
        assertEqualHexByte(@cpu.accu_a.value, 0xe2)
        assertEqualHexByte(@cpu.get_cc_value(), 0x1f)
    end
    
    def test_EXG_X_CC
        """
        TODO: verify this behaviour on real hardware!
        """
        @cpu.index_x.set(0x1234)
        @cpu.set_cc(0x56)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1E, 0x1A, # EXG X,CC
        end
        ])
        assertEqualHexWord(@cpu.index_x.value, 0xff56)
        assertEqualHexByte(@cpu.get_cc_value(), 0x34)
    end
    
    def test_EXG_undefined_to_X
        """
        TODO: verify this behaviour on real hardware!
        """
        @cpu.index_x.set(0x1234)
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x1E, 0xd1, # EXG undefined,X
        end
        ])
        assertEqualHexWord(@cpu.index_x.value, 0xffff)
    end
end



if __name__ == '__main__'
    unittest.main(
        argv=(
            sys.argv[0],
        end
    end
end
#            "Test6809_TFR",
#             "Test6809_TFR.test_TFR_CC_A",
#            "Test6809_EXG",
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
