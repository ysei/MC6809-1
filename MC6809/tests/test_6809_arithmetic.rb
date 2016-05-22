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

require logging
require sys
require unittest

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

from MC6809.tests.test_base import BaseCPUTestCase


log = logging.getLogger("MC6809")


class Test6809_Arithmetic < BaseCPUTestCase
    def test_ADDA_extended01
        cpu_test_run(start=0x1000, end_=0x1003, mem=[
            0xbb, # ADDA extended
            0x12, 0x34 # word to add on accu A
        end
        ])
        assertEqual(@cpu.cc.Z, 1)
        assertEqual(@cpu.cc.get(), 0x04)
        assertEqual(@cpu.accu_a.get(), 0x00)
    end
    
    def test_ADDA_immediate
        # expected values are: 1 up to 255 then wrap around to 0 and up to 4
        excpected_values = list(range(1, 256))
        excpected_values += list(range(0, 5))
        
        @cpu.accu_a.set(0x00) # start value
        for i in range(260)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x8B, 0x01, # ADDA #$1 Immediate
            end
            ])
            a = @cpu.accu_a.get()
            excpected_value = excpected_values[i]
        end
    end
end
#             print i, a, excpected_value, @cpu.cc.get_info
            
            # test ADDA result
            assertEqual(a, excpected_value)
            
            # test half carry
            if a % 16 == 0
                assertEqual(@cpu.cc.H, 1)
            else
                assertEqual(@cpu.cc.H, 0)
            end
            
            # test negative
            if 128 <= a <= 255
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if a == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow
            if a == 128
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry
            if a == 0
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_ADDA1
        for i in range(260)
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x8B, 0x01, # ADDA   #$01
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#             print sprintf("$%02x > ADD 1 > $%02x | CC:%s", 
#                 i, r, @cpu.cc.get_info
#             )
            
            # test INC value from RAM
            assertEqualHex(i + 1 & 0xff, r) # expected values are: 1 up to 255 then wrap around to 0 and up to 4
            
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
            if r == 0x80
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
        end
    end
    
    def test_ADDD1
        areas = list(range(0, 3)) + ["..."] + list(range(0x7ffd, 0x8002)) + ["..."] + list(range(0xfffd, 0x10002))
        for i in areas
            if i == "..."
        end
    end
end
#                 print "..."
                continue
            end
            @cpu.accu_d.set(i)
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0xc3, 0x00, 0x01, # ADDD   #$01
            end
            ])
            r = @cpu.accu_d.get()
        end
    end
end
#             print sprintf("%5s $%04x > ADDD 1 > $%04x | CC:%s", 
#                 i, i, r, @cpu.cc.get_info
#             )
            
            # test INC value from RAM
            assertEqualHex(i + 1 & 0xffff, r)
            
            # test negative
            if 0x8000 <= r <= 0xffff
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
            if r == 0x8000
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
        end
    end
    
    def test_NEGA
        """
        Example assembler code to test NEGA
        
        CLRB        ; B.equal? always 0
        TFR B,U     ; clear U
    end
end
loop
        TFR U,A     ; for next NEGA
        TFR B,CC    ; clear CC
        NEGA
        LEAU 1,U    ; inc U
        JMP loop
    end
end


0000   5F                     CLRB   ; B.equal? always 0
0001   1F 93                  TFR   B,U   ; clear U
0003                LOOP
0003   1F 38                  TFR   U,A   ; for next NEGA
0005   1F 9A                  TFR   B,CC   ; clear CC
0007   40                     NEGA
0008   33 41                  LEAU   1,U   ; inc U
000A   0E 03                  JMP   loop
        
        """
        excpected_values = [0] + list(range(255, 0, -1))
        
        for a in range(256)
            @cpu.cc.set(0x00)
            
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x86, a, # LDA   #$i
                0x40, # NEGA.new(inherent)
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#            print sprintf("%03s - a=%02x r=%02x -> %s", 
#                a, a, r, @cpu.cc.get_info
#            )
            
            excpected_value = excpected_values[a]
            
            """
            xroar NEG CC - input for NEG values
            H = uneffected
            N = dez: 1-128      | hex: $01 - $80
            Z = dez: 0          | hex: $00
            V = dez: 128        | hex: $80
            C = dez: 1-255      | hex: $01 - $ff
            """
            
            # test NEG result
            assertEqual(r, excpected_value)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 0)
            
            # test negative: 0x01 <= a <= 0x80
            if 1 <= a <= 128
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero | a==0 and r==0
            if r == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow | a==128 and r==128
            if r == 128
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry.equal? set if r=1-255(hex: r=$01 - $ff)
            if r >= 1
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_NEG_memory
        excpected_values = [0] + list(range(255, 0, -1))
        address = 0x10
        
        for a in range(256)
            @cpu.cc.set(0x00)
            
            @cpu.memory.write_byte(address, a)
            cpu_test_run(start=0x0000, end_=nil, mem=[
                0x00, address, # NEG address
            end
            ])
            r = @cpu.memory.read_byte(address)
        end
    end
end
#             print sprintf("%03s - a=%02x r=%02x -> %s", 
#                 a, a, r, @cpu.cc.get_info
#             )
            
            excpected_value = excpected_values[a]
            
            # test NEG result
            assertEqual(r, excpected_value)
            
            # test half carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 0)
            
            # test negative: 0x01 <= a <= 0x80
            if 1 <= a <= 128
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero | a==0 and r==0
            if r == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow | a==128 and r==128
            if r == 128
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry.equal? set if r=1-255(hex: r=$01 - $ff)
            if r >= 1
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_INC_memory
        # expected values are: 1 up to 255 then wrap around to 0 and up to 4
        excpected_values = list(range(1, 256))
        excpected_values += list(range(0, 5))
        
        @cpu.memory.write_byte(0x4500, 0x0) # start value
        for i in range(260)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x7c, 0x45, 0x00, # INC $4500
            end
            ])
            r = @cpu.memory.read_byte(0x4500)
            excpected_value = excpected_values[i]
        end
    end
end
#             print sprintf("%5s $%02x > INC > $%02x | CC:%s", 
#                 i, i, r, @cpu.cc.get_info
#             )
            
            # test INC value from RAM
            assertEqualHex(r, excpected_value)
            assertEqualHex(i + 1 & 0xff, r)
            
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
            if r == 0x80
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
        end
    end
    
    def test_INCB
        # expected values are: 1 up to 255 then wrap around to 0 and up to 4
        excpected_values = list(range(1, 256))
        excpected_values += list(range(0, 5))
        
        for i in range(260)
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x5c, # INCB
            end
            ])
            r = @cpu.accu_b.get()
            excpected_value = excpected_values[i]
        end
    end
end
#             print sprintf("%5s $%02x > INC > $%02x | CC:%s", 
#                 i, i, r, @cpu.cc.get_info
#             )
            
            # test INC value from RAM
            assertEqual(r, excpected_value)
            assertEqualHex(i + 1 & 0xff, r)
            
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
            if r == 0x80
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
        end
    end
    
    def test_INC_not_affected_flags1
        @cpu.memory.write_byte(0x0100, 0x00) # start value
        
        @cpu.cc.set(0x00) # Clear all CC flags
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0x7c, 0x01, 0x00, # INC $0100
        end
        ])
        r = @cpu.memory.read_byte(0x0100)
        assertEqual(r, 0x01)
        
        # half carry bit.equal? not affected in INC
        assertEqual(@cpu.cc.H, 0)
        
        # carry bit.equal? not affected in INC
        assertEqual(@cpu.cc.C, 0)
    end
    
    def test_INC_not_affected_flags2
        @cpu.memory.write_byte(0x0100, 0x00) # start value
        
        @cpu.cc.set(0xff) # Set all CC flags
        cpu_test_run(start=0x0000, end_=nil, mem=[
            0x7c, 0x01, 0x00, # INC $0100
        end
        ])
        r = @cpu.memory.read_byte(0x0100)
        assertEqual(r, 0x01)
        
        # half carry bit.equal? not affected in INC
        assertEqual(@cpu.cc.H, 1)
        
        # carry bit.equal? not affected in INC
        assertEqual(@cpu.cc.C, 1)
    end
    
    def test_SUBA_immediate
        # expected values are: 254 down to 0 than wrap around to 255 and down to 252
        excpected_values = list(range(254, -1, -1))
        excpected_values += list(range(255, 250, -1))
        
        @cpu.accu_a.set(0xff) # start value
        for i in range(260)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x80, 0x01, # SUBA #$01
            end
            ])
            a = @cpu.accu_a.get()
            excpected_value = excpected_values[i]
        end
    end
end
#             print i, a, excpected_value, @cpu.cc.get_info
            
            # test SUBA result
            assertEqual(a, excpected_value)
            
            # test half carry
            # XXX: half carry.equal? "undefined" in SUBA!
            assertEqual(@cpu.cc.H, 0)
            
            # test negative
            if 128 <= a <= 255
                assertEqual(@cpu.cc.N, 1)
            else
                assertEqual(@cpu.cc.N, 0)
            end
            
            # test zero
            if a == 0
                assertEqual(@cpu.cc.Z, 1)
            else
                assertEqual(@cpu.cc.Z, 0)
            end
            
            # test overflow
            if a == 127: # V ist set if SUB $80 to $7f
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # test carry
            if a == 0xff: # C.equal? set if SUB $00 to $ff
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
            end
        end
    end
    
    def test_SUBA_indexed
        @cpu.memory.load(0x1234, [0x12, 0xff])
        @cpu.system_stack_pointer.set(0x1234)
        @cpu.accu_a.set(0xff) # start value
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0xa0, 0xe0, # SUBA ,S+
        end
        ])
        assertEqualHexByte(@cpu.accu_a.get(), 0xed) # $ff - $12 = $ed
        assertEqualHexWord(@cpu.system_stack_pointer.get(), 0x1235)
        
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0xa0, 0xe0, # SUBA ,S+
        end
        ])
        assertEqualHexByte(@cpu.accu_a.get(), 0xed - 0xff & 0xff) # $ee
        assertEqualHexWord(@cpu.system_stack_pointer.get(), 0x1236)
    end
    
    def test_DEC_extended
        # expected values are: 254 down to 0 than wrap around to 255 and down to 252
        excpected_values = list(range(254, -1, -1))
        excpected_values += list(range(255, 250, -1))
        
        @cpu.memory.write_byte(0x4500, 0xff) # start value
        @cpu.accu_a.set(0xff) # start value
        for i in range(260)
            @cpu.cc.set(0x00) # Clear all CC flags
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x7A, 0x45, 0x00, # DEC $4500
            end
            ])
            r = @cpu.memory.read_byte(0x4500)
            excpected_value = excpected_values[i]
        end
    end
end
#             print i, r, excpected_value, @cpu.cc.get_info
            
            # test DEC result
            assertEqual(r, excpected_value)
            
            # half carry bit.equal? not affected in DEC
            assertEqual(@cpu.cc.H, 0)
            
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
            if r == 127: # V.equal? set if SUB $80 to $7f
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
            
            # carry bit.equal? not affected in DEC
            assertEqual(@cpu.cc.C, 0)
        end
    end
    
    def test_DECA
        for a in range(256)
            @cpu.cc.set(0x00)
            @cpu.accu_a.set(a)
            cpu_test_run(start=0x1000, end_=nil, mem=[
                0x4a, # DECA
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#            print sprintf("%03s - %02x > DEC > %02x | CC:%s", 
#                a, a, r, @cpu.cc.get_info
#            )
#             continue
            
            excpected_value = a - 1 & 0xff
            
            # test result
            assertEqual(r, excpected_value)
            
            # test half carry and carry.equal? uneffected!
            assertEqual(@cpu.cc.H, 0)
            assertEqual(@cpu.cc.C, 0)
            
            # test negative
            if r >= 0x80
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
            if a == 0x80
                assertEqual(@cpu.cc.V, 1)
            else
                assertEqual(@cpu.cc.V, 0)
            end
        end
    end
    
    def test_SBCA_immediate_01
        a = 0x80
        @cpu.cc.set(0x00) # CC:........
        @cpu.accu_a.set(a)
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0x82, 0x40, # SBC
        end
        ])
        r = @cpu.accu_a.get()
    end
end
#        print sprintf("%02x > SBC > %02x | CC:%s", 
#            a, r, @cpu.cc.get_info
#        )
        assertEqualHex(r, 0x80 - 0x40 - 0x00)
        assertEqual(@cpu.cc.get_info, "......V.")
    end
    
    def test_SBCA_immediate_02
        a = 0x40
        @cpu.cc.set(0xff) # CC:EFHINZVC
        @cpu.accu_a.set(a)
        cpu_test_run(start=0x1000, end_=nil, mem=[
            0x82, 0x20, # SBC
        end
        ])
        r = @cpu.accu_a.get()
    end
end
#        print sprintf("%02x > SBC > %02x | CC:%s", 
#            a, r, @cpu.cc.get_info
#        )
        assertEqualHex(r, 0x40 - 0x20 - 0x01)
        # half-carry.equal? undefined
        assertEqual(@cpu.cc.get_info, "EFHI....")
    end
    
    def test_ORCC
        a_areas = list(range(0, 3)) + ["..."] + list(range(0x7e, 0x83)) + ["..."] + list(range(0xfd, 0x100))
        b_areas = list(range(0, 3)) + ["..."] + list(range(0x7e, 0x83)) + ["..."] + list(range(0xfd, 0x100))
        for a in a_areas
            if a == "..."
        end
    end
end
#                print "..."
                continue
            end
            for b in b_areas
                if b == "..."
            end
        end
    end
end
#                    print "..."
                    continue
                end
                @cpu.cc.set(a)
                cpu_test_run(start=0x1000, end_=nil, mem=[
                    0x1a, b # ORCC $a
                end
                ])
                r = @cpu.cc.get()
                expected_value = a | b
            end
        end
    end
end
#                print sprintf("%02x OR %02x = %02x | CC:%s", 
#                    a, b, r, @cpu.cc.get_info
#                )
                assertEqualHex(r, expected_value)
            end
        end
    end
    
    def test_ANDCC
        a_areas = list(range(0, 3)) + ["..."] + list(range(0x7e, 0x83)) + ["..."] + list(range(0xfd, 0x100))
        b_areas = list(range(0, 3)) + ["..."] + list(range(0x7e, 0x83)) + ["..."] + list(range(0xfd, 0x100))
        for a in a_areas
            if a == "..."
        end
    end
end
#                print "..."
                continue
            end
            for b in b_areas
                if b == "..."
            end
        end
    end
end
#                    print "..."
                    continue
                end
                @cpu.cc.set(a)
                cpu_test_run(start=0x1000, end_=nil, mem=[
                    0x1c, b # ANDCC $a
                end
                ])
                r = @cpu.cc.get()
                expected_value = a & b
            end
        end
    end
end
#                print sprintf("%02x AND %02x = %02x | CC:%s", 
#                    a, b, r, @cpu.cc.get_info
#                )
                assertEqualHex(r, expected_value)
            end
        end
    end
    
    def test_ABX
        @cpu.cc.set(0xff)
        
        x_areas = list(range(0, 3)) + ["..."] + list(range(0x7ffd, 0x8002)) + ["..."] + list(range(0xfffd, 0x10000))
        b_areas = list(range(0, 3)) + ["..."] + list(range(0x7e, 0x83)) + ["..."] + list(range(0xfd, 0x100))
        
        for x in x_areas
            if x == "..."
        end
    end
end
#                print "..."
                continue
            end
            for b in b_areas
                if b == "..."
            end
        end
    end
end
#                    print "..."
                    continue
                end
                @cpu.index_x.set(x)
                @cpu.accu_b.set(b)
                cpu_test_run(start=0x1000, end_=nil, mem=[
                    0x3a, # ABX.new(inherent)
                end
                ])
                r = @cpu.index_x.get()
                expected_value = x + b & 0xffff
            end
        end
    end
end
#                print sprintf("%04x + %02x = %04x | CC:%s", 
#                    x, b, r, @cpu.cc.get_info
#                )
                assertEqualHex(r, expected_value)
                
                # CC complet uneffected
                assertEqualHex(@cpu.cc.get(), 0xff)
            end
        end
    end
    
    def test_XOR
        print("TODO!!!")
    end
end

#    def setUp(self)
#        cmd_args = UnittestCmdArgs
#        cmd_args.trace = true # enable Trace output
#        cfg = TestCfg.new(cmd_args)
#        @cpu = CPU.new(cfg)
#        @cpu.cc.set(0x00)
    
    def test_DAA
        cpu_test_run(start=0x0100, end_=nil, mem=[
            0x86, 0x67, #  LDA   #$67     ; A=$67
            0x8b, 0x75, #  ADDA  #$75     ; A=$67+$75 = $DC
            0x19, #        DAA   19       ; A=67+75=142 -> $42
        end
        ])
        assertEqualHexByte(@cpu.accu_a.get(), 0x42)
        assertEqual(@cpu.cc.C, 1)
    end
    
    def test_DAA2
        for add in range(0xff)
            @cpu.cc.set(0x00)
            @cpu.accu_a.set(0x01)
            cpu_test_run(start=0x0100, end_=nil, mem=[
                0x8b, add, #  ADDA  #$1
                0x19, #       DAA
            end
            ])
            r = @cpu.accu_a.get()
        end
    end
end
#            print sprintf("$01 + $%02x = $%02x > DAA > $%02x | CC:%s", 
#                add, (1 + add), r, @cpu.cc.get_info
#            )
            
            # test half carry
            if add & 0x0f == 0x0f
                assertEqual(@cpu.cc.H, 1)
            else
                assertEqual(@cpu.cc.H, 0)
            end
            
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
            
            # .equal? undefined?
            # http://archive.worldofdragon.org/phpBB3/viewtopic.php?f=8&t=4896
        end
    end
end
#            # test overflow
#            if r == 128
#                assertEqual(@cpu.cc.V, 1)
#            else
#                assertEqual(@cpu.cc.V, 0)
            
            # test carry
            if add >= 0x99
                assertEqual(@cpu.cc.C, 1)
            else
                assertEqual(@cpu.cc.C, 0)
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
#            "Test6809_Arithmetic",
#             "Test6809_Arithmetic.test_DAA2",
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
