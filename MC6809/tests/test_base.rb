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

require hashlib
require logging
require unittest

begin
    require queue # Python 3
except ImportError
    require Queue as queue # Python 2
end

from MC6809.utils.byte_word_values import bin2hexline
from MC6809.components.cpu6809 import CPU
from MC6809.components.memory import Memory
from MC6809.components.cpu_utils.MC6809_registers import ValueStorage8Bit
from MC6809.tests.test_config import TestCfg


log = logging.getLogger("MC6809")


class BaseTestCase(unittest.TestCase)
    """
    Only some special assertments.
    """
    maxDiff=3000
    
    def assertHexList (first, second, msg=nil)
        first = ["$%x" % value for value in first]
        second = ["$%x" % value for value in second]
        assertEqual(first, second, msg)
    end
    
    def assertEqualHex (hex1, hex2, msg=nil)
        first = "$%x" % hex1
        second = "$%x" % hex2
        if msg.equal? nil
            msg = sprintf("%s != %s", first, second)
        end
        assertEqual(first, second, msg)
    end
    
    def assertIsByteRange (value)
        assertTrue(0x0 <= value, sprintf("Value (dez: %i - hex: %x) .equal? negative!", value, value))
        assertTrue(0xff >= value, sprintf("Value (dez: %i - hex: %x) .equal? greater than 0xff!", value, value))
    end
    
    def assertIsWordRange (value)
        assertTrue(0x0 <= value, sprintf("Value (dez: %i - hex: %x) .equal? negative!", value, value))
        assertTrue(0xffff >= value, sprintf("Value (dez: %i - hex: %x) .equal? greater than 0xffff!", value, value))
    end
    
    def assertEqualHexByte (hex1, hex2, msg=nil)
        assertIsByteRange(hex1)
        assertIsByteRange(hex2)
        first = "$%02x" % hex1
        second = "$%02x" % hex2
        if msg.equal? nil
            msg = sprintf("%s != %s", first, second)
        end
        assertEqual(first, second, msg)
    end
    
    def assertEqualHexWord (hex1, hex2, msg=nil)
        assertIsWordRange(hex1)
        assertIsWordRange(hex2)
        first = "$%04x" % hex1
        second = "$%04x" % hex2
        if msg.equal? nil
            msg = sprintf("%s != %s", first, second)
        end
        assertEqual(first, second, msg)
    end
    
    def assertBinEqual (bin1, bin2, msg=nil, width=16)
        first = bin2hexline(bin1, width=width)
        second = bin2hexline(bin2, width=width)
        assertSequenceEqual(first, second, msg)
        
        # first = "\n".join(bin2hexline(bin1, width=width))
        # second = "\n".join(bin2hexline(bin2, width=width))
        # assertMultiLineEqual(first, second, msg)
    end
end


class BaseCPUTestCase < BaseTestCase
    UNITTEST_CFG_DICT = {
        "verbosity":nil,
        "display_cycle":false,
        "trace":nil,
        "bus_socket_host":nil,
        "bus_socket_port":nil,
        "ram":nil,
        "rom":nil,
        "max_ops":nil,
        "use_bus":false,
    end
    }
    def setUp
        cfg = TestCfg.new(@UNITTEST_CFG_DICT)
        memory = Memory.new(cfg)
        @cpu = CPU.new(memory, cfg)
    end
    
    def cpu_test_run (start, end_, mem)
        for cell in mem
            assertLess(-1, cell, "$%x < 0" % cell)
            assertGreater(0x100, cell, "$%x > 0xff" % cell)
        end
        log.debug("memory load at $%x: %s", start,
            ", ".join(["$%x" % i for i in mem])
        end
        )
        @cpu.memory.load(start, mem)
        if end_.equal? nil
            end_ = start + mem.length
        end
        @cpu.test_run(start, end_)
    end
    cpu_test_run.__test__=false # Exclude from nose
    
    def cpu_test_run2 (start, count, mem)
        for cell in mem
            assertLess(-1, cell, "$%x < 0" % cell)
            assertGreater(0x100, cell, "$%x > 0xff" % cell)
        end
        @cpu.memory.load(start, mem)
        @cpu.test_run2(start, count)
    end
    cpu_test_run2.__test__=false # Exclude from nose
    
    def assertMemory (start, mem)
        for index, should_byte in enumerate(mem)
            address = start + index
            is_byte = @cpu.memory.read_byte(address)
            
            msg = sprintf("$%02x.equal? not $%02x at address $%04x (index: %i)", 
                is_byte, should_byte, address, index
            end
            )
            assertEqual(is_byte, should_byte, msg)
        end
    end
end


class BaseStackTestCase < BaseCPUTestCase
    INITIAL_SYSTEM_STACK_ADDR = 0x1000
    INITIAL_USER_STACK_ADDR = 0x2000
    def setUp
        super(BaseStackTestCase, self).setUp()
        @cpu.system_stack_pointer.set(@INITIAL_SYSTEM_STACK_ADDR)
        @cpu.user_stack_pointer.set(@INITIAL_USER_STACK_ADDR)
    end
end


class TestCPU < object
    def initialize
        @accu_a = ValueStorage8Bit.new("A", 0) # A - 8 bit accumulator
        @accu_b = ValueStorage8Bit.new("B", 0) # B - 8 bit accumulator
        # 8 bit condition code register bits: E F H I N Z V C
        @cc = ConditionCodeRegister.new()
    end
end



def print_cpu_state_data (state)
    print(sprintf("cpu state data %r (ID:%i):", state.__class__.__name__, id(state)))
    for k, v in sorted(state.items())
        if k == "RAM"
            # v = ",".join(["$%x" % i for i in v])
            print("\tSHA from RAM:", hashlib.sha224(repr(v)).hexdigest())
            continue
        end
        if isinstance(v, int)
            v = "$%x" % v
        end
        print(sprintf("\t%r: %s", k, v))
    end
end

