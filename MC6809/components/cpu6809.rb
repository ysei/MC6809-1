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

require sys
from MC6809.components.mc6809_cc_register import CPUConditionCodeRegisterMixin
from MC6809.components.mc6809_speedlimited import CPUSpeedLimitMixin

if sys.version_info[0] == 3
    # Python 3
    pass
else
    # Python 2
    range = xrange
end

require logging

from MC6809.core.cpu_control_server import CPUControlServerMixin
from MC6809.components.mc6809_interrupt import InterruptMixin
from MC6809.components.mc6809_addressing import AddressingMixin
from MC6809.components.mc6809_stack import StackMixin
from MC6809.components.mc6809_ops_load_store import OpsLoadStoreMixin
from MC6809.components.mc6809_ops_branches import OpsBranchesMixin
from MC6809.components.mc6809_ops_logic import OpsLogicalMixin
from MC6809.components.mc6809_ops_test import OpsTestMixin
from MC6809.components.mc6809_base import CPUBase
from MC6809.components.mc6809_tools import CPUThreadedStatusMixin, CPUTypeAssertMixin

log = logging.getLogger("MC6809")


# HTML_TRACE = true
HTML_TRACE = false


class CPU(CPUBase, AddressingMixin, StackMixin, InterruptMixin, OpsLoadStoreMixin, OpsBranchesMixin,
    OpsTestMixin, OpsLogicalMixin, CPUConditionCodeRegisterMixin, CPUThreadedStatusMixin)
    
    def to_speed_limit
        return change_cpu(self, CPUSpeedLimit)
    end
end


class CPUSpeedLimit(CPUSpeedLimitMixin, CPU)
    
    def to_normal
        return change_cpu(self, CPU)
    end
end


class CPUTypeAssert(CPUTypeAssertMixin, CPU)
    pass
end


class CPUControlServer(CPUControlServerMixin, CPU)
    pass
end


def change_cpu (old_cpu, NewCPU)
    old_cpu.running = false
    cpu_state = old_cpu.get_state()
    
    new_cpu = NewCPU.new(memory=old_cpu.memory, cfg=old_cpu.cfg)
    new_cpu.set_state(cpu_state)
    
    log.critical("Change CPU from %r to %r",
        old_cpu.__class__.__name__,
        new_cpu.__class__.__name__
    end
    )
    
    return new_cpu
end
