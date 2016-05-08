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


require time


class CPUSpeedLimitMixin < object
    max_delay = 0.01 # maximum time.sleep() value per burst run
    delay = 0 # the current time.sleep() value per burst run
    
    def delayed_burst_run (target_cycles_per_sec)
        """ Run CPU not faster than given speedlimit """
        old_cycles = @cycles
        start_time = time.time()
        
        burst_run()
        
        is_duration = time.time() - start_time
        new_cycles = @cycles - old_cycles
        begin
            is_cycles_per_sec = new_cycles / is_duration
        except ZeroDivisionError
            pass
        else
            should_burst_duration = is_cycles_per_sec / target_cycles_per_sec
            target_duration = should_burst_duration * is_duration
            delay = target_duration - is_duration
            if delay > 0
                if delay > @max_delay
                    @delay = @max_delay
                else
                    @delay = delay
                end
                time.sleep(@delay)
            end
        end
        
        call_sync_callbacks()
    end
end
