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

require logging
require sys
require unittest

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

from MC6809.tests.test_base import BaseCPUTestCase, BaseStackTestCase


log = logging.getLogger("MC6809")


class Test6809_Register < BaseCPUTestCase
    def test_registerA
        for i in range(255)
            @cpu.accu_a.set(i)
            t = @cpu.accu_a.get()
            assertEqual(i, t)
        end
    end
    
    def test_register_8bit_overflow
        @cpu.accu_a.set(0xff)
        a = @cpu.accu_a.get()
        assertEqualHex(a, 0xff)
        
        @cpu.accu_a.set(0x100)
        a = @cpu.accu_a.get()
        assertEqualHex(a, 0)
        
        @cpu.accu_a.set(0x101)
        a = @cpu.accu_a.get()
        assertEqualHex(a, 0x1)
    end
    
    def test_register_8bit_negative
        @cpu.accu_a.set(0)
        t = @cpu.accu_a.get()
        assertEqualHex(t, 0)
        
        @cpu.accu_a.set(-1)
        t = @cpu.accu_a.get()
        assertEqualHex(t, 0xff)
        
        @cpu.accu_a.set(-2)
        t = @cpu.accu_a.get()
        assertEqualHex(t, 0xfe)
    end
    
    def test_register_16bit_overflow
        @cpu.index_x.set(0xffff)
        x = @cpu.index_x.get()
        assertEqual(x, 0xffff)
        
        @cpu.index_x.set(0x10000)
        x = @cpu.index_x.get()
        assertEqual(x, 0)
        
        @cpu.index_x.set(0x10001)
        x = @cpu.index_x.get()
        assertEqual(x, 1)
    end
    
    def test_register_16bit_negative1
        @cpu.index_x.set(-1)
        x = @cpu.index_x.get()
        assertEqualHex(x, 0xffff)
        
        @cpu.index_x.set(-2)
        x = @cpu.index_x.get()
        assertEqualHex(x, 0xfffe)
    end
    
    def test_register_16bit_negative2
        @cpu.index_x.set(0)
        x = @cpu.index_x.decrement()
        assertEqualHex(x, 0x10000 - 1)
        
        @cpu.index_x.set(0)
        x = @cpu.index_x.decrement(2)
        assertEqualHex(x, 0x10000 - 2)
    end
end


class Test6809_ZeroFlag < BaseCPUTestCase
    def test_DECA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0x1, # LDA $01
            0x4A, #      DECA
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_DECB
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0xC6, 0x1, # LDB $01
            0x5A, #      DECB
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_ADDA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0xff, # LDA $FF
            0x8B, 0x01, # ADDA #1
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_CMPA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0x00, # LDA $00
            0x81, 0x00, # CMPA %00
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_COMA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0xFF, # LDA $FF
            0x43, #       COMA
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_NEGA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0xFF, # LDA $FF
            0x40, #       NEGA
        end
        ])
        assertEqual(@cpu.cc.Z, 0)
    end
    
    def test_ANDA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0xF0, # LDA $F0
            0x84, 0x0F, # ANDA $0F
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_TFR
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0x04, # LDA $04
            0x1F, 0x8a, # TFR A,CCR
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
    
    def test_CLRA
        assertEqual(@cpu.cc.Z, 0)
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x4F, # CLRA
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
    end
end




class Test6809_CC < BaseCPUTestCase
    """
    condition code register tests
    """
    def test_defaults
        status_byte = @cpu.cc.get()
        assertEqual(status_byte, 0)
    end
    
    def test_from_to
        for i in range(256)
            @cpu.cc.set(i)
            status_byte = @cpu.cc.get()
            assertEqual(status_byte, i)
        end
    end
    
    def test_AND
        excpected_values = list(range(0, 128))
        excpected_values += list(range(0, 128))
        excpected_values += list(range(0, 4))
        
        for i in range(260)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0x0e) # Set affected flags: ....NZV.
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x84, 0x7f, # ANDA #$7F
            end
            ])
            r = @cpu.accu_a.get()
            excpected_value = excpected_values[i]
        end
    end
end
#             print i, r, excpected_value, @cpu.cc.get_info, @cpu.cc.get()
            
            # test AND result
            assertEqual(r, excpected_value)
            
            # test all CC flags
            if r == 0
                assertEqual(@cpu.cc.get(), 4)
            else
                assertEqual(@cpu.cc.get(), 0)
            end
        end
    end
end


class Test6809_Ops < BaseCPUTestCase
    def test_TFR01
        @cpu.index_x.set(512) # source
        assertEqual(@cpu.index_y.get(), 0) # destination
        
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0x1f, # TFR
            0x12, # from index register X(0x01) to Y(0x02)
        end
        ])
        assertEqual(@cpu.index_y.get(), 512)
    end
    
    def test_TFR02
        @cpu.accu_b.set(0x55) # source
        assertEqual(@cpu.cc.get(), 0) # destination
        
        cpu_test_run(start=0x1000, end_=0x1002, mem=[
            0x1f, # TFR
            0x9a, # from accumulator B(0x9) to condition code register CC.new(0xa)
        end
        ])
        assertEqual(@cpu.cc.get(), 0x55) # destination
    end
    
    def test_TFR03
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x10, 0x8e, 0x12, 0x34, # LDY Y=$1234
            0x1f, 0x20, # TFR  Y,D
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0x1234) # destination
    end
    
    def test_CMPU_immediate
        u = 0x80
        @cpu.user_stack_pointer.set(u)
        for m in range(0x7e, 0x83)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x11, 0x83, # CMPU.new(immediate word)
                0x00, m # the word that CMP reads
            end
            ])
            r = u - m
            """
            80 - 7e = 02 -> ........
            80 - 7f = 01 -> ........
            80 - 80 = 00 -> .....Z..
            80 - 81 = -1 -> ....N..C
            80 - 82 = -2 -> ....N..C
            """
        end
    end
end
#             print sprintf("%02x - %02x = %02x -> %s", 
#                 u, m, r, @cpu.cc.get_info
#             )
            
            # test negative: 0x01 <= a <= 0x80
            if r < 0
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
            
            # test carry.equal? set if r=1-255(hex: r=$01 - $ff)
            if r < 0
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_CMPA_immediate_byte
        a = 0x80
        @cpu.accu_a.set(a)
        for m in range(0x7e, 0x83)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x81, m # CMPA.new(immediate byte)
            end
            ])
            r = a - m
            """
            80 - 7e = 02 -> ......V.
            80 - 7f = 01 -> ......V.
            80 - 80 = 00 -> .....Z..
            80 - 81 = -1 -> ....N..C
            80 - 82 = -2 -> ....N..C
            """
        end
    end
end
#             print sprintf("%02x - %02x = %02x -> %s", 
#                 a, m, r, @cpu.cc.get_info
#             )
            
            # test negative: 0x01 <= a <= 0x80
            if r < 0
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
            if r > 0
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry.equal? set if r=1-255(hex: r=$01 - $ff)
            if r < 0
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_CMPX_immediate_word
        x = 0x80
        @cpu.index_x.set(x)
        for m in range(0x7e, 0x83)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x8c, 0x00, m # CMPX.new(immediate word)
            end
            ])
            r = x - m
            """
            80 - 7e = 02 -> ........
            80 - 7f = 01 -> ........
            80 - 80 = 00 -> .....Z..
            80 - 81 = -1 -> ....N..C
            80 - 82 = -2 -> ....N..C
            """
        end
    end
end
#             print sprintf("%02x - %02x = %02x -> %s", 
#                 x, m, r, @cpu.cc.get_info
#             )
            
            # test negative: 0x01 <= a <= 0x80
            if r < 0
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
            
            # test carry.equal? set if r=1-255(hex: r=$01 - $ff)
            if r < 0
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_ABX_01
        @cpu.cc.set(0xff)
        @cpu.accu_b.set(0x0f)
        @cpu.index_x.set(0x00f0)
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0x3A, # ABX
        end
        ])
        assertEqualHex(@cpu.index_x.get(), 0x00ff)
        assertEqualHex(@cpu.cc.get(), 0xff)
        
        @cpu.cc.set(0x00)
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0x3A, # ABX
        end
        ])
        assertEqualHex(@cpu.index_x.get(), 0x010E)
        assertEqualHex(@cpu.cc.get(), 0x00)
    end
end


class Test6809_TestInstructions < BaseCPUTestCase
    def assertTST (i)
        if 128 <= i <= 255: # test negative
            assertEqual(@cpu.cc.N, 1)
        else
            assertEqual(@cpu.cc.N, 0)
        end
        
        if i == 0: # test zero
            assertEqual(@cpu.cc.Z, 1)
        else
            assertEqual(@cpu.cc.Z, 0)
        end
        
        # test overflow
        assertEqual(@cpu.cc.V, 0)
        
        # test not affected flags
        assertEqual(@cpu.cc.E, 1)
        assertEqual(@cpu.cc.F, 1)
        assertEqual(@cpu.cc.H, 1)
        assertEqual(@cpu.cc.I, 1)
        assertEqual(@cpu.cc.C, 1)
    end
    
    def test_TST_direct
        for i in range(255)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0xff) # Set all CC flags
            
            @cpu.memory.write_byte(address=0x00, value=i)
            
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x0D, 0x00 # TST $00
            end
            ])
            assertTST(i)
        end
    end
    
    def test_TST_extended
        for i in range(255)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0xff) # Set all CC flags
            
            @cpu.memory.write_byte(address=0x1234, value=i)
            
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x7D, 0x12, 0x34 # TST $1234
            end
            ])
            assertTST(i)
        end
    end
    
    def test_TSTA
        for i in range(255)
            @cpu.accu_a.set(i)
            @cpu.cc.set(0xff) # Set all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x4D # TSTA
            end
            ])
            assertTST(i)
        end
    end
    
    def test_TSTB
        for i in range(255)
            @cpu.accu_b.set(i)
            @cpu.cc.set(0xff) # Set all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x5D # TSTB
            end
            ])
            assertTST(i)
        end
    end
end








# TODO
#        cpu_test_run(start=0x4000, end_=nil, mem=[0x4F]) # CLRA
#        assertEqualHex(@cpu.accu_d.get(), 0x34)
#
#        cpu_test_run(start=0x4000, end_=nil, mem=[0x5F]) # CLRB
#        assertEqualHex(@cpu.accu_d.get(), 0x0)


class Test6809_Stack < BaseStackTestCase
    def test_PushPullSytemStack_01
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR
        end
        )
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0x1a, # LDA A=$1a
            0x34, 0x02, # PSHS A
        end
        ])
        
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR - 1 # Byte added
        end
        )
        
        assertEqualHex(@cpu.accu_a.get(), 0x1a)
        
        @cpu.accu_a.set(0xee)
        
        assertEqualHex(@cpu.accu_b.get(), 0x00)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x35, 0x04, # PULS B  ;  B gets the value from A = 1a
        end
        ])
        
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR # Byte removed
        end
        )
        
        assertEqualHex(@cpu.accu_a.get(), 0xee)
        assertEqualHex(@cpu.accu_b.get(), 0x1a)
    end
    
    def test_PushPullSystemStack_02
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR
        end
        )
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0xab, # LDA A=$ab
            0x34, 0x02, # PSHS A
            0x86, 0x02, # LDA A=$02
            0x34, 0x02, # PSHS A
            0x86, 0xef, # LDA A=$ef
        end
        ])
        assertEqualHex(@cpu.accu_a.get(), 0xef)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x35, 0x04, # PULS B
        end
        ])
        assertEqualHex(@cpu.accu_a.get(), 0xef)
        assertEqualHex(@cpu.accu_b.get(), 0x02)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x35, 0x02, # PULS A
        end
        ])
        assertEqualHex(@cpu.accu_a.get(), 0xab)
        assertEqualHex(@cpu.accu_b.get(), 0x02)
        
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR
        end
        )
    end
    
    def test_PushPullSystemStack_03
        assertEqualHex(
            @cpu.system_stack_pointer.get(),
            @INITIAL_SYSTEM_STACK_ADDR
        end
        )
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0xcc, 0x12, 0x34, # LDD D=$1234
            0x34, 0x06, # PSHS B,A
            0xcc, 0xab, 0xcd, # LDD D=$abcd
            0x34, 0x06, # PSHS B,A
            0xcc, 0x54, 0x32, # LDD D=$5432
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0x5432)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x35, 0x06, # PULS B,A
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0xabcd)
        assertEqualHex(@cpu.accu_a.get(), 0xab)
        assertEqualHex(@cpu.accu_b.get(), 0xcd)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x35, 0x06, # PULS B,A
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0x1234)
    end
    
    def test_PushPullUserStack_01
        assertEqualHex(
            @cpu.user_stack_pointer.get(),
            @INITIAL_USER_STACK_ADDR
        end
        )
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0xcc, 0x12, 0x34, # LDD D=$1234
            0x36, 0x06, # PSHU B,A
            0xcc, 0xab, 0xcd, # LDD D=$abcd
            0x36, 0x06, # PSHU B,A
            0xcc, 0x54, 0x32, # LDD D=$5432
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0x5432)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x37, 0x06, # PULU B,A
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0xabcd)
        assertEqualHex(@cpu.accu_a.get(), 0xab)
        assertEqualHex(@cpu.accu_b.get(), 0xcd)
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x37, 0x06, # PULU B,A
        end
        ])
        assertEqualHex(@cpu.accu_d.get(), 0x1234)
    end
end


class Test6809_Code < BaseCPUTestCase
    """
    Test with some small test codes
    """
    def test_code01
        @cpu.memory.load(
            0x2220, [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]
        end
        )
        
        cpu_test_run(start=0x4000, end_=nil, mem=[
            0x86, 0x22, #       LDA $22    ; Immediate
            0x8E, 0x22, 0x22, # LDX $2222  ; Immediate
            0x1F, 0x89, #       TFR A,B    ; Inherent.new(Register)
            0x5A, #             DECB       ; Inherent.new(Implied)
            0xED, 0x84, #       STD ,X     ; Indexed.new(non indirect)
            0x4A, #             DECA       ; Inherent.new(Implied)
            0xA7, 0x94, #       STA [,X]   ; Indexed.new(indirect)
        end
        ])
        assertEqualHex(@cpu.accu_a.get(), 0x21)
        assertEqualHex(@cpu.accu_b.get(), 0x21)
        assertEqualHex(@cpu.accu_d.get(), 0x2121)
        assertEqualHex(@cpu.index_x.get(), 0x2222)
        assertEqualHex(@cpu.index_y.get(), 0x0000)
        assertEqualHex(@cpu.direct_page.get(), 0x00)
        
        assertMemory(
            start=0x2220,
            mem=[0xFF, 0x21, 0x22, 0x21, 0xFF, 0xFF]
        end
        )
    end
    
    def test_code02
        cpu_test_run(start=0x2000, end_=nil, mem=[
            0x10, 0x8e, 0x30, 0x00, #       2000|       LDY $3000
            0xcc, 0x10, 0x00, #             2004|       LDD $1000
            0xed, 0xa4, #                   2007|       STD ,Y
            0x86, 0x55, #                   2009|       LDA $55
            0xA7, 0xb4, #                   200B|       STA ,[Y]
        end
        ])
        assertEqualHex(@cpu.cc.get(), 0x00)
        assertMemory(
            start=0x1000,
            mem=[0x55]
        end
        )
    end
    
    def test_code_LEAU_01
        @cpu.user_stack_pointer.set(0xff)
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0x33, 0x41, #                  0000|            LEAU   1,U
        end
        ])
        assertEqualHex(@cpu.user_stack_pointer.get(), 0x100)
    end
    
    def test_code_LEAU_02
        @cpu.user_stack_pointer.set(0xff)
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0xCE, 0x00, 0x00, #                       LDU   #$0000
            0x33, 0xC9, 0x1A, 0xBC, #                 LEAU  $1abc,U
        end
        ])
        assertEqualHex(@cpu.user_stack_pointer.get(), 0x1abc)
    end
    
    def test_code_LDU_01
        @cpu.user_stack_pointer.set(0xff)
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0xCE, 0x12, 0x34, #                       LDU   #$0000
        end
        ])
        assertEqualHex(@cpu.user_stack_pointer.get(), 0x1234)
    end
    
    def test_code_ORA_01
        @cpu.cc.set(0xff)
        @cpu.accu_a.set(0x12)
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0x8A, 0x21, #                             ORA   $21
        end
        ])
        assertEqualHex(@cpu.accu_a.get(), 0x33)
        assertEqual(@cpu.cc.N, 0)
        assertEqual(@cpu.cc.Z, 0)
        assertEqual(@cpu.cc.V, 0)
    end
    
    def test_code_ORCC_01
        @cpu.cc.set(0x12)
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0x1A, 0x21, #                             ORCC   $21
        end
        ])
        assertEqualHex(@cpu.cc.get(), 0x33)
    end
end



class TestSimple6809ROM < BaseCPUTestCase
    """
    use routines from Simple 6809 ROM code
    """
    def _is_carriage_return (a, pc)
        @cpu.accu_a.set(a)
        cpu_test_run2(start=0x4000, count=3, mem=[
            # origin start address in ROM: $db16
            0x34, 0x02, # PSHS A
            0x81, 0x0d, # CMPA #000d(CR)       ; IS IT CARRIAGE RETURN?
            0x27, 0x0b, # BEQ  NEWLINE         ; YES
        end
        ])
        assertEqualHex(@cpu.program_counter.get(), pc)
    end
    
    def test_is_not_carriage_return
        _is_carriage_return(a=0x00, pc=0x4006)
    end
    
    def test_is_carriage_return
        _is_carriage_return(a=0x0d, pc=0x4011)
    end
end



