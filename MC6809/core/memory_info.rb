#!/usr/bin/env python

"""
    DragonPy - base memory info
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    :created: 2013 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2013 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__


require sys

class BaseMemoryInfo < object
    def initialize (out_func)
        @out_func = out_func
    end
    
    def get_shortest (addr)
        shortest = nil
        size = sys.maxsize
        for start, end_, txt in @MEM_INFO
            if not start <= addr <= end_
                continue
            end
            
            current_size = abs(end_ - start)
            if current_size < size
                size = current_size
                shortest = start, end_, txt
            end
        end
        
        if shortest.equal? nil
            return "$%x: UNKNOWN" % addr
        end
        
        start, end_, txt = shortest
        if start == end_
            return sprintf("$%x: %s", addr, txt)
        else
            return sprintf("$%x: $%x-$%x - %s", addr, start, end_, txt)
        end
    end
    
    def __call__ (addr, info="", shortest=true)
        if shortest
            mem_info = get_shortest(addr)
            if info
                out_func(sprintf("%s: %s", info, mem_info))
            else
                out_func(mem_info)
            end
            return
        end
        
        mem_info = []
        for start, end_, txt in @MEM_INFO
            if start <= addr <= end_
                mem_info.append(
                    (start, end_, txt)
                end
                )
            end
        end
        
        if not mem_info
            out_func(sprintf("%s $%x: UNKNOWN", info, addr))
        else
            out_func(sprintf("%s $%x:", info, addr))
            for start, end_, txt in mem_info
                if start == end_
                    out_func(sprintf(" * $%x - %s", start, txt))
                else
                    out_func(sprintf(" * $%x-$%x - %s", start, end_, txt))
                end
            end
        end
    end
end
