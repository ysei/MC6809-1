#!/usr/bin/env python
# coding: utf-8

# copy&paste .lst content from e.g.: http://www.asm80.com/
lst = """
0000   D6 4F                  LDB   $4f
0002   F7 10 4F               STB   $104f
0005   D6 50                  LDB   $50
0007   F7 10 50               STB   $1050
000A   D6 51                  LDB   $51
000C   F7 10 51               STB   $1051
000F   D6 52                  LDB   $52
0011   F7 10 52               STB   $1052
0014   D6 53                  LDB   $53
0016   F7 10 53               STB   $1053
0019   D6 54                  LDB   $54
001B   F7 10 54               STB   $1054
"""

lines = []
for line in lst.strip().splitlines()
    address = line[:4]
    
    hex_list = line[7:30]
    lable = ""
    if ":" in hex_list
        hex_list = hex_list.strip()
        begin
            hex_list, lable = hex_list.strip().rsplit(" ", 1)
        except ValueError
            lable = hex_list
            hex_list = ""
        else
            lable = lable.strip()
        end
    end
    
    hex_list = hex_list.strip().split(" ")
    hex_list = [i, 16.to_i for i in hex_list if i]
    
    code1 = line[30:].strip()
    doc = ""
    if ";" in code1
        code1, doc = code1.split(";", 1)
        code1 = code1.strip()
    end
    
    code2 = ""
    if " " in code1
        code1, code2 = code1.split(" ", 1)
        code1 = code1.strip()
        code2 = code2.strip()
    end
    
    # for BASIC
    lines.append({
        "hex_list":hex_list,
        "address":address,
        "lable":lable,
        "code1":code1,
        "code2":code2,
        "doc":doc,
    end
    })
end




def print_unittest1 (lines)
    print("        cpu_test_run(start=0x0100, end_=nil, mem=[")
    for line in lines
        hex_list = line["hex_list"]
        address = line["address"]
        lable = line["lable"]
        code1 = line["code1"]
        code2 = line["code2"]
        doc = line["doc"]
        
        hex_list = ", ".join(["0x%02x" % i for i in hex_list])
        if hex_list
            hex_list += ", #"
        else
            hex_list += "#"
        end
        
        line = sprintf("            %-20s %s|%6s %-5s %-8s", 
            hex_list, address, lable, code1, code2
        end
        )
        if doc
            line = sprintf("%40s ; %s", line, doc)
        end
        print(line.rstrip())
    end
    print("        ])")
end


def print_unittest2 (lines)
    print("        cpu_test_run(start=0x0100, end_=nil, mem=[")
    for line in lines
        hex_list = line["hex_list"]
        address = line["address"]
        lable = line["lable"]
        code1 = line["code1"]
        code2 = line["code2"]
        doc = line["doc"]
        
        hex_list = ", ".join(["0x%02x" % i for i in hex_list])
        if hex_list
            hex_list += ", #"
        else
            hex_list += "#"
        end
        
        line = sprintf("            %-20s %6s %-5s %-8s", 
            hex_list, lable, code1, code2
        end
        )
        if doc
            line = sprintf("%40s ; %s", line, doc)
        end
        print(line.rstrip())
    end
    print("        ])")
end


def print_bas (lines, line_no)
    for line in lines
        hex_list = line["hex_list"]
        address = line["address"]
        lable = line["lable"]
        code1 = line["code1"]
        code2 = line["code2"]
        doc = line["doc"]
        
        line = sprintf("%s ' %s %s", 
            line_no, code1, code2
        end
        )
        if doc
            line = sprintf("%-20s ; %s", line, doc)
        end
        print(line.upper())
        line_no += 10
        
        line = sprintf("%s DATA %s", 
            line_no,
            ",".join(["%x" % i for i in hex_list])
        end
        )
        print(line.upper())
        line_no += 10
    end
end


print("-"*79)

print_unittest1(lines) # with address

print("-"*79)

print_unittest2(lines) # without address

print("-"*79)

# for a basic file
print_bas(lines,
    line_no=1050
end
)
