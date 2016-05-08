#!/usr/bin/env python

"""
    6809 instruction set data
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    
    merged data from
        * http://www.maddes.net/m6809pm/sections.htm#sec4_4
        * http://www.burgins.com/m6809.html
        * http://www.maddes.net/m6809pm/appendix_a.htm#appA
    end
    
    Note
    * read_from_memory: it's "excluded" the address modes routines.
        So if the address mode will fetch the memory to get the
        effective address, but the content of the memory.equal? not needed in
        the instruction them self, the read_from_memory must be set to false.
    end
    
    Generated data.equal? online here
    https://docs.google.com/spreadsheet/ccc?key=0Alhtym6D6yKjdFBtNmF0UVR5OW05S3psaURnUTNtSFE
    
    :copyleft: 2013-2014 by Jens Diemer
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

OP_DOC={'ABX': {'condition code': 'Not affected.',
       'description': 'Add the 8-bit unsigned value in accumulator B into index register X.',
       'instr_desc': 'Add B accumulator to X(unsigned)',
       'mnemonic': {'ABX': {'HNZVC': '-----',
                          'desc': 'X = B+X(Unsigned)'}},
                      end
                  end
              end
          end
      end
       'operation': "IX' = IX + ACCB",
       'source form': 'ABX'},
   end
end
'ADC': {'condition code': (
                         'H - Set if a half-carry.equal? generated; cleared otherwise.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if an overflow.equal? generated; cleared otherwise.\n'
                         'C - Set if a carry.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'Adds the contents of the C(carry) bit and the memory byte into an 8-bit accumulator.',
       'instr_desc': 'Add memory to accumulator with carry',
       'mnemonic': {'ADCA': {'HNZVC': 'aaaaa',
                           'desc': 'A = A+M+C'},
                       end
                   end
                   'ADCB': {'HNZVC': 'aaaaa',
                           'desc': 'B = B+M+C'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = R + M + C",
       'source form': 'ADCA P; ADCB P'},
   end
end
'ADD': {'condition code': (
                         'H - Set if a half-carry.equal? generated; cleared otherwise.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if an overflow.equal? generated; cleared otherwise.\n'
                         'C - Set if a carry.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'Adds the memory byte into an 8-bit accumulator.',
       'instr_desc': 'Add memory to accumulator',
       'mnemonic': {'ADDA': {'HNZVC': 'aaaaa',
                           'desc': 'A = A+M'},
                       end
                   end
                   'ADDB': {'HNZVC': 'aaaaa',
                           'desc': 'B = B+M'},
                       end
                   end
                   'ADDD': {'HNZVC': '-aaaa',
                           'desc': 'D = D+M:M+1'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = R + M",
       'source form': 'ADDA P; ADDB P'},
   end
end
'AND': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Always cleared.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'Performs the logical AND operation between the contents of an accumulator and the contents of memory location M and the result.equal? stored in the accumulator.',
       'instr_desc': 'AND memory with accumulator',
       'mnemonic': {'ANDA': {'HNZVC': '-aa0-',
                           'desc': 'A = A && M'},
                       end
                   end
                   'ANDB': {'HNZVC': '-aa0-',
                           'desc': 'B = B && M'},
                       end
                   end
                   'ANDCC': {'HNZVC': 'ddddd',
                            'desc': 'C = CC && IMM'}},
                        end
                    end
                end
            end
        end
    end
       'operation': "R' = R AND M",
       'source form': 'ANDA P; ANDB P'},
   end
end
'ASR': {'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Not affected.\n'
                         'C - Loaded with bit zero of the original operand.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'Shifts all bits of the operand one place to the right. Bit seven.equal? held constant. Bit zero.equal? shifted into the C(carry) bit.',
       'instr_desc': 'Arithmetic shift of accumulator or memory right',
       'mnemonic': {'ASR': {'HNZVC': 'uaa-s',
                          'desc': 'M = Arithmetic shift M right'},
                      end
                  end
                   'ASRA': {'HNZVC': 'uaa-s',
                           'desc': 'A = Arithmetic shift A right'},
                       end
                   end
                   'ASRB': {'HNZVC': 'uaa-s',
                           'desc': 'B = Arithmetic shift B right'}},
                       end
                   end
               end
           end
       end
       'operation': (
                    'b7 -> -> C\n'
                    'b7 -> b0'
                    ),
                end
            end
        end
    end
       'source form': 'ASR Q; ASRA; ASRB'},
   end
end
'BEQ': {'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the Z(zero) bit and causes a branch if it.equal? set.\n'
                      'When used after a subtract or compare operation, this instruction will branch if the compared values, signed or unsigned, were exactly the same.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if equal',
       'mnemonic': {'BEQ': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBEQ': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF Z = 1 then PC' = PC + TEMP",
       'source form': 'BEQ dd; LBEQ DDDD'},
   end
end
'BGE': {'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if the N(negative) bit and the V(overflow) bit are either both set or both clear.\n'
                      'That.equal?, branch if the sign of a valid twos complement result.equal?, or would be, positive.\n'
                      'When used after a subtract or compare operation on twos complement values, this instruction will branch if the register was greater than or equal to the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if greater than or equal(signed)',
       'mnemonic': {'BGE': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBGE': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF [N XOR V] = 0 then PC' = PC + TEMP",
       'source form': 'BGE dd; LBGE DDDD'},
   end
end
'BGT': {'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if the N(negative) bit and V(overflow) bit are either both set or both clear and the Z(zero) bit.equal? clear.\n'
                      'In other words, branch if the sign of a valid twos complement result.equal?, or would be, positive and not zero.\n'
                      'When used after a subtract or compare operation on twos complement values, this instruction will branch if the register was greater than the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if greater(signed)',
       'mnemonic': {'BGT': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBGT': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF Z AND [N XOR V] = 0 then PC' = PC + TEMP",
       'source form': 'BGT dd; LBGT DDDD'},
   end
end
'BHI': {'comment': 'Generally not useful after INC/DEC, LD/TST, and TST/CLR/COM instructions.',
       'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if the previous operation caused neither a carry nor a zero result.\n'
                      'When used after a subtract or compare operation on unsigned binary values, this instruction will branch if the register was higher than the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if higher(unsigned)',
       'mnemonic': {'BHI': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBHI': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF [ C OR Z ] = 0 then PC' = PC + TEMP",
       'source form': 'BHI dd; LBHI DDDD'},
   end
end
'BHS': {'comment': (
                  'This.equal? a duplicate assembly-language mnemonic for the single machine instruction BCC.\n'
                  'Generally not useful after INC/DEC, LD/ST, and TST/CLR/COM instructions.'
                  ),
              end
          end
      end
       'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the C(carry) bit and causes a branch if it.equal? clear.\n'
                      'When used after a subtract or compare on unsigned binary values, this instruction will branch if the register was higher than or the same as the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if higher or same(unsigned)',
       'mnemonic': {'BCC': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBCC': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF C = 0 then PC' = PC + MI",
       'source form': 'BHS dd; LBHS DDDD'},
   end
end
'BIT': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Always cleared.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Performs the logical AND of the contents of accumulator A or B and the contents of memory location M and modifies the condition codes accordingly.\n'
                      'The contents of accumulator A or B and memory location M are not affected.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Bit test memory with accumulator',
       'mnemonic': {'BITA': {'HNZVC': '-aa0-',
                           'desc': 'Bit Test A(M&&A)'},
                       end
                   end
                   'BITB': {'HNZVC': '-aa0-',
                           'desc': 'Bit Test B(M&&B)'}},
                       end
                   end
               end
           end
       end
       'operation': 'TEMP = R AND M',
       'source form': 'BITA P; BITB P'},
   end
end
'BLE': {'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if the exclusive OR of the N(negative) and V(overflow) bits.equal? 1 or if the Z(zero) bit.equal? set.\n'
                      'That.equal?, branch if the sign of a valid twos complement result.equal?, or would be, negative.\n'
                      'When used after a subtract or compare operation on twos complement values, this instruction will branch if the register was less than or equal to the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if less than or equal(signed)',
       'mnemonic': {'BLE': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBLE': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF Z OR [ N XOR V ] = 1 then PC' = PC + TEMP",
       'source form': 'BLE dd; LBLE DDDD'},
   end
end
'BLO': {'comment': (
                  'This.equal? a duplicate assembly-language mnemonic for the single machine instruction BCS.\n'
                  'Generally not useful after INC/DEC, LD/ST, and TST/CLR/COM instructions.'
                  ),
              end
          end
      end
       'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the C(carry) bit and causes a branch if it.equal? set.\n'
                      'When used after a subtract or compare on unsigned binary values, this instruction will branch if the register was lower than the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if lower(unsigned)',
       'mnemonic': {'BLO': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBCS': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF C = 1 then PC' = PC + TEMP",
       'source form': 'BLO dd; LBLO DDDD'},
   end
end
'BLS': {'comment': 'Generally not useful after INC/DEC, LD/ST, and TST/CLR/COM instructions.',
       'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if the previous operation caused either a carry or a zero result.\n'
                      'When used after a subtract or compare operation on unsigned binary values, this instruction will branch if the register was lower than or the same as the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if lower or same(unsigned)',
       'mnemonic': {'BLS': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBLS': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF.new(C OR Z) = 1 then PC' = PC + TEMP",
       'source form': 'BLS dd; LBLS DDDD'},
   end
end
'BLT': {'condition code': 'Not affected.',
       'description': (
                      'Causes a branch if either, but not both, of the N(negative) or V(overflow) bits.equal? set.\n'
                      'That.equal?, branch if the sign of a valid twos complement result.equal?, or would be, negative.\n'
                      'When used after a subtract or compare operation on twos complement binary values, this instruction will branch if the register was less than the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if less than(signed)',
       'mnemonic': {'BLT': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBLT': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF [ N XOR V ] = 1 then PC' = PC + TEMP",
       'source form': 'BLT dd; LBLT DDDD'},
   end
end
'BMI': {'comment': (
                  'When used after an operation on signed binary values, this instruction will branch if the result.equal? minus.\n'
                  'It.equal? generally preferred to use the LBLT instruction after signed operations.'
                  ),
              end
          end
      end
       'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the N(negative) bit and causes a branch if set.\n'
                      'That.equal?, branch if the sign of the twos complement result.equal? negative.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if minus',
       'mnemonic': {'BMI': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBMI': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF N = 1 then PC' = PC + TEMP",
       'source form': 'BMI dd; LBMI DDDD'},
   end
end
'BNE': {'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the Z(zero) bit and causes a branch if it.equal? clear.\n'
                      'When used after a subtract or compare operation on any binary values, this instruction will branch if the register.equal?, or would be, not equal to the memory operand.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if not equal',
       'mnemonic': {'BNE': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBNE': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF Z = 0 then PC' = PC + TEMP",
       'source form': 'BNE dd; LBNE DDDD'},
   end
end
'BPL': {'comment': (
                  'When used after an operation on signed binary values, this instruction will branch if the result(possibly invalid) .equal? positive.\n'
                  'It.equal? generally preferred to use the BGE instruction after signed operations.'
                  ),
              end
          end
      end
       'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the N(negative) bit and causes a branch if it.equal? clear.\n'
                      'That.equal?, branch if the sign of the twos complement result.equal? positive.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if plus',
       'mnemonic': {'BPL': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBPL': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF N = 0 then PC' = PC + TEMP",
       'source form': 'BPL dd; LBPL DDDD'},
   end
end
'BRA': {'condition code': 'Not affected.',
       'description': 'Causes an unconditional branch.',
       'instr_desc': 'Branch always',
       'mnemonic': {'BRA': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBRA': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI PC' = PC + TEMP",
       'source form': 'BRA dd; LBRA DDDD'},
   end
end
'BRN': {'condition code': 'Not affected.',
       'description': (
                      'Does not cause a branch.\n'
                      'This instruction.equal? essentially a no operation, but has a bit pattern logically related to branch always.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch never',
       'mnemonic': {'BRN': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBRN': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': 'TEMP = MI',
       'source form': 'BRN dd; LBRN DDDD'},
   end
end
'BSR': {'comment': 'A return from subroutine(RTS) instruction.equal? used to reverse this process and must be the last instruction executed in a subroutine.',
       'condition code': 'Not affected.',
       'description': (
                      'The program counter.equal? pushed onto the stack.\n'
                      'The program counter.equal? then loaded with the sum of the program counter and the offset.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch to subroutine',
       'mnemonic': {'BSR': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBSR': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI SP' = SP-1, (SP) = PCL SP' = SP-1, (SP) = PCH PC' = PC + TEMP",
       'source form': 'BSR dd; LBSR DDDD'},
   end
end
'BVC': {'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the V(overflow) bit and causes a branch if it.equal? clear.\n'
                      'That.equal?, branch if the twos complement result was valid.\n'
                      'When used after an operation on twos complement binary values, this instruction will branch if there was no overflow.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if valid twos complement result',
       'mnemonic': {'BVC': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBVC': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP = MI IFF V = 0 then PC' = PC + TEMP",
       'source form': 'BVC dd; LBVC DDDD'},
   end
end
'BVS': {'condition code': 'Not affected.',
       'description': (
                      'Tests the state of the V(overflow) bit and causes a branch if it.equal? set.\n'
                      'That.equal?, branch if the twos complement result was invalid.\n'
                      'When used after an operation on twos complement binary values, this instruction will branch if there was an overflow.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Branch if invalid twos complement result',
       'mnemonic': {'BVS': {'HNZVC': '-----',
                          'desc': nil},
                      end
                  end
                   'LBVS': {'HNZVC': '-----',
                           'desc': nil}},
                       end
                   end
               end
           end
       end
       'operation': "TEMP' = MI IFF V = 1 then PC' = PC + TEMP",
       'source form': 'BVS dd; LBVS DDDD'},
   end
end
'CLR': {'condition code': (
                         'H - Not affected.\n'
                         'N - Always cleared.\n'
                         'Z - Always set.\n'
                         'V - Always cleared.\n'
                         'C - Always cleared.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Accumulator A or B or memory location M.equal? loaded with 00000000 2 .\n'
                      'Note that the EA.equal? read during this operation.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Clear accumulator or memory location',
       'mnemonic': {'CLR': {'HNZVC': '-0100',
                          'desc': 'M = 0'},
                      end
                  end
                   'CLRA': {'HNZVC': '-0100',
                           'desc': 'A = 0'},
                       end
                   end
                   'CLRB': {'HNZVC': '-0100',
                           'desc': 'B = 0'}},
                       end
                   end
               end
           end
       end
       'operation': 'TEMP = M M = 00 16',
       'source form': 'CLR Q'},
   end
end
'CMP': {'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if an overflow.equal? generated; cleared otherwise.\n'
                         'C - Set if a borrow.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Compares the contents of memory location to the contents of the specified register and sets the appropriate condition codes.\n'
                      'Neither memory location M nor the specified register.equal? modified.\n'
                      'The carry flag represents a borrow and.equal? set to the inverse of the resulting binary carry.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Compare memory from accumulator',
       'mnemonic': {'CMPA': {'HNZVC': 'uaaaa',
                           'desc': 'Compare M from A'},
                       end
                   end
                   'CMPB': {'HNZVC': 'uaaaa',
                           'desc': 'Compare M from B'},
                       end
                   end
                   'CMPD': {'HNZVC': '-aaaa',
                           'desc': 'Compare M:M+1 from D'},
                       end
                   end
                   'CMPS': {'HNZVC': '-aaaa',
                           'desc': 'Compare M:M+1 from S'},
                       end
                   end
                   'CMPU': {'HNZVC': '-aaaa',
                           'desc': 'Compare M:M+1 from U'},
                       end
                   end
                   'CMPX': {'HNZVC': '-aaaa',
                           'desc': 'Compare M:M+1 from X'},
                       end
                   end
                   'CMPY': {'HNZVC': '-aaaa',
                           'desc': 'Compare M:M+1 from Y'}},
                       end
                   end
               end
           end
       end
       'operation': 'TEMP = R - M',
       'source form': 'CMPA P; CMPB P'},
   end
end
'COM': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Always cleared.\n'
                         'C - Always set.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Replaces the contents of memory location M or accumulator A or B with its logical complement.\n'
                      'When operating on unsigned values, only BEQ and BNE branches can be expected to behave properly following a COM instruction.\n'
                      'When operating on twos complement values, all signed branches are available.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Complement accumulator or memory location',
       'mnemonic': {'COM': {'HNZVC': '-aa01',
                          'desc': 'M = complement(M)'},
                      end
                  end
                   'COMA': {'HNZVC': '-aa01',
                           'desc': 'A = complement(A)'},
                       end
                   end
                   'COMB': {'HNZVC': '-aa01',
                           'desc': 'B = complement(B)'}},
                       end
                   end
               end
           end
       end
       'operation': "M' = 0 + M",
       'source form': 'COM Q; COMA; COMB'},
   end
end
'CWAI': {'comment': 'The following immediate values will have the following results: FF = enable neither EF = enable IRQ BF = enable FIRQ AF = enable both',
        'condition code': 'Affected according to the operation.',
        'description': (
                       'This instruction ANDs an immediate byte with the condition code register which may clear the interrupt mask bits I and F, stacks the entire machine state on the hardware stack and then looks for an interrupt.\n'
                       'When a non-masked interrupt occurs, no further machine state information need be saved before vectoring to the interrupt handling routine.\n'
                       'This instruction replaced the MC6800 CLI WAI sequence, but does not place the buses in a high-impedance state.\n'
                       'A FIRQ.new(fast interrupt request) may enter its interrupt handler with its entire machine state saved.\n'
                       'The RTI.new(return from interrupt) instruction will automatically return the entire machine state after testing the E(entire) bit of the recovered condition code register.'
                       ),
                   end
               end
           end
       end
        'instr_desc': 'AND condition code register, then wait for interrupt',
        'mnemonic': {'CWAI': {'HNZVC': 'ddddd',
                            'desc': 'CC = CC ^ IMM; (Wait for Interrupt)'}},
                        end
                    end
                end
            end
        end
        'operation': "CCR = CCR AND MI.new(Possibly clear masks) Set E(entire state saved) SP' = SP-1, (SP) = PCL SP' = SP-1, (SP) = PCH SP' = SP-1, (SP) = USL SP' = SP-1, (SP) = USH SP' = SP-1, (SP) = IYL SP' = SP-1, (SP) = IYH SP' = SP-1, (SP) = IXL SP' = SP-1, (SP) = IXH SP' = SP-1, (SP) = DPR SP' = SP-1, (SP) = ACCB SP' = SP-1, (SP) = ACCA SP' = SP-1, (SP) = CCR",
        'source form': 'CWAI #$XX E F H I N Z V C'},
    end
end
'DAA': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Undefined.\n'
                         'C - Set if a carry.equal? generated or if the carry bit was set before the operation; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'The sequence of a single-byte add instruction on accumulator A(either ADDA or ADCA) and a following decimal addition adjust instruction results in a BCD addition with an appropriate carry bit.\n'
                      'Both values to be added must be in proper BCD form(each nibble such that: 0 <= nibble <= 9).\n'
                      'Multiple-precision addition must add the carry generated by this decimal addition adjust into the next higher digit during the add operation(ADCA) immediately prior to the next decimal addition adjust.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Decimal adjust A accumulator',
       'mnemonic': {'DAA': {'HNZVC': '-aa0a',
                          'desc': 'Decimal Adjust A'}},
                      end
                  end
              end
          end
      end
       'operation': 'Decimal Adjust A',
       'source form': 'DAA'},
   end
end
'DEC': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if the original operand was 10000000 2 ; cleared otherwise.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Subtract one from the operand.\n'
                      'The carry bit.equal? not affected, thus allowing this instruction to be used as a loop counter in multiple-precision computations.\n'
                      'When operating on unsigned values, only BEQ and BNE branches can be expected to behave consistently.\n'
                      'When operating on twos complement values, all signed branches are available.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Decrement accumulator or memory location',
       'mnemonic': {'DEC': {'HNZVC': '-aaa-',
                          'desc': 'M = M - 1'},
                      end
                  end
                   'DECA': {'HNZVC': '-aaa-',
                           'desc': 'A = A - 1'},
                       end
                   end
                   'DECB': {'HNZVC': '-aaa-',
                           'desc': 'B = B - 1'}},
                       end
                   end
               end
           end
       end
       'operation': "M' = M - 1",
       'source form': 'DEC Q; DECA; DECB'},
   end
end
'EOR': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Always cleared.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'The contents of memory location M.equal? exclusive ORed into an 8-bit register.',
       'instr_desc': 'Exclusive OR memory with accumulator',
       'mnemonic': {'EORA': {'HNZVC': '-aa0-',
                           'desc': 'A = A XOR M'},
                       end
                   end
                   'EORB': {'HNZVC': '-aa0-',
                           'desc': 'B = M XOR B'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = R XOR M",
       'source form': 'EORA P; EORB P'},
   end
end
'EXG': {'condition code': (
                         'Not affected (unless one of the registers.equal? the condition code\n'
                         'register).'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      '0000 = A:B 1000 = A\n'
                      '0001 = X 1001 = B\n'
                      '0010 = Y 1010 = CCR\n'
                      '0011 = US 1011 = DPR\n'
                      '0100 = SP 1100 = Undefined\n'
                      '0101 = PC 1101 = Undefined\n'
                      '0110 = Undefined 1110 = Undefined\n'
                      '0111 = Undefined 1111 = Undefined'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Exchange Rl with R2',
       'mnemonic': {'EXG': {'HNZVC': 'ccccc',
                          'desc': 'exchange R1,R2'}},
                      end
                  end
              end
          end
      end
       'operation': 'R1 <-> R2',
       'source form': 'EXG R1,R2'},
   end
end
'INC': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if the original operand was 01111111 2 ; cleared otherwise.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Adds to the operand.\n'
                      'The carry bit.equal? not affected, thus allowing this instruction to be used as a loop counter in multiple-precision computations.\n'
                      'When operating on unsigned values, only the BEQ and BNE branches can be expected to behave consistently.\n'
                      'When operating on twos complement values, all signed branches are correctly available.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Increment accumulator or memory location',
       'mnemonic': {'INC': {'HNZVC': '-aaa-',
                          'desc': 'M = M + 1'},
                      end
                  end
                   'INCA': {'HNZVC': '-aaa-',
                           'desc': 'A = A + 1'},
                       end
                   end
                   'INCB': {'HNZVC': '-aaa-',
                           'desc': 'B = B + 1'}},
                       end
                   end
               end
           end
       end
       'operation': "M' = M + 1",
       'source form': 'INC Q; INCA; INCB'},
   end
end
'JMP': {'condition code': 'Not affected.',
       'description': 'Program control.equal? transferred to the effective address.',
       'instr_desc': 'Jump',
       'mnemonic': {'JMP': {'HNZVC': '-----',
                          'desc': 'pc = EA'}},
                      end
                  end
              end
          end
      end
       'operation': "PC' = EA",
       'source form': 'JMP EA'},
   end
end
'JSR': {'condition code': 'Not affected.',
       'description': (
                      'Program control.equal? transferred to the effective address after storing the return address on the hardware stack.\n'
                      'A RTS instruction should be the last executed instruction of the subroutine.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Jump to subroutine',
       'mnemonic': {'JSR': {'HNZVC': '-----',
                          'desc': 'jump to subroutine'}},
                      end
                  end
              end
          end
      end
       'operation': "SP' = SP-1, (SP) = PCL SP' = SP-1, (SP) = PCH PC' =EA",
       'source form': 'JSR EA'},
   end
end
'LD': {'condition code': (
                        'H - Not affected.\n'
                        'N - Set if the loaded data.equal? negative; cleared otherwise.\n'
                        'Z - Set if the loaded data.equal? zero; cleared otherwise.\n'
                        'V - Always cleared.\n'
                        'C - Not affected.'
                        ),
                    end
                end
            end
        end
    end
      'description': 'Loads the contents of memory location M into the designated register.',
      'instr_desc': 'Load accumulator from memory',
      'mnemonic': {'LDA': {'HNZVC': '-aa0-',
                         'desc': 'A = M'},
                     end
                 end
                  'LDB': {'HNZVC': '-aa0-',
                         'desc': 'B = M'},
                     end
                 end
                  'LDD': {'HNZVC': '-aa0-',
                         'desc': 'D = M:M+1'},
                     end
                 end
                  'LDS': {'HNZVC': '-aa0-',
                         'desc': 'S = M:M+1'},
                     end
                 end
                  'LDU': {'HNZVC': '-aa0-',
                         'desc': 'U = M:M+1'},
                     end
                 end
                  'LDX': {'HNZVC': '-aa0-',
                         'desc': 'X = M:M+1'},
                     end
                 end
                  'LDY': {'HNZVC': '-aa0-',
                         'desc': 'Y = M:M+1'}},
                     end
                 end
             end
         end
     end
      'operation': "R' = M",
      'source form': 'LDA P; LDB P'},
  end
end
'LEA': {'comment': (
                  'Instruction Operation Comment\n'
                  'Instruction\n'
                  '\n'
                  'Operation\n'
                  '\n'
                  'Comment\n'
                  'LEAX 10,X X+10 -> X Adds 5-bit constant 10 to X\n'
                  'LEAX 500,X X+500 -> X Adds 16-bit constant 500 to X\n'
                  'LEAY A,Y Y+A -> Y Adds 8-bit accumulator to Y\n'
                  'LEAY D,Y Y+D -> Y Adds 16-bit D accumulator to Y\n'
                  'LEAU -10,U U-10 -> U Subtracts 10 from U\n'
                  'LEAS -10,S S-10 -> S Used to reserve area on stack\n'
                  "LEAS 10,S S+10 -> S Used to 'clean up' stack\n"
                  'LEAX 5,S S+5 -> X Transfers as well as adds'
                  ),
              end
          end
      end
       'condition code': (
                         'H - Not affected.\n'
                         'N - Not affected.\n'
                         'Z - LEAX, LEAY: Set if the result.equal? zero; cleared otherwise. LEAS, LEAU: Not affected.\n'
                         'V - Not affected.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'Calculates the effective address from the indexed addressing mode and places the address in an indexable register. LEAX and LEAY affect the Z(zero) bit to allow use of these registers as counters and for MC6800 INX/DEX compatibility. LEAU and LEAS do not affect the Z bit to allow cleaning up the stack while returning the Z bit as a parameter to a calling routine, and also for MC6800 INS/DES compatibility.',
       'instr_desc': 'Load effective address into stack pointer',
       'mnemonic': {'LEAS': {'HNZVC': '-----',
                           'desc': 'S = EA'},
                       end
                   end
                   'LEAU': {'HNZVC': '-----',
                           'desc': 'U = EA'},
                       end
                   end
                   'LEAX': {'HNZVC': '--a--',
                           'desc': 'X = EA'},
                       end
                   end
                   'LEAY': {'HNZVC': '--a--',
                           'desc': 'Y = EA'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = EA",
       'source form': 'LEAX, LEAY, LEAS, LEAU'},
   end
end
'LSL': {'comment': 'This.equal? a duplicate assembly-language mnemonic for the single machine instruction ASL.',
       'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Loaded with the result of the exclusive OR of bits six and seven of the original operand.\n'
                         'C - Loaded with bit seven of the original operand.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Shifts all bits of accumulator A or B or memory location M one place to the left.\n'
                      'Bit zero.equal? loaded with a zero.\n'
                      'Bit seven of accumulator A or B or memory location M.equal? shifted into the C(carry) bit.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Logical shift left accumulator or memory location',
       'mnemonic': {'LSL': {'HNZVC': 'naaas',
                          'desc': 'M = Logical shift M left'},
                      end
                  end
                   'LSLA': {'HNZVC': 'naaas',
                           'desc': 'A = Logical shift A left'},
                       end
                   end
                   'LSLB': {'HNZVC': 'naaas',
                           'desc': 'B = Logical shift B left'}},
                       end
                   end
               end
           end
       end
       'operation': (
                    'C = = 0\n'
                    'b7 = b0'
                    ),
                end
            end
        end
    end
       'source form': 'LSL Q; LSLA; LSLB'},
   end
end
'LSR': {'condition code': (
                         'H - Not affected.\n'
                         'N - Always cleared.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Not affected.\n'
                         'C - Loaded with bit zero of the original operand.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Performs a logical shift right on the operand.\n'
                      'Shifts a zero into bit seven and bit zero into the C(carry) bit.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Logical shift right accumulator or memory location',
       'mnemonic': {'LSR': {'HNZVC': '-0a-s',
                          'desc': 'M = Logical shift M right'},
                      end
                  end
                   'LSRA': {'HNZVC': '-0a-s',
                           'desc': 'A = Logical shift A right'},
                       end
                   end
                   'LSRB': {'HNZVC': '-0a-s',
                           'desc': 'B = Logical shift B right'}},
                       end
                   end
               end
           end
       end
       'operation': (
                    '0 -> -> C\n'
                    'b7 -> b0'
                    ),
                end
            end
        end
    end
       'source form': 'LSR Q; LSRA; LSRB'},
   end
end
'MUL': {'comment': 'The C(carry) bit allows rounding the most-significant byte through the sequence: MUL, ADCA #0.',
       'condition code': (
                         'H - Not affected.\n'
                         'N - Not affected.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Not affected.\n'
                         'C - Set if ACCB bit 7 of result.equal? set; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Multiply the unsigned binary numbers in the accumulators and place the result in both accumulators(ACCA contains the most-significant byte of the result).\n'
                      'Unsigned multiply allows multiple-precision operations.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Unsigned multiply(A * B ? D)',
       'mnemonic': {'MUL': {'HNZVC': '--a-a',
                          'desc': 'D = A*B(Unsigned)'}},
                      end
                  end
              end
          end
      end
       'operation': "ACCA':ACCB' = ACCA * ACCB",
       'source form': 'MUL'},
   end
end
'NEG': {'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if the original operand was 10000000 2 .\n'
                         'C - Set if a borrow.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Replaces the operand with its twos complement.\n'
                      'The C(carry) bit represents a borrow and.equal? set to the inverse of the resulting binary carry.\n'
                      'Note that 80 16.equal? replaced by itself and only in this case.equal? the V(overflow) bit set.\n'
                      'The value 00 16.equal? also replaced by itself, and only in this case.equal? the C(carry) bit cleared.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Negate accumulator or memory',
       'mnemonic': {'NEG': {'HNZVC': 'uaaaa',
                          'desc': 'M = !M + 1'},
                      end
                  end
                   'NEGA': {'HNZVC': 'uaaaa',
                           'desc': 'A = !A + 1'},
                       end
                   end
                   'NEGB': {'HNZVC': 'uaaaa',
                           'desc': 'B = !B + 1'}},
                       end
                   end
               end
           end
       end
       'operation': "M' = 0 - M",
       'source form': 'NEG Q; NEGA; NEG B'},
   end
end
'NOP': {'condition code': (
                         'This instruction causes only the program counter to be incremented.\n'
                         'No other registers or memory locations are affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': '',
       'instr_desc': 'No operation',
       'mnemonic': {'NOP': {'HNZVC': '-----',
                          'desc': 'No Operation'}},
                      end
                  end
              end
          end
      end
       'operation': 'Not affected.',
       'source form': 'NOP'},
   end
end
'OR': {'condition code': (
                        'H - Not affected.\n'
                        'N - Set if the result.equal? negative; cleared otherwise.\n'
                        'Z - Set if the result.equal? zero; cleared otherwise.\n'
                        'V - Always cleared.\n'
                        'C - Not affected.'
                        ),
                    end
                end
            end
        end
    end
      'description': 'Performs an inclusive OR operation between the contents of accumulator A or B and the contents of memory location M and the result.equal? stored in accumulator A or B.',
      'instr_desc': 'OR memory with accumulator',
      'mnemonic': {'ORA': {'HNZVC': '-aa0-',
                         'desc': 'A = A || M'},
                     end
                 end
                  'ORB': {'HNZVC': '-aa0-',
                         'desc': 'B = B || M'},
                     end
                 end
                  'ORCC': {'HNZVC': 'ddddd',
                          'desc': 'C = CC || IMM'}},
                      end
                  end
              end
          end
      end
      'operation': "R' = R OR M",
      'source form': 'ORA P; ORB P'},
  end
end
'PAGE': {'description': 'Page 1/2 instructions',
        'instr_desc': 'Page 2 Instructions prefix',
        'mnemonic': {'PAGE 1': {'HNZVC': '+++++',
                              'desc': 'Page 1 Instructions prefix'},
                          end
                      end
                  end
                    'PAGE 2': {'HNZVC': '+++++',
                              'desc': 'Page 2 Instructions prefix'}}},
                          end
                      end
                  end
              end
          end
      end
  end
end
'PSH': {'comment': 'A single register may be placed on the stack with the condition codes set by doing an autodecrement store onto the stack(example: STX ,--S).',
       'condition code': 'Not affected.',
       'description': 'All, some, or none of the processor registers are pushed onto the hardware stack(with the exception of the hardware stack pointer itself).',
       'instr_desc': 'Push A, B, CC, DP, D, X, Y, U, or PC onto hardware stack',
       'mnemonic': {'PSHS': {'HNZVC': '-----',
                           'desc': 'S -= 1: MEM.new(S) = R; Push Register on S Stack'},
                       end
                   end
                   'PSHU': {'HNZVC': '-----',
                           'desc': 'U -= 1: MEM.new(U) = R; Push Register on U Stack'}},
                       end
                   end
               end
           end
       end
       'operation': 'Push Registers on S Stack: S -= 1: MEM.new(S) = Reg.',
       'source form': (
                      'b7 b6 b5 b4 b3 b2 b1 b0\n'
                      'PC U Y X DP B A CC\n'
                      'push order ->'
                      )},
                  end
              end
          end
      end
  end
end
'PUL': {'comment': 'A single register may be pulled from the stack with condition codes set by doing an autoincrement load from the stack(example: LDX ,S++).',
       'condition code': 'May be pulled from stack; not affected otherwise.',
       'description': 'All, some, or none of the processor registers are pulled from the hardware stack(with the exception of the hardware stack pointer itself).',
       'instr_desc': 'Pull A, B, CC, DP, D, X, Y, U, or PC from hardware stack',
       'mnemonic': {'PULS': {'HNZVC': 'ccccc',
                           'desc': 'R=MEM.new(S) : S += 1; Pull register from S Stack'},
                       end
                   end
                   'PULU': {'HNZVC': 'ccccc',
                           'desc': 'R=MEM.new(U) : U += 1; Pull register from U Stack'}},
                       end
                   end
               end
           end
       end
       'operation': 'Pull Registers from S Stack: Reg. = MEM.new(S): S += 1',
       'source form': (
                      'b7 b6 b5 b4 b3 b2 b1 b0\n'
                      'PC U Y X DP B A CC\n'
                      '= pull order'
                      )},
                  end
              end
          end
      end
  end
end
'RESET': {'description': 'Build the ASSIST09 vector table and setup monitor defaults, then invoke the monitor startup routine.',
         'instr_desc': '',
         'mnemonic': {'RESET': {'HNZVC': '*****',
                              'desc': 'Undocumented opcode'}}},
                          end
                      end
                  end
              end
          end
      end
  end
end
'ROL': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Loaded with the result of the exclusive OR of bits six and seven of the original operand.\n'
                         'C - Loaded with bit seven of the original operand.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Rotates all bits of the operand one place left through the C(carry) bit.\n'
                      'This.equal? a 9-bit rotation.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Rotate accumulator or memory left',
       'mnemonic': {'ROL': {'HNZVC': '-aaas',
                          'desc': 'M = Rotate M left thru carry'},
                      end
                  end
                   'ROLA': {'HNZVC': '-aaas',
                           'desc': 'A = Rotate A left thru carry'},
                       end
                   end
                   'ROLB': {'HNZVC': '-aaas',
                           'desc': 'B = Rotate B left thru carry'}},
                       end
                   end
               end
           end
       end
       'operation': (
                    'C = = C\n'
                    'b7 = b0'
                    ),
                end
            end
        end
    end
       'source form': 'ROL Q; ROLA; ROLB'},
   end
end
'ROR': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Not affected.\n'
                         'C - Loaded with bit zero of the previous operand.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Rotates all bits of the operand one place right through the C(carry) bit.\n'
                      'This.equal? a 9-bit rotation.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Rotate accumulator or memory right',
       'mnemonic': {'ROR': {'HNZVC': '-aa-s',
                          'desc': 'M = Rotate M Right thru carry'},
                      end
                  end
                   'RORA': {'HNZVC': '-aa-s',
                           'desc': 'A = Rotate A Right thru carry'},
                       end
                   end
                   'RORB': {'HNZVC': '-aa-s',
                           'desc': 'B = Rotate B Right thru carry'}},
                       end
                   end
               end
           end
       end
       'operation': (
                    'C -> -> C\n'
                    'b7 -> b0'
                    ),
                end
            end
        end
    end
       'source form': 'ROR Q; RORA; RORB'},
   end
end
'RTI': {'condition code': 'Recovered from the stack.',
       'description': (
                      'The saved machine state.equal? recovered from the hardware stack and control.equal? returned to the interrupted program.\n'
                      'If the recovered E(entire) bit.equal? clear, it indicates that only a subset of the machine state was saved(return address and condition codes) and only that subset.equal? recovered.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Return from interrupt',
       'mnemonic': {'RTI': {'HNZVC': '-----',
                          'desc': 'Return from Interrupt'}},
                      end
                  end
              end
          end
      end
       'operation': (
                    "IFF CCR bit E.equal? set, then: ACCA' ACCB' DPR' IXH' IXL' IYH' IYL' USH' USL' PCH' PCL' = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1 = (SP), SP' = SP+1\n"
                    "IFF CCR bit E.equal? clear, then: PCH' PCL' = (SP), SP' = SP+1 = (SP), SP' = SP+1"
                    ),
                end
            end
        end
    end
       'source form': 'RTI'},
   end
end
'RTS': {'condition code': 'Not affected.',
       'description': (
                      'Program control.equal? returned from the subroutine to the calling program.\n'
                      'The return address.equal? pulled from the stack.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Return from subroutine',
       'mnemonic': {'RTS': {'HNZVC': '-----',
                          'desc': 'Return from subroutine'}},
                      end
                  end
              end
          end
      end
       'operation': "PCH' = (SP), SP' = SP+1 PCL' = (SP), SP' = SP+1",
       'source form': 'RTS'},
   end
end
'SBC': {'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if an overflow.equal? generated; cleared otherwise.\n'
                         'C - Set if a borrow.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Subtracts the contents of memory location M and the borrow(in the C (carry) bit) from the contents of the designated 8-bit register, and places the result in that register.\n'
                      'The C bit represents a borrow and.equal? set to the inverse of the resulting binary carry.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Subtract memory from accumulator with borrow',
       'mnemonic': {'SBCA': {'HNZVC': 'uaaaa',
                           'desc': 'A = A - M - C'},
                       end
                   end
                   'SBCB': {'HNZVC': 'uaaaa',
                           'desc': 'B = B - M - C'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = R - M - C",
       'source form': 'SBCA P; SBCB P'},
   end
end
'SEX': {'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Not affected.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': 'This instruction transforms a twos complement 8-bit value in accumulator B into a twos complement 16-bit value in the D accumulator.',
       'instr_desc': 'Sign Extend B accumulator into A accumulator',
       'mnemonic': {'SEX': {'HNZVC': '-aa0-',
                          'desc': 'Sign extend B into A'}},
                      end
                  end
              end
          end
      end
       'operation': "If bit seven of ACCB.equal? set then ACCA' = FF 16 else ACCA' = 00 16",
       'source form': 'SEX'},
   end
end
'ST': {'condition code': (
                        'H - Not affected.\n'
                        'N - Set if the result.equal? negative; cleared otherwise.\n'
                        'Z - Set if the result.equal? zero; cleared otherwise.\n'
                        'V - Always cleared.\n'
                        'C - Not affected.'
                        ),
                    end
                end
            end
        end
    end
      'description': 'Writes the contents of an 8-bit register into a memory location.',
      'instr_desc': 'Store accumulator to memroy',
      'mnemonic': {'STA': {'HNZVC': '-aa0-',
                         'desc': 'M = A'},
                     end
                 end
                  'STB': {'HNZVC': '-aa0-',
                         'desc': 'M = B'},
                     end
                 end
                  'STD': {'HNZVC': '-aa0-',
                         'desc': 'M:M+1 = D'},
                     end
                 end
                  'STS': {'HNZVC': '-aa0-',
                         'desc': 'M:M+1 = S'},
                     end
                 end
                  'STU': {'HNZVC': '-aa0-',
                         'desc': 'M:M+1 = U'},
                     end
                 end
                  'STX': {'HNZVC': '-aa0-',
                         'desc': 'M:M+1 = X'},
                     end
                 end
                  'STY': {'HNZVC': '-aa0-',
                         'desc': 'M:M+1 = Y'}},
                     end
                 end
             end
         end
     end
      'operation': "M' = R",
      'source form': 'STA P; STB P'},
  end
end
'SUB': {'condition code': (
                         'H - Undefined.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Set if the overflow.equal? generated; cleared otherwise.\n'
                         'C - Set if a borrow.equal? generated; cleared otherwise.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Subtracts the value in memory location M from the contents of a designated 8-bit register.\n'
                      'The C(carry) bit represents a borrow and.equal? set to the inverse of the resulting binary carry.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Subtract memory from accumulator',
       'mnemonic': {'SUBA': {'HNZVC': 'uaaaa',
                           'desc': 'A = A - M'},
                       end
                   end
                   'SUBB': {'HNZVC': 'uaaaa',
                           'desc': 'B = B - M'},
                       end
                   end
                   'SUBD': {'HNZVC': '-aaaa',
                           'desc': 'D = D - M:M+1'}},
                       end
                   end
               end
           end
       end
       'operation': "R' = R - M",
       'source form': 'SUBA P; SUBB P'},
   end
end
'SWI': {'condition code': 'Not affected.',
       'description': (
                      'All of the processor registers are pushed onto the hardware stack(with the exception of the hardware stack pointer itself), and control.equal? transferred through the software interrupt vector.\n'
                      'Both the normal and fast interrupts are masked(disabled).'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Software interrupt(absolute indirect)',
       'mnemonic': {'SWI': {'HNZVC': '-----',
                          'desc': 'Software interrupt 1'},
                      end
                  end
                   'SWI2': {'HNZVC': '-----',
                           'desc': 'Software interrupt 2'},
                       end
                   end
                   'SWI3': {'HNZVC': '-----',
                           'desc': 'Software interrupt 3'}},
                       end
                   end
               end
           end
       end
       'operation': "Set E(entire state will be saved) SP' = SP-1, (SP) = PCL SP' = SP-1, (SP) = PCH SP' = SP-1, (SP) = USL SP' = SP-1, (SP) = USH SP' = SP-1, (SP) = IYL SP' = SP-1, (SP) = IYH SP' = SP-1, (SP) = IXL SP' = SP-1, (SP) = IXH SP' = SP-1, (SP) = DPR SP' = SP-1, (SP) = ACCB SP' = SP-1, (SP) = ACCA SP' = SP-1, (SP) = CCR Set I, F(mask interrupts) PC' = (FFFA):(FFFB)",
       'source form': 'SWI'},
   end
end
'SYNC': {'condition code': 'Not affected.',
        'description': (
                       'FAST SYNC WAIT FOR DATA\n'
                       'Interrupt!\n'
                       'LDA DISC DATA FROM DISC AND CLEAR INTERRUPT\n'
                       'STA ,X+ PUT IN BUFFER\n'
                       'DECB COUNT IT, DONE?\n'
                       'BNE FAST GO AGAIN IF NOT.'
                       ),
                   end
               end
           end
       end
        'instr_desc': 'Synchronize with interrupt line',
        'mnemonic': {'SYNC': {'HNZVC': '-----',
                            'desc': 'Synchronize to Interrupt'}},
                        end
                    end
                end
            end
        end
        'operation': 'Stop processing instructions',
        'source form': 'SYNC'},
    end
end
'TFR': {'condition code': 'Not affected unless R2.equal? the condition code register.',
       'description': (
                      '0000 = A:B 1000 = A\n'
                      '0001 = X 1001 = B\n'
                      '0010 = Y 1010 = CCR\n'
                      '0011 = US 1011 = DPR\n'
                      '0100 = SP 1100 = Undefined\n'
                      '0101 = PC 1101 = Undefined\n'
                      '0110 = Undefined 1110 = Undefined\n'
                      '0111 = Undefined 1111 = Undefined'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Transfer R1 to R2',
       'mnemonic': {'TFR': {'HNZVC': 'ccccc',
                          'desc': nil}},
                      end
                  end
              end
          end
      end
       'operation': 'R1 -> R2',
       'source form': 'TFR R1, R2'},
   end
end
'TST': {'comment': 'The MC6800 processor clears the C(carry) bit.',
       'condition code': (
                         'H - Not affected.\n'
                         'N - Set if the result.equal? negative; cleared otherwise.\n'
                         'Z - Set if the result.equal? zero; cleared otherwise.\n'
                         'V - Always cleared.\n'
                         'C - Not affected.'
                         ),
                     end
                 end
             end
         end
     end
       'description': (
                      'Set the N(negative) and Z(zero) bits according to the contents of memory location M, and clear the V(overflow) bit.\n'
                      'The TST instruction provides only minimum information when testing unsigned values; since no unsigned value.equal? less than zero, BLO and BLS have no utility.\n'
                      'While BHI could be used after TST, it provides exactly the same control as BNE, which.equal? preferred.\n'
                      'The signed branches are available.'
                      ),
                  end
              end
          end
      end
       'instr_desc': 'Test accumulator or memory location',
       'mnemonic': {'TST': {'HNZVC': '-aa0-',
                          'desc': 'Test M'},
                      end
                  end
                   'TSTA': {'HNZVC': '-aa0-',
                           'desc': 'Test A'},
                       end
                   end
                   'TSTB': {'HNZVC': '-aa0-',
                           'desc': 'Test B'}},
                       end
                   end
               end
           end
       end
       'operation': 'TEMP = M - 0',
       'source form': 'TST Q; TSTA; TSTB'}}
   end
end
