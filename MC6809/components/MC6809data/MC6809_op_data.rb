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




BYTE = "8"
WORD = "16"


# Address modes
DIRECT = "DIRECT"
DIRECT_WORD = "DIRECT_WORD"
EXTENDED = "EXTENDED"
EXTENDED_WORD = "EXTENDED_WORD"
IMMEDIATE = "IMMEDIATE"
IMMEDIATE_WORD = "IMMEDIATE_WORD"
INDEXED = "INDEXED"
INDEXED_WORD = "INDEXED_WORD"
INHERENT = "INHERENT"
RELATIVE = "RELATIVE"
RELATIVE_WORD = "RELATIVE_WORD"


# Registers
REG_A = "A"
REG_B = "B"
REG_CC = "CC"
REG_D = "D"
REG_DP = "DP"
REG_PC = "PC"
REG_S = "S"
REG_U = "U"
REG_X = "X"
REG_Y = "Y"


OP_DATA={'ABX': {'mnemonic': {'ABX': {'needs_ea': false,
                          'ops': {0x3a: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'ADC': {'mnemonic': {'ADCA': {'needs_ea': false,
                           'ops': {0x89: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x99: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa9: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb9: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'ADCB': {'needs_ea': false,
                           'ops': {0xc9: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd9: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe9: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf9: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'ADD': {'mnemonic': {'ADDA': {'needs_ea': false,
                           'ops': {0x8b: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x9b: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xab: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xbb: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'ADDB': {'needs_ea': false,
                           'ops': {0xcb: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xdb: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xeb: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xfb: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil},
                       end
                   end
                   'ADDD': {'needs_ea': false,
                           'ops': {0xc3: {'addr_mode': IMMEDIATE_WORD,
                                        'bytes': 3,
                                        'cycles': 4},
                                    end
                                end
                                  0xd3: {'addr_mode': DIRECT_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xe3: {'addr_mode': INDEXED_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xf3: {'addr_mode': EXTENDED_WORD,
                                        'bytes': 3,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': WORD,
                           'register': REG_D,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'AND': {'mnemonic': {'ANDA': {'needs_ea': false,
                           'ops': {0x84: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x94: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa4: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb4: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'ANDB': {'needs_ea': false,
                           'ops': {0xc4: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd4: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe4: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf4: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil},
                       end
                   end
                   'ANDCC': {'needs_ea': false,
                            'ops': {0x1c: {'addr_mode': IMMEDIATE,
                                         'bytes': 2,
                                         'cycles': 3}},
                                     end
                                 end
                             end
                         end
                            'read_from_memory': BYTE,
                            'register': REG_CC,
                            'write_to_memory': nil}}},
                        end
                    end
                end
            end
        end
    end
end
'ASR': {'mnemonic': {'ASR': {'needs_ea': true,
                          'ops': {0x07: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x67: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x77: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'ASRA': {'needs_ea': false,
                           'ops': {0x47: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'ASRB': {'needs_ea': false,
                           'ops': {0x57: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BEQ': {'mnemonic': {'BEQ': {'needs_ea': true,
                          'ops': {0x27: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBEQ': {'needs_ea': true,
                           'ops': {0x1027: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BGE': {'mnemonic': {'BGE': {'needs_ea': true,
                          'ops': {0x2c: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBGE': {'needs_ea': true,
                           'ops': {0x102c: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BGT': {'mnemonic': {'BGT': {'needs_ea': true,
                          'ops': {0x2e: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBGT': {'needs_ea': true,
                           'ops': {0x102e: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BHI': {'mnemonic': {'BHI': {'needs_ea': true,
                          'ops': {0x22: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBHI': {'needs_ea': true,
                           'ops': {0x1022: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BHS': {'mnemonic': {'BCC': {'needs_ea': true,
                          'ops': {0x24: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBCC': {'needs_ea': true,
                           'ops': {0x1024: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BIT': {'mnemonic': {'BITA': {'needs_ea': false,
                           'ops': {0x85: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x95: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa5: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb5: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'BITB': {'needs_ea': false,
                           'ops': {0xc5: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd5: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe5: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf5: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BLE': {'mnemonic': {'BLE': {'needs_ea': true,
                          'ops': {0x2f: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBLE': {'needs_ea': true,
                           'ops': {0x102f: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BLO': {'mnemonic': {'BLO': {'needs_ea': true,
                          'ops': {0x25: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBCS': {'needs_ea': true,
                           'ops': {0x1025: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BLS': {'mnemonic': {'BLS': {'needs_ea': true,
                          'ops': {0x23: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBLS': {'needs_ea': true,
                           'ops': {0x1023: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BLT': {'mnemonic': {'BLT': {'needs_ea': true,
                          'ops': {0x2d: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBLT': {'needs_ea': true,
                           'ops': {0x102d: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BMI': {'mnemonic': {'BMI': {'needs_ea': true,
                          'ops': {0x2b: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBMI': {'needs_ea': true,
                           'ops': {0x102b: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BNE': {'mnemonic': {'BNE': {'needs_ea': true,
                          'ops': {0x26: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBNE': {'needs_ea': true,
                           'ops': {0x1026: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BPL': {'mnemonic': {'BPL': {'needs_ea': true,
                          'ops': {0x2a: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBPL': {'needs_ea': true,
                           'ops': {0x102a: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BRA': {'mnemonic': {'BRA': {'needs_ea': true,
                          'ops': {0x20: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBRA': {'needs_ea': true,
                           'ops': {0x16: {'addr_mode': RELATIVE_WORD,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BRN': {'mnemonic': {'BRN': {'needs_ea': true,
                          'ops': {0x21: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBRN': {'needs_ea': true,
                           'ops': {0x1021: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BSR': {'mnemonic': {'BSR': {'needs_ea': true,
                          'ops': {0x8d: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBSR': {'needs_ea': true,
                           'ops': {0x17: {'addr_mode': RELATIVE_WORD,
                                        'bytes': 3,
                                        'cycles': 9}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BVC': {'mnemonic': {'BVC': {'needs_ea': true,
                          'ops': {0x28: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBVC': {'needs_ea': true,
                           'ops': {0x1028: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'BVS': {'mnemonic': {'BVS': {'needs_ea': true,
                          'ops': {0x29: {'addr_mode': RELATIVE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'LBVS': {'needs_ea': true,
                           'ops': {0x1029: {'addr_mode': RELATIVE_WORD,
                                          'bytes': 4,
                                          'cycles': 5}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'CLR': {'mnemonic': {'CLR': {'needs_ea': true,
                          'ops': {0x0f: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x6f: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x7f: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'CLRA': {'needs_ea': false,
                           'ops': {0x4f: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'CLRB': {'needs_ea': false,
                           'ops': {0x5f: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'CMP': {'mnemonic': {'CMPA': {'needs_ea': false,
                           'ops': {0x81: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x91: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa1: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb1: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPB': {'needs_ea': false,
                           'ops': {0xc1: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd1: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe1: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf1: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPD': {'needs_ea': false,
                           'ops': {0x1083: {'addr_mode': IMMEDIATE_WORD,
                                          'bytes': 4,
                                          'cycles': 5},
                                      end
                                  end
                                  0x1093: {'addr_mode': DIRECT_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x10a3: {'addr_mode': INDEXED_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x10b3: {'addr_mode': EXTENDED_WORD,
                                          'bytes': 4,
                                          'cycles': 8}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': WORD,
                           'register': REG_D,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPS': {'needs_ea': false,
                           'ops': {0x118c: {'addr_mode': IMMEDIATE_WORD,
                                          'bytes': 4,
                                          'cycles': 5},
                                      end
                                  end
                                  0x119c: {'addr_mode': DIRECT_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x11ac: {'addr_mode': INDEXED_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x11bc: {'addr_mode': EXTENDED_WORD,
                                          'bytes': 4,
                                          'cycles': 8}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': WORD,
                           'register': REG_S,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPU': {'needs_ea': false,
                           'ops': {0x1183: {'addr_mode': IMMEDIATE_WORD,
                                          'bytes': 4,
                                          'cycles': 5},
                                      end
                                  end
                                  0x1193: {'addr_mode': DIRECT_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x11a3: {'addr_mode': INDEXED_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x11b3: {'addr_mode': EXTENDED_WORD,
                                          'bytes': 4,
                                          'cycles': 8}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': WORD,
                           'register': REG_U,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPX': {'needs_ea': false,
                           'ops': {0x8c: {'addr_mode': IMMEDIATE_WORD,
                                        'bytes': 3,
                                        'cycles': 4},
                                    end
                                end
                                  0x9c: {'addr_mode': DIRECT_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xac: {'addr_mode': INDEXED_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xbc: {'addr_mode': EXTENDED_WORD,
                                        'bytes': 3,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': WORD,
                           'register': REG_X,
                           'write_to_memory': nil},
                       end
                   end
                   'CMPY': {'needs_ea': false,
                           'ops': {0x108c: {'addr_mode': IMMEDIATE_WORD,
                                          'bytes': 4,
                                          'cycles': 5},
                                      end
                                  end
                                  0x109c: {'addr_mode': DIRECT_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x10ac: {'addr_mode': INDEXED_WORD,
                                          'bytes': 3,
                                          'cycles': 7},
                                      end
                                  end
                                  0x10bc: {'addr_mode': EXTENDED_WORD,
                                          'bytes': 4,
                                          'cycles': 8}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': WORD,
                           'register': REG_Y,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'COM': {'mnemonic': {'COM': {'needs_ea': true,
                          'ops': {0x03: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x63: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x73: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'COMA': {'needs_ea': false,
                           'ops': {0x43: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'COMB': {'needs_ea': false,
                           'ops': {0x53: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'CWAI': {'mnemonic': {'CWAI': {'needs_ea': false,
                            'ops': {0x3c: {'addr_mode': IMMEDIATE,
                                         'bytes': 2,
                                         'cycles': 21}},
                                     end
                                 end
                             end
                         end
                            'read_from_memory': BYTE,
                            'register': nil,
                            'write_to_memory': nil}}},
                        end
                    end
                end
            end
        end
    end
end
'DAA': {'mnemonic': {'DAA': {'needs_ea': false,
                          'ops': {0x19: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 2}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'DEC': {'mnemonic': {'DEC': {'needs_ea': true,
                          'ops': {0x0a: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x6a: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x7a: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'DECA': {'needs_ea': false,
                           'ops': {0x4a: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'DECB': {'needs_ea': false,
                           'ops': {0x5a: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'EOR': {'mnemonic': {'EORA': {'needs_ea': false,
                           'ops': {0x88: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x98: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa8: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb8: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'EORB': {'needs_ea': false,
                           'ops': {0xc8: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd8: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe8: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf8: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'EXG': {'mnemonic': {'EXG': {'needs_ea': false,
                          'ops': {0x1e: {'addr_mode': IMMEDIATE,
                                       'bytes': 2,
                                       'cycles': 8}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'INC': {'mnemonic': {'INC': {'needs_ea': true,
                          'ops': {0x0c: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x6c: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x7c: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'INCA': {'needs_ea': false,
                           'ops': {0x4c: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'INCB': {'needs_ea': false,
                           'ops': {0x5c: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'JMP': {'mnemonic': {'JMP': {'needs_ea': true,
                          'ops': {0x0e: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 3},
                                   end
                               end
                                 0x6e: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 3},
                                   end
                               end
                                 0x7e: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'JSR': {'mnemonic': {'JSR': {'needs_ea': true,
                          'ops': {0x9d: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 7},
                                   end
                               end
                                 0xad: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 7},
                                   end
                               end
                                 0xbd: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 8}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'LD': {'mnemonic': {'LDA': {'needs_ea': false,
                         'ops': {0x86: {'addr_mode': IMMEDIATE,
                                      'bytes': 2,
                                      'cycles': 2},
                                  end
                              end
                                0x96: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xa6: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xb6: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': BYTE,
                         'register': REG_A,
                         'write_to_memory': nil},
                     end
                 end
                  'LDB': {'needs_ea': false,
                         'ops': {0xc6: {'addr_mode': IMMEDIATE,
                                      'bytes': 2,
                                      'cycles': 2},
                                  end
                              end
                                0xd6: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xe6: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xf6: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': BYTE,
                         'register': REG_B,
                         'write_to_memory': nil},
                     end
                 end
                  'LDD': {'needs_ea': false,
                         'ops': {0xcc: {'addr_mode': IMMEDIATE_WORD,
                                      'bytes': 3,
                                      'cycles': 3},
                                  end
                              end
                                0xdc: {'addr_mode': DIRECT_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xec: {'addr_mode': INDEXED_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xfc: {'addr_mode': EXTENDED_WORD,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': WORD,
                         'register': REG_D,
                         'write_to_memory': nil},
                     end
                 end
                  'LDS': {'needs_ea': false,
                         'ops': {0x10ce: {'addr_mode': IMMEDIATE_WORD,
                                        'bytes': 4,
                                        'cycles': 4},
                                    end
                                end
                                0x10de: {'addr_mode': DIRECT_WORD,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10ee: {'addr_mode': INDEXED_WORD,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10fe: {'addr_mode': EXTENDED_WORD,
                                        'bytes': 4,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                         'read_from_memory': WORD,
                         'register': REG_S,
                         'write_to_memory': nil},
                     end
                 end
                  'LDU': {'needs_ea': false,
                         'ops': {0xce: {'addr_mode': IMMEDIATE_WORD,
                                      'bytes': 3,
                                      'cycles': 3},
                                  end
                              end
                                0xde: {'addr_mode': DIRECT_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xee: {'addr_mode': INDEXED_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xfe: {'addr_mode': EXTENDED_WORD,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': WORD,
                         'register': REG_U,
                         'write_to_memory': nil},
                     end
                 end
                  'LDX': {'needs_ea': false,
                         'ops': {0x8e: {'addr_mode': IMMEDIATE_WORD,
                                      'bytes': 3,
                                      'cycles': 3},
                                  end
                              end
                                0x9e: {'addr_mode': DIRECT_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xae: {'addr_mode': INDEXED_WORD,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xbe: {'addr_mode': EXTENDED_WORD,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': WORD,
                         'register': REG_X,
                         'write_to_memory': nil},
                     end
                 end
                  'LDY': {'needs_ea': false,
                         'ops': {0x108e: {'addr_mode': IMMEDIATE_WORD,
                                        'bytes': 4,
                                        'cycles': 4},
                                    end
                                end
                                0x109e: {'addr_mode': DIRECT_WORD,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10ae: {'addr_mode': INDEXED_WORD,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10be: {'addr_mode': EXTENDED_WORD,
                                        'bytes': 4,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                         'read_from_memory': WORD,
                         'register': REG_Y,
                         'write_to_memory': nil}}},
                     end
                 end
             end
         end
     end
 end
end
'LEA': {'mnemonic': {'LEAS': {'needs_ea': true,
                           'ops': {0x32: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_S,
                           'write_to_memory': nil},
                       end
                   end
                   'LEAU': {'needs_ea': true,
                           'ops': {0x33: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_U,
                           'write_to_memory': nil},
                       end
                   end
                   'LEAX': {'needs_ea': true,
                           'ops': {0x30: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_X,
                           'write_to_memory': nil},
                       end
                   end
                   'LEAY': {'needs_ea': true,
                           'ops': {0x31: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_Y,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'LSL': {'mnemonic': {'LSL': {'needs_ea': true,
                          'ops': {0x08: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x68: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x78: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'LSLA': {'needs_ea': false,
                           'ops': {0x48: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'LSLB': {'needs_ea': false,
                           'ops': {0x58: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'LSR': {'mnemonic': {'LSR': {'needs_ea': true,
                          'ops': {0x04: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x64: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x74: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'LSRA': {'needs_ea': false,
                           'ops': {0x44: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'LSRB': {'needs_ea': false,
                           'ops': {0x54: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'MUL': {'mnemonic': {'MUL': {'needs_ea': false,
                          'ops': {0x3d: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 11}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'NEG': {'mnemonic': {'NEG': {'needs_ea': true,
                          'ops': {0x00: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x60: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x70: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'NEGA': {'needs_ea': false,
                           'ops': {0x40: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'NEGB': {'needs_ea': false,
                           'ops': {0x50: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'NOP': {'mnemonic': {'NOP': {'needs_ea': false,
                          'ops': {0x12: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 2}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'OR': {'mnemonic': {'ORA': {'needs_ea': false,
                         'ops': {0x8a: {'addr_mode': IMMEDIATE,
                                      'bytes': 2,
                                      'cycles': 2},
                                  end
                              end
                                0x9a: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xaa: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xba: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': BYTE,
                         'register': REG_A,
                         'write_to_memory': nil},
                     end
                 end
                  'ORB': {'needs_ea': false,
                         'ops': {0xca: {'addr_mode': IMMEDIATE,
                                      'bytes': 2,
                                      'cycles': 2},
                                  end
                              end
                                0xda: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xea: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xfa: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': BYTE,
                         'register': REG_B,
                         'write_to_memory': nil},
                     end
                 end
                  'ORCC': {'needs_ea': false,
                          'ops': {0x1a: {'addr_mode': IMMEDIATE,
                                       'bytes': 2,
                                       'cycles': 3}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': REG_CC,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'PAGE': {'mnemonic': {'PAGE 1': {'needs_ea': false,
                              'ops': {0x10: {'addr_mode': nil,
                                           'bytes': 1,
                                           'cycles': 1}},
                                       end
                                   end
                               end
                           end
                              'read_from_memory': nil,
                              'register': nil,
                              'write_to_memory': nil},
                          end
                      end
                  end
                    'PAGE 2': {'needs_ea': false,
                              'ops': {0x11: {'addr_mode': nil,
                                           'bytes': 1,
                                           'cycles': 1}},
                                       end
                                   end
                               end
                           end
                              'read_from_memory': nil,
                              'register': nil,
                              'write_to_memory': nil}}},
                          end
                      end
                  end
              end
          end
      end
  end
end
'PSH': {'mnemonic': {'PSHS': {'needs_ea': false,
                           'ops': {0x34: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_S,
                           'write_to_memory': nil},
                       end
                   end
                   'PSHU': {'needs_ea': false,
                           'ops': {0x36: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_U,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'PUL': {'mnemonic': {'PULS': {'needs_ea': false,
                           'ops': {0x35: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_S,
                           'write_to_memory': nil},
                       end
                   end
                   'PULU': {'needs_ea': false,
                           'ops': {0x37: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_U,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'RESET': {'mnemonic': {'RESET': {'needs_ea': false,
                              'ops': {0x3e: {'addr_mode': nil,
                                           'bytes': 1,
                                           'cycles': -1}},
                                       end
                                   end
                               end
                           end
                              'read_from_memory': nil,
                              'register': nil,
                              'write_to_memory': nil}}},
                          end
                      end
                  end
              end
          end
      end
  end
end
'ROL': {'mnemonic': {'ROL': {'needs_ea': true,
                          'ops': {0x09: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x69: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x79: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'ROLA': {'needs_ea': false,
                           'ops': {0x49: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'ROLB': {'needs_ea': false,
                           'ops': {0x59: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'ROR': {'mnemonic': {'ROR': {'needs_ea': true,
                          'ops': {0x06: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x66: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x76: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': BYTE},
                      end
                  end
                   'RORA': {'needs_ea': false,
                           'ops': {0x46: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'RORB': {'needs_ea': false,
                           'ops': {0x56: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'RTI': {'mnemonic': {'RTI': {'needs_ea': false,
                          'ops': {0x3b: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 6}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'RTS': {'mnemonic': {'RTS': {'needs_ea': false,
                          'ops': {0x39: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 5}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'SBC': {'mnemonic': {'SBCA': {'needs_ea': false,
                           'ops': {0x82: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x92: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa2: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb2: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'SBCB': {'needs_ea': false,
                           'ops': {0xc2: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd2: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe2: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf2: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'SEX': {'mnemonic': {'SEX': {'needs_ea': false,
                          'ops': {0x1d: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 2}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'ST': {'mnemonic': {'STA': {'needs_ea': true,
                         'ops': {0x97: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xa7: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xb7: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': nil,
                         'register': REG_A,
                         'write_to_memory': BYTE},
                     end
                 end
                  'STB': {'needs_ea': true,
                         'ops': {0xd7: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xe7: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 4},
                                  end
                              end
                                0xf7: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 5}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': nil,
                         'register': REG_B,
                         'write_to_memory': BYTE},
                     end
                 end
                  'STD': {'needs_ea': true,
                         'ops': {0xdd: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xed: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xfd: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': nil,
                         'register': REG_D,
                         'write_to_memory': WORD},
                     end
                 end
                  'STS': {'needs_ea': true,
                         'ops': {0x10df: {'addr_mode': DIRECT,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10ef: {'addr_mode': INDEXED,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10ff: {'addr_mode': EXTENDED,
                                        'bytes': 4,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                         'read_from_memory': nil,
                         'register': REG_S,
                         'write_to_memory': WORD},
                     end
                 end
                  'STU': {'needs_ea': true,
                         'ops': {0xdf: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xef: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xff: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': nil,
                         'register': REG_U,
                         'write_to_memory': WORD},
                     end
                 end
                  'STX': {'needs_ea': true,
                         'ops': {0x9f: {'addr_mode': DIRECT,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xaf: {'addr_mode': INDEXED,
                                      'bytes': 2,
                                      'cycles': 5},
                                  end
                              end
                                0xbf: {'addr_mode': EXTENDED,
                                      'bytes': 3,
                                      'cycles': 6}},
                                  end
                              end
                          end
                      end
                         'read_from_memory': nil,
                         'register': REG_X,
                         'write_to_memory': WORD},
                     end
                 end
                  'STY': {'needs_ea': true,
                         'ops': {0x109f: {'addr_mode': DIRECT,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10af: {'addr_mode': INDEXED,
                                        'bytes': 3,
                                        'cycles': 6},
                                    end
                                end
                                0x10bf: {'addr_mode': EXTENDED,
                                        'bytes': 4,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                         'read_from_memory': nil,
                         'register': REG_Y,
                         'write_to_memory': WORD}}},
                     end
                 end
             end
         end
     end
 end
end
'SUB': {'mnemonic': {'SUBA': {'needs_ea': false,
                           'ops': {0x80: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0x90: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xa0: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xb0: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'SUBB': {'needs_ea': false,
                           'ops': {0xc0: {'addr_mode': IMMEDIATE,
                                        'bytes': 2,
                                        'cycles': 2},
                                    end
                                end
                                  0xd0: {'addr_mode': DIRECT,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xe0: {'addr_mode': INDEXED,
                                        'bytes': 2,
                                        'cycles': 4},
                                    end
                                end
                                  0xf0: {'addr_mode': EXTENDED,
                                        'bytes': 3,
                                        'cycles': 5}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': BYTE,
                           'register': REG_B,
                           'write_to_memory': nil},
                       end
                   end
                   'SUBD': {'needs_ea': false,
                           'ops': {0x83: {'addr_mode': IMMEDIATE_WORD,
                                        'bytes': 3,
                                        'cycles': 4},
                                    end
                                end
                                  0x93: {'addr_mode': DIRECT_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xa3: {'addr_mode': INDEXED_WORD,
                                        'bytes': 2,
                                        'cycles': 6},
                                    end
                                end
                                  0xb3: {'addr_mode': EXTENDED_WORD,
                                        'bytes': 3,
                                        'cycles': 7}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': WORD,
                           'register': REG_D,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'SWI': {'mnemonic': {'SWI': {'needs_ea': false,
                          'ops': {0x3f: {'addr_mode': INHERENT,
                                       'bytes': 1,
                                       'cycles': 19}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': nil,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'SWI2': {'needs_ea': false,
                           'ops': {0x103f: {'addr_mode': INHERENT,
                                          'bytes': 2,
                                          'cycles': 20}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil},
                       end
                   end
                   'SWI3': {'needs_ea': false,
                           'ops': {0x113f: {'addr_mode': INHERENT,
                                          'bytes': 2,
                                          'cycles': 20}},
                                      end
                                  end
                              end
                          end
                           'read_from_memory': nil,
                           'register': nil,
                           'write_to_memory': nil}}},
                       end
                   end
               end
           end
       end
   end
end
'SYNC': {'mnemonic': {'SYNC': {'needs_ea': false,
                            'ops': {0x13: {'addr_mode': INHERENT,
                                         'bytes': 1,
                                         'cycles': 2}},
                                     end
                                 end
                             end
                         end
                            'read_from_memory': nil,
                            'register': nil,
                            'write_to_memory': nil}}},
                        end
                    end
                end
            end
        end
    end
end
'TFR': {'mnemonic': {'TFR': {'needs_ea': false,
                          'ops': {0x1f: {'addr_mode': IMMEDIATE,
                                       'bytes': 2,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': nil}}},
                      end
                  end
              end
          end
      end
  end
end
'TST': {'mnemonic': {'TST': {'needs_ea': false,
                          'ops': {0x0d: {'addr_mode': DIRECT,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x6d: {'addr_mode': INDEXED,
                                       'bytes': 2,
                                       'cycles': 6},
                                   end
                               end
                                 0x7d: {'addr_mode': EXTENDED,
                                       'bytes': 3,
                                       'cycles': 7}},
                                   end
                               end
                           end
                       end
                          'read_from_memory': BYTE,
                          'register': nil,
                          'write_to_memory': nil},
                      end
                  end
                   'TSTA': {'needs_ea': false,
                           'ops': {0x4d: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_A,
                           'write_to_memory': nil},
                       end
                   end
                   'TSTB': {'needs_ea': false,
                           'ops': {0x5d: {'addr_mode': INHERENT,
                                        'bytes': 1,
                                        'cycles': 2}},
                                    end
                                end
                            end
                        end
                           'read_from_memory': nil,
                           'register': REG_B,
                           'write_to_memory': nil}}}}
                       end
                   end
               end
           end
       end
   end
end
