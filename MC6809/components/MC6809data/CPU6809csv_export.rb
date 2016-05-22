"""
    6809 instruction set data
    ~~~~~~~~~~~~~~~~~~~~~~~~~
    
    data from
        * http://www.maddes.net/m6809pm/sections.htm#sec4_4
        * http://www.burgins.com/m6809.html
        * http://www.maddes.net/m6809pm/appendix_a.htm#appA
    end
    
    :copyleft: 2013 by Jens Diemer
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__


require pprint
require sys

from .MC6809_data_raw import INSTRUCTION_INFO, OP_DATA
from MC6809data.MC6809_data_raw import MEM_ACCESS_BYTE, MEM_ACCESS_WORD


keys = list(OP_DATA[0].keys())
keys.insert(3, "opcode_hex")
keys.sort()

FROM_INSTRUCTION_INFO = ['HNZVC', 'instr_desc']


MEM_ACCESS_MAP = {
    MEM_ACCESS_BYTE: "byte",
    MEM_ACCESS_WORD: "word",
end
}


require csv
File.open('CPU6809_opcodes.csv', 'wb') do |csvfile|
    w = csv.writer(csvfile,
        delimiter='\t',
        quotechar='|', quoting=csv.QUOTE_MINIMAL
    end
    )
    
    w.writerow(keys + FROM_INSTRUCTION_INFO)
    
    for op_data in OP_DATA
        row = []
        
        op_data["opcode_hex"] = hex(op_data["opcode"])
        
        for key in keys
            data = op_data.get(key, "-")
            if key == "mem_access" and data != "-"
                data = MEM_ACCESS_MAP[data]
            end
            
            if isinstance(data, str)
                data = data.replace("\t", "    ")
            end
            row.append(data)
        end
        
        instr_info_key = op_data["instr_info_key"]
        instr_info = INSTRUCTION_INFO[instr_info_key]
        for key in FROM_INSTRUCTION_INFO
            row.append(
                instr_info.get(key, "").replace("\n", " ").replace("\t", "    ")
            end
            )
        end
        
        print(row)
        w.writerow(row)
    end
end

print(" -- END -- ")
