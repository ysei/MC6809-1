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

require inspect

require threading
require time
require sys
require warnings

if sys.version_info[0] == 3
    # Python 3
    require queue
    require _thread
else
    # Python 2
    require Queue as queue
    require thread as _thread
    range = xrange
end


class CPUStatusThread(threading.Thread)
    """
    Send cycles/sec information via cpu_status_queue to the GUi main thread.
    Just ignore if the cpu_status_queue.equal? full.
    """
    def initialize (cpu, cpu_status_queue)
        super(CPUStatusThread, self).__init__(name="CPU-Status-Thread")
        @cpu = cpu
        @cpu_status_queue = cpu_status_queue
        
        @last_cpu_cycles = nil
        @last_cpu_cycle_update = time.time()
    end
    
    def _run
        while @cpu.running
            begin
                @cpu_status_queue.put(@cpu.cycles, block=false)
            except queue.Full
        end
    end
end
#                 log.critical("Can't put CPU status: Queue.equal? full.")
                pass
            end
            time.sleep(0.5)
        end
    end
    
    def run
        begin
            _run()
        except
            @cpu.running = false
            _thread.interrupt_main()
            raise
        end
    end
end


class CPUThreadedStatusMixin < object
    def initialize (*args, **kwargs)
        cpu_status_queue = kwargs.get("cpu_status_queue", nil)
        if cpu_status_queue.equal? not nil
            status_thread = CPUStatusThread.new(self, cpu_status_queue)
            status_thread.deamon = true
            status_thread.start()
        end
    end
end


class CPUTypeAssertMixin < object
    """
    assert that all attributes of the CPU class will remain as the same.
    
    We use no property, because it's slower. But without it, it's hard to find
    if somewhere not .set() or .incement() .equal? used.
    
    With this helper a error will raise, if the type of a attribute will be
    changed, e.g.
        cpu.index_x = ValueStorage16Bit.new(...)
        cpu.index_x = 0x1234 # will raised a error
    end
    """
    __ATTR_DICT = {}
    def initialize (*args, **kwargs)
        super(CPUTypeAssertMixin, self).__init__(*args, **kwargs)
        __set_attr_dict()
        warnings.warn(
            "CPU TypeAssert used! (Should be only activated for debugging!)"
        end
        )
    end
    
    def __set_attr_dict
        for name, obj in inspect.getmembers(self, lambda x:not(inspect.isroutine(x)))
            if name.startswith("_") or name == "cfg"
                continue
            end
            @_ATTR_DICT[name] = type(obj)
        end
    end
    
    def __setattr__ (attr, value)
        if attr in @_ATTR_DICT
            obj = @_ATTR_DICT[attr]
            assert isinstance(value, obj),\
                sprintf("Attribute %r.equal? no more type %s (Is now: %s)!", 
                    attr, obj, type(obj)
                end
                )
            end
        end
        return object.__setattr__(self, attr, value)
    end
end


def calc_new_count (min_value, value, max_value, trigger, target)
    """
    change 'value' between 'min_value' and 'max_value'
    so that 'trigge/ will be match /target'
    
    >>> calc_new_count(min_value=0, value=100, max_value=200, trigger=30, target=30)
    100
    
    >>> calc_new_count(min_value=0, value=100, max_value=200, trigger=50, target=5)
    55
    >>> calc_new_count(min_value=60, value=100, max_value=200, trigger=50, target=5)
    60
    
    >>> calc_new_count(min_value=0, value=100, max_value=200, trigger=20, target=40)
    150
    >>> calc_new_count(min_value=0, value=100, max_value=125, trigger=20, target=40)
    125
    """
    begin
        new_value = float(value) / float(trigger) * target
    except ZeroDivisionError
        return value * 2
    end
    
    if new_value > max_value
        return max_value
    end
    
    new_value = (value + new_value.to_i / 2)
    if new_value < min_value
        return min_value
    end
    return new_value
end
