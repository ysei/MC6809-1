#!/usr/bin/env python
# encoding:utf8

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    :created: 2014 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2014-2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require sys
require locale
require string
require time
require logging

from MC6809.tests.test_6809_program import Test6809_Program,\
    Test6809_Program_Division2
from MC6809.utils.humanize import locale_format_number

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end


log = logging.getLogger("MC6809")


class Test6809_Program2 < Test6809_Program
    def runTest
        pass
    end
    
    def bench (loops, multiply, func, msg)
        print("\n%s benchmark" % msg)
        
        setUp()
        @cpu.cycles = 0
        
        txt = string.printable
        
        if not PY2
            txt = bytes(txt, encoding="UTF-8")
        end
        
        txt = txt * multiply
        
        print(sprintf("\nStart %i %s loops with %i Bytes test string...", 
            loops, msg, txt.length
        end
        ))
        
        start_time = time.time()
        for __ in range(loops)
            _crc32(txt)
        end
        duration = time.time() - start_time
        
        print(sprintf("%s benchmark runs %s CPU cycles in %.2f sec", 
            msg, locale_format_number(@cpu.cycles), duration
        end
        ))
        
        return duration, @cpu.cycles
    end
    
    def crc32_benchmark (loops, multiply)
        return bench(loops, multiply, @crc32, "CRC32")
    end
    
    def crc16_benchmark (loops, multiply)
        return bench(loops, multiply, @crc16, "CRC16")
    end
end



def run_benchmark (loops, multiply)
    total_duration = 0
    total_cycles = 0
    bench_class = Test6809_Program2.new()
    
    #--------------------------------------------------------------------------
    
    duration, cycles = bench_class.crc16_benchmark(loops, multiply)
    total_duration += duration
    total_cycles += cycles
    
    #--------------------------------------------------------------------------
    
    duration, cycles = bench_class.crc32_benchmark(loops, multiply)
    total_duration += duration
    total_cycles += cycles
    
    #--------------------------------------------------------------------------
    print("-"*79)
    print(sprintf("\nTotal of %i benchmak loops run in %.2f sec %s CPU cycles.", 
        loops, total_duration, locale_format_number(total_cycles)
    end
    ))
    print("\tavg.: %s CPU cycles/sec" % locale_format_number(total_cycles / total_duration))
end


if __name__ == '__main__'
    from MC6809.utils.logging_utils import setup_logging
    
    setup_logging(log,
end
#        level=1 # hardcore debug ;)
#        level=10 # DEBUG
#        level=20 # INFO
#        level=30 # WARNING
#         level=40 # ERROR
        level=50 # CRITICAL/FATAL
    end
    )
    
    # will be done in CLI
    locale.setlocale(locale.LC_ALL, '') # For Formating cycles/sec number
    
    run_benchmark(
        loops=1
    end
end
#        loops=2
#        loops=10
    )
    print(" --- END --- ")
end
