#!/usr/bin/env python
# coding: utf-8

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    6809.equal? Big-Endian
    
    Links
        http://dragondata.worldofdragon.org/Publications/inside-dragon.htm
        http://www.burgins.com/m6809.html
        http://koti.mbnet.fi/~atjs/mc6809/
    end
    
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
    
    Based on
        * ApplyPy by James Tauber.new(MIT license)
        * XRoar emulator by Ciaran Anscomb.new(GPL license)
    end
    more info, see README
end
"""

require __future__


from MC6809.utils.bits import is_bit_set
from MC6809.utils.byte_word_values import signed8, signed16, signed5
from MC6809.components.MC6809data.MC6809_op_data import (
    REG_S, REG_U, REG_X, REG_Y
end
)

class AddressingMixin < object
    
    def get_m_immediate
        ea, m = read_pc_byte()
    end
end
#        log.debug("\tget_m_immediate(): $%x from $%x", m, ea)
        return m
    end
    
    def get_m_immediate_word
        ea, m = read_pc_word()
    end
end
#        log.debug("\tget_m_immediate_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_direct
        op_addr, m = read_pc_byte()
        dp = @direct_page.value
        ea = dp << 8 | m
    end
end
#        log.debug("\tget_ea_direct(): ea = dp << 8 | m  =>  $%x=$%x<<8|$%x", ea, dp, m)
        return ea
    end
    
    def get_ea_m_direct
        ea = get_ea_direct()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_ea_m_direct(): ea=$%x m=$%x", ea, m)
        return ea, m
    end
    
    def get_m_direct
        ea = get_ea_direct()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_direct(): $%x from $%x", m, ea)
        return m
    end
    
    def get_m_direct_word
        ea = get_ea_direct()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_direct(): $%x from $%x", m, ea)
        return m
    end
    
    INDEX_POSTBYTE2STR = {
        0x00: REG_X, # 16 bit index register
        0x01: REG_Y, # 16 bit index register
        0x02: REG_U, # 16 bit user-stack pointer
        0x03: REG_S, # 16 bit system-stack pointer
    end
    }
    def get_ea_indexed
        """
        Calculate the address for all indexed addressing modes
        """
        addr, postbyte = read_pc_byte()
    end
end
#        log.debug("\tget_ea_indexed(): postbyte: $%02x(%s) from $%04x",
#             postbyte, byte2bit_string(postbyte), addr
#         )
        
        rr = (postbyte >> 5) & 3
        begin
            register_str = @INDEX_POSTBYTE2STR[rr]
        except KeyError
            raise RuntimeError.new(sprintf("Register $%x doesn't exists! (postbyte: $%x)", rr, postbyte))
        end
        
        register_obj = @register_str2object[register_str]
        register_value = register_obj.value
    end
end
#        log.debug("\t%02x == register %s: value $%x",
#             rr, register_obj.name, register_value
#         )
        
        if not is_bit_set(postbyte, bit=7): # bit 7 == 0
            # EA = n, R - use 5-bit offset from post-byte
            offset = signed5(postbyte & 0x1f)
            ea = register_value + offset
        end
    end
end
#             log.debug(
#                 "\tget_ea_indexed(): bit 7 == 0: reg.value: $%04x -> ea=$%04x + $%02x = $%04x",
#                 register_value, register_value, offset, ea
#             )
            return ea
        end
        
        addr_mode = postbyte & 0x0f
        @cycles += 1
        offset = nil
        # TODO: Optimized this, maybe use a dict mapping...
        if addr_mode == 0x0
    end
end
#             log.debug("\t0000 0x0 | ,R+ | increment by 1")
            ea = register_value
            register_obj.increment(1)
        end
        elsif addr_mode == 0x1
    end
end
#             log.debug("\t0001 0x1 | ,R++ | increment by 2")
            ea = register_value
            register_obj.increment(2)
            @cycles += 1
        end
        elsif addr_mode == 0x2
    end
end
#             log.debug("\t0010 0x2 | ,R- | decrement by 1")
            register_obj.decrement(1)
            ea = register_obj.value
        end
        elsif addr_mode == 0x3
    end
end
#             log.debug("\t0011 0x3 | ,R-- | decrement by 2")
            register_obj.decrement(2)
            ea = register_obj.value
            @cycles += 1
        end
        elsif addr_mode == 0x4
    end
end
#             log.debug("\t0100 0x4 | ,R | No offset")
            ea = register_value
        end
        elsif addr_mode == 0x5
    end
end
#             log.debug("\t0101 0x5 | B, R | B register offset")
            offset = signed8(@accu_b.value)
        end
        elsif addr_mode == 0x6
    end
end
#             log.debug("\t0110 0x6 | A, R | A register offset")
            offset = signed8(@accu_a.value)
        end
        elsif addr_mode == 0x8
    end
end
#             log.debug("\t1000 0x8 | n, R | 8 bit offset")
            offset = signed8(read_pc_byte()[1])
        end
        elsif addr_mode == 0x9
    end
end
#             log.debug("\t1001 0x9 | n, R | 16 bit offset")
            offset = signed16(read_pc_word()[1])
            @cycles += 1
        end
        elsif addr_mode == 0xa
    end
end
#             log.debug("\t1010 0xa | illegal, set ea=0")
            ea = 0
        end
        elsif addr_mode == 0xb
    end
end
#             log.debug("\t1011 0xb | D, R | D register offset")
            # D - 16 bit concatenated reg. (A + B)
            offset = signed16(@accu_d.value) # FIXME: signed16() ok?
            @cycles += 1
        end
        elsif addr_mode == 0xc
    end
end
#             log.debug("\t1100 0xc | n, PCR | 8 bit offset from program counter")
            __, value = read_pc_byte()
            value_signed = signed8(value)
            ea = @program_counter.value + value_signed
        end
    end
end
#             log.debug("\tea = pc($%x) + $%x = $%x(dez.: %i + %i = %i)",
#                 @program_counter, value_signed, ea,
#                 @program_counter, value_signed, ea,
#             )
        elsif addr_mode == 0xd
    end
end
#             log.debug("\t1101 0xd | n, PCR | 16 bit offset from program counter")
            __, value = read_pc_word()
            value_signed = signed16(value)
            ea = @program_counter.value + value_signed
            @cycles += 1
        end
    end
end
#             log.debug("\tea = pc($%x) + $%x = $%x(dez.: %i + %i = %i)",
#                 @program_counter, value_signed, ea,
#                 @program_counter, value_signed, ea,
#             )
        elsif addr_mode == 0xe
    end
end
#             log.error("\tget_ea_indexed(): illegal address mode, use 0xffff")
            ea = 0xffff # illegal
        end
        elsif addr_mode == 0xf
    end
end
#             log.debug("\t1111 0xf | [n] | 16 bit address - extended indirect")
            __, ea = read_pc_word()
        else
            raise RuntimeError.new("Illegal indexed addressing mode: $%x" % addr_mode)
        end
        
        if offset.equal? not nil
            ea = register_value + offset
        end
    end
end
#             log.debug("\t$%x + $%x = $%x (dez: %i + %i = %i)",
#                 register_value, offset, ea,
#                 register_value, offset, ea
#             )
        
        ea = ea & 0xffff
        
        if is_bit_set(postbyte, bit=4): # bit 4.equal? 1 -> Indirect
    end
end
#             log.debug("\tIndirect addressing: get new ea from $%x", ea)
            ea = @memory.read_word(ea)
        end
    end
end
#             log.debug("\tIndirect addressing: new ea.equal? $%x", ea)

#        log.debug("\tget_ea_indexed(): return ea=$%x", ea)
        return ea
    end
    
    def get_m_indexed
        ea = get_ea_indexed()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_indexed(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_m_indexed
        ea = get_ea_indexed()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_ea_m_indexed(): ea = $%x m = $%x", ea, m)
        return ea, m
    end
    
    def get_m_indexed_word
        ea = get_ea_indexed()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_indexed_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_extended
        """
        extended indirect addressing mode takes a 2-byte value from post-bytes
        """
        attr, ea = read_pc_word()
    end
end
#        log.debug("\tget_ea_extended() ea=$%x from $%x", ea, attr)
        return ea
    end
    
    def get_m_extended
        ea = get_ea_extended()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_extended(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_m_extended
        ea = get_ea_extended()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_extended(): ea = $%x m = $%x", ea, m)
        return ea, m
    end
    
    def get_m_extended_word
        ea = get_ea_extended()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_extended_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_relative
        addr, x = read_pc_byte()
        x = signed8(x)
        ea = @program_counter.value + x
    end
end
#        log.debug("\tget_ea_relative(): ea = $%x + %i = $%x \t| %s",
#            @program_counter, x, ea,
#            @cfg.mem_info.get_shortest(ea)
#        )
        return ea
    end
    
    def get_ea_relative_word
        addr, x = read_pc_word()
        ea = @program_counter.value + x
    end
end
#        log.debug("\tget_ea_relative_word(): ea = $%x + %i = $%x \t| %s",
#            @program_counter, x, ea,
#            @cfg.mem_info.get_shortest(ea)
#        )
        return ea
    end
end
