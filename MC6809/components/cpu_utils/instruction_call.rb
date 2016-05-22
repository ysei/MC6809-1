
"""
    This file was generated with: "Instruction_generator.py"
    Please doen't change it directly ;)
    
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end

"""


from MC6809.components.cpu_utils.instruction_base import InstructionBase

class PrepagedInstructions < InstructionBase
    
    def direct_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct(),
        end
        )
    end
    
    def direct_A_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct(),
            register = @cpu.accu_a,
        end
        )
    end
    
    def direct_B_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct(),
            register = @cpu.accu_b,
        end
        )
    end
    
    def direct_ea (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
        end
        )
    end
    
    def direct_ea_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def direct_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_direct()
        ea, value = instr_func(
            opcode = opcode,
            ea = ea,
            m = m,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def direct_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.accu_a,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def direct_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.accu_b,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def direct_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.accu_d,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def direct_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.system_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def direct_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.user_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def direct_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.index_x,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def direct_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_direct(),
            register = @cpu.index_y,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def direct_word_D_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct_word(),
            register = @cpu.accu_d,
        end
        )
    end
    
    def direct_word_S_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct_word(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def direct_word_U_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct_word(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def direct_word_X_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct_word(),
            register = @cpu.index_x,
        end
        )
    end
    
    def direct_word_Y_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_direct_word(),
            register = @cpu.index_y,
        end
        )
    end
    
    def extended_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended(),
        end
        )
    end
    
    def extended_A_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended(),
            register = @cpu.accu_a,
        end
        )
    end
    
    def extended_B_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended(),
            register = @cpu.accu_b,
        end
        )
    end
    
    def extended_ea (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
        end
        )
    end
    
    def extended_ea_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def extended_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_extended()
        ea, value = instr_func(
            opcode = opcode,
            ea = ea,
            m = m,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def extended_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.accu_a,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def extended_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.accu_b,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def extended_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.accu_d,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def extended_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.system_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def extended_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.user_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def extended_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.index_x,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def extended_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_extended(),
            register = @cpu.index_y,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def extended_word_D_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended_word(),
            register = @cpu.accu_d,
        end
        )
    end
    
    def extended_word_S_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended_word(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def extended_word_U_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended_word(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def extended_word_X_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended_word(),
            register = @cpu.index_x,
        end
        )
    end
    
    def extended_word_Y_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_extended_word(),
            register = @cpu.index_y,
        end
        )
    end
    
    def immediate_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
        end
        )
    end
    
    def immediate_A_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
            register = @cpu.accu_a,
        end
        )
    end
    
    def immediate_B_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
            register = @cpu.accu_b,
        end
        )
    end
    
    def immediate_CC_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
            register = @cpu.cc,
        end
        )
    end
    
    def immediate_S_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def immediate_U_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def immediate_word_D_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate_word(),
            register = @cpu.accu_d,
        end
        )
    end
    
    def immediate_word_S_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate_word(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def immediate_word_U_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate_word(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def immediate_word_X_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate_word(),
            register = @cpu.index_x,
        end
        )
    end
    
    def immediate_word_Y_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_immediate_word(),
            register = @cpu.index_y,
        end
        )
    end
    
    def indexed_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed(),
        end
        )
    end
    
    def indexed_A_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed(),
            register = @cpu.accu_a,
        end
        )
    end
    
    def indexed_B_read8 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed(),
            register = @cpu.accu_b,
        end
        )
    end
    
    def indexed_ea (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
        end
        )
    end
    
    def indexed_ea_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def indexed_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_indexed()
        ea, value = instr_func(
            opcode = opcode,
            ea = ea,
            m = m,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def indexed_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.accu_a,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def indexed_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.accu_b,
        end
        )
        @memory.write_byte(ea, value)
    end
    
    def indexed_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.accu_d,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def indexed_ea_S (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def indexed_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.system_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def indexed_ea_U (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def indexed_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.user_stack_pointer,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def indexed_ea_X (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.index_x,
        end
        )
    end
    
    def indexed_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.index_x,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def indexed_ea_Y (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.index_y,
        end
        )
    end
    
    def indexed_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_indexed(),
            register = @cpu.index_y,
        end
        )
        @memory.write_word(ea, value)
    end
    
    def indexed_word_D_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed_word(),
            register = @cpu.accu_d,
        end
        )
    end
    
    def indexed_word_S_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed_word(),
            register = @cpu.system_stack_pointer,
        end
        )
    end
    
    def indexed_word_U_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed_word(),
            register = @cpu.user_stack_pointer,
        end
        )
    end
    
    def indexed_word_X_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed_word(),
            register = @cpu.index_x,
        end
        )
    end
    
    def indexed_word_Y_read16 (opcode)
        instr_func(
            opcode = opcode,
            m = @cpu.get_m_indexed_word(),
            register = @cpu.index_y,
        end
        )
    end
    
    def inherent (opcode)
        instr_func(
            opcode = opcode,
        end
        )
    end
    
    def inherent_A (opcode)
        instr_func(
            opcode = opcode,
            register = @cpu.accu_a,
        end
        )
    end
    
    def inherent_B (opcode)
        instr_func(
            opcode = opcode,
            register = @cpu.accu_b,
        end
        )
    end
    
    def relative_ea (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_relative(),
        end
        )
    end
    
    def relative_word_ea (opcode)
        instr_func(
            opcode = opcode,
            ea = @cpu.get_ea_relative_word(),
        end
        )
    end
end

