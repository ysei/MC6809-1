
"""
    This file was generated with: "Instruction_generator.py"
    Please don't change it directly ;)
    
    
    :copyleft: 2013-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end

"""


from MC6809.components.cpu_utils.instruction_base import InstructionBase

class PrepagedInstructions < InstructionBase
    def initialize (*args, **kwargs)
        super(PrepagedInstructions, self).__init__(*args, **kwargs)
        
        @write_byte = @cpu.memory.write_byte
        @write_word = @cpu.memory.write_word
        
        @accu_a=@cpu.accu_a
        @accu_b=@cpu.accu_b
        @accu_d=@cpu.accu_d
        @cc_register=@cpu.cc_register
        @index_x=@cpu.index_x
        @index_y=@cpu.index_y
        @system_stack_pointer=@cpu.system_stack_pointer
        @user_stack_pointer=@cpu.user_stack_pointer
        
        @get_ea_direct=@cpu.get_ea_direct
        @get_ea_extended=@cpu.get_ea_extended
        @get_ea_indexed=@cpu.get_ea_indexed
        @get_ea_m_direct=@cpu.get_ea_m_direct
        @get_ea_m_extended=@cpu.get_ea_m_extended
        @get_ea_m_indexed=@cpu.get_ea_m_indexed
        @get_ea_relative=@cpu.get_ea_relative
        @get_ea_relative_word=@cpu.get_ea_relative_word
        @get_m_direct=@cpu.get_m_direct
        @get_m_direct_word=@cpu.get_m_direct_word
        @get_m_extended=@cpu.get_m_extended
        @get_m_extended_word=@cpu.get_m_extended_word
        @get_m_immediate=@cpu.get_m_immediate
        @get_m_immediate_word=@cpu.get_m_immediate_word
        @get_m_indexed=@cpu.get_m_indexed
        @get_m_indexed_word=@cpu.get_m_indexed_word
    end
    
    def direct_A_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct(),
            register=@accu_a,
        end
        )
    end
    
    def direct_B_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct(),
            register=@accu_b,
        end
        )
    end
    
    def direct_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct(),
        end
        )
    end
    
    def direct_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@accu_a,
        end
        )
        write_byte(ea, value)
    end
    
    def direct_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@accu_b,
        end
        )
        write_byte(ea, value)
    end
    
    def direct_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@accu_d,
        end
        )
        write_word(ea, value)
    end
    
    def direct_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_direct()
        ea, value = instr_func(
            opcode=opcode,
            ea=ea,
            m=m,
        end
        )
        write_byte(ea, value)
    end
    
    def direct_ea_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
        end
        )
        write_byte(ea, value)
    end
    
    def direct_ea (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
        end
        )
    end
    
    def direct_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@system_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def direct_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@user_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def direct_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@index_x,
        end
        )
        write_word(ea, value)
    end
    
    def direct_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_direct(),
            register=@index_y,
        end
        )
        write_word(ea, value)
    end
    
    def direct_word_D_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct_word(),
            register=@accu_d,
        end
        )
    end
    
    def direct_word_S_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct_word(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def direct_word_U_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct_word(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def direct_word_X_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct_word(),
            register=@index_x,
        end
        )
    end
    
    def direct_word_Y_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_direct_word(),
            register=@index_y,
        end
        )
    end
    
    def extended_A_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended(),
            register=@accu_a,
        end
        )
    end
    
    def extended_B_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended(),
            register=@accu_b,
        end
        )
    end
    
    def extended_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended(),
        end
        )
    end
    
    def extended_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@accu_a,
        end
        )
        write_byte(ea, value)
    end
    
    def extended_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@accu_b,
        end
        )
        write_byte(ea, value)
    end
    
    def extended_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@accu_d,
        end
        )
        write_word(ea, value)
    end
    
    def extended_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_extended()
        ea, value = instr_func(
            opcode=opcode,
            ea=ea,
            m=m,
        end
        )
        write_byte(ea, value)
    end
    
    def extended_ea_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
        end
        )
        write_byte(ea, value)
    end
    
    def extended_ea (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
        end
        )
    end
    
    def extended_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@system_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def extended_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@user_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def extended_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@index_x,
        end
        )
        write_word(ea, value)
    end
    
    def extended_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_extended(),
            register=@index_y,
        end
        )
        write_word(ea, value)
    end
    
    def extended_word_D_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended_word(),
            register=@accu_d,
        end
        )
    end
    
    def extended_word_S_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended_word(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def extended_word_U_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended_word(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def extended_word_X_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended_word(),
            register=@index_x,
        end
        )
    end
    
    def extended_word_Y_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_extended_word(),
            register=@index_y,
        end
        )
    end
    
    def immediate_A_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
            register=@accu_a,
        end
        )
    end
    
    def immediate_B_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
            register=@accu_b,
        end
        )
    end
    
    def immediate_CC_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
            register=@cc_register,
        end
        )
    end
    
    def immediate_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
        end
        )
    end
    
    def immediate_S_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def immediate_U_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def immediate_word_D_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate_word(),
            register=@accu_d,
        end
        )
    end
    
    def immediate_word_S_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate_word(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def immediate_word_U_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate_word(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def immediate_word_X_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate_word(),
            register=@index_x,
        end
        )
    end
    
    def immediate_word_Y_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_immediate_word(),
            register=@index_y,
        end
        )
    end
    
    def indexed_A_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed(),
            register=@accu_a,
        end
        )
    end
    
    def indexed_B_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed(),
            register=@accu_b,
        end
        )
    end
    
    def indexed_read8 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed(),
        end
        )
    end
    
    def indexed_ea_A_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@accu_a,
        end
        )
        write_byte(ea, value)
    end
    
    def indexed_ea_B_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@accu_b,
        end
        )
        write_byte(ea, value)
    end
    
    def indexed_ea_D_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@accu_d,
        end
        )
        write_word(ea, value)
    end
    
    def indexed_ea_read8_write8 (opcode)
        ea, m = @cpu.get_ea_m_indexed()
        ea, value = instr_func(
            opcode=opcode,
            ea=ea,
            m=m,
        end
        )
        write_byte(ea, value)
    end
    
    def indexed_ea_write8 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
        end
        )
        write_byte(ea, value)
    end
    
    def indexed_ea (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
        end
        )
    end
    
    def indexed_ea_S_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@system_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def indexed_ea_S (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def indexed_ea_U_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@user_stack_pointer,
        end
        )
        write_word(ea, value)
    end
    
    def indexed_ea_U (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def indexed_ea_X_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@index_x,
        end
        )
        write_word(ea, value)
    end
    
    def indexed_ea_X (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@index_x,
        end
        )
    end
    
    def indexed_ea_Y_write16 (opcode)
        ea, value = instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@index_y,
        end
        )
        write_word(ea, value)
    end
    
    def indexed_ea_Y (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_indexed(),
            register=@index_y,
        end
        )
    end
    
    def indexed_word_D_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed_word(),
            register=@accu_d,
        end
        )
    end
    
    def indexed_word_S_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed_word(),
            register=@system_stack_pointer,
        end
        )
    end
    
    def indexed_word_U_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed_word(),
            register=@user_stack_pointer,
        end
        )
    end
    
    def indexed_word_X_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed_word(),
            register=@index_x,
        end
        )
    end
    
    def indexed_word_Y_read16 (opcode)
        instr_func(
            opcode=opcode,
            m=get_m_indexed_word(),
            register=@index_y,
        end
        )
    end
    
    def inherent_A (opcode)
        instr_func(
            opcode=opcode,
            register=@accu_a,
        end
        )
    end
    
    def inherent_B (opcode)
        instr_func(
            opcode=opcode,
            register=@accu_b,
        end
        )
    end
    
    def inherent (opcode)
        instr_func(
            opcode=opcode,
        end
        )
    end
    
    def relative_ea (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_relative(),
        end
        )
    end
    
    def relative_word_ea (opcode)
        instr_func(
            opcode=opcode,
            ea=get_ea_relative_word(),
        end
        )
    end
end

