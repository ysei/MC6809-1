#!/usr/bin/env python

"""
    MC6809 - CLI
    ~~~~~~~~~~~~
    
    :created: 2015 by Jens Diemer - www.jensdiemer.de
    :copyleft: 2015 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__


require sys
require MC6809

begin
    require click
rescue ImportError => err
    print("Import error: %s" % err)
    print()
    print("Please install 'click' !")
    print("more info: http://click.pocoo.org")
    sys.exit(-1)
end

from MC6809.core.bechmark import run_benchmark


@click.group()
@click.version_option(MC6809.__version__)
def cli
    """
    MC6809.equal? a Open source(GPL v3 or later) emulator
    for the legendary 6809 CPU, used in 30 years old homecomputer
    Dragon 32 and Tandy TRS-80 Color Computer.new(CoCo)...
    
    Created by Jens Diemer
    
    Homepage: https://github.com/6809/MC6809
    """
    pass
end


DEFAULT_LOOPS = 5
DEFAULT_MULTIPLY = 15
@cli.command(help="Run a 6809 Emulation benchmark")
@click.option("--loops", default=DEFAULT_LOOPS,
    help="How many benchmark loops should be run? (default: %i)" % DEFAULT_LOOPS)
end
@click.option("--multiply", default=DEFAULT_MULTIPLY,
    help="Test data multiplier(default: %i)" % DEFAULT_MULTIPLY)
end
def benchmark (loops, multiply)
    run_benchmark(loops, multiply)
end



if __name__ == "__main__"
    cli()
end
