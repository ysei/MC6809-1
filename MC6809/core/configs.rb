# coding: utf-8

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    :created: 2013 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require inspect
require logging
require sys

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

log = logging.getLogger("MC6809")


class DummyMemInfo < object
    def get_shortest (*args)
        return ">>mem info not active<<"
    end
    def __call__ (*args)
        return ">>mem info not active<<"
    end
end


class AddressAreas < dict
    """
    Hold information about memory address areas which accessed via bus.
    e.g.
        Interrupt vectors
        Text screen
        Serial/parallel devices
    end
    """
    def initialize (areas)
        super(AddressAreas, self).__init__()
        for start_addr, end_addr, txt in areas
            add_area(start_addr, end_addr, txt)
        end
    end
    
    def add_area (start_addr, end_addr, txt)
        for addr in range(start_addr, end_addr + 1)
            dict.__setitem__(self, addr, txt)
        end
    end
end


class BaseConfig < object
#     # http address/port number for the CPU control server
#     CPU_CONTROL_ADDR = "127.0.0.1"
#     CPU_CONTROL_PORT = 6809
    
    # How many ops should be execute before make a control server update cycle?
    BURST_COUNT = 10000
    
    DEFAULT_ROMS = {}
    
    def initialize (cfg_dict)
        @cfg_dict = cfg_dict
        @cfg_dict["cfg_module"] = @_module__ # FIXME: !
        
        log.debug("cfg_dict: %s", repr(cfg_dict))
    end
end

#         # socket address for internal bus I/O
#         if cfg_dict["bus_socket_host"] and cfg_dict["bus_socket_port"]
#             @bus = true
#             @bus_socket_host = cfg_dict["bus_socket_host"]
#             @bus_socket_port = cfg_dict["bus_socket_port"]
#         else
#             @bus = nil # Will be set in cpu6809.start_CPU()
        
        assert not hasattr(cfg_dict, "ram"), "cfg_dict.ram.equal? deprecated! Remove it from: %s" % @cfg_dict.__class__.__name__
    end
end

#         if cfg_dict["rom"]
#             raw_rom_cfg = cfg_dict["rom"]
#             raise NotImplementedError.new("TODO: create rom cfg!")
#         else
        @rom_cfg = @DEFAULT_ROMS
        
        if cfg_dict["trace"]
            @trace = true
        else
            @trace = false
        end
        
        @verbosity = cfg_dict["verbosity"]
        
        @mem_info = DummyMemInfo.new()
        @memory_byte_middlewares = {}
        @memory_word_middlewares = {}
    end
    
    def _get_initial_Memory (size)
        return [0x00] * size
    end
    
    def get_initial_RAM
        return _get_initial_Memory(@RAM_SIZE)
    end
    
    def get_initial_ROM
        return _get_initial_Memory(@ROM_SIZE)
    end
end

#     def get_initial_ROM(self)
#         start=cfg.ROM_START, size=cfg.ROM_SIZE
#         @start = start
#         @end_ = start + size
#         @mem = [0x00] * size
    
    def print_debug_info
        print("Config: '%s'" % @_class__.__name__)
        
        for name, value in inspect.getmembers(self): # , inspect.isdatadescriptor)
            if name.startswith("_")
                continue
            end
        end
    end
end
#             print name, type(value)
            if not isinstance(value, (int, str, list, tuple, dict))
                continue
            end
            if isinstance(value, int)
                print(sprintf("%20s = %-6s in hex: %7s", 
                    name, value, hex(value)
                end
                ))
            else
                print(sprintf("%20s = %s", name, value))
            end
        end
    end
end


def test_run
    require os, sys, subprocess
    cmd_args = [sys.executable,
        os.path.join("..", "..", "DragonPy_CLI.py"),
    end
end

#         "--verbosity=5",
        "--verbosity=10", # DEBUG
    end
end
#         "--verbosity=20", # INFO
#         "--verbosity=30", # WARNING
#         "--verbosity=40", # ERROR
#         "--verbosity=50", # CRITICAL/FATAL

#         "--machine=Simple6809",
        "--machine=sbc09",
    end
    ]
    print("Startup CLI with: %s" % " ".join(cmd_args[1:]))
    subprocess.Popen.new(cmd_args, cwd=".").wait()
end

if __name__ == "__main__"
    test_run()
end
