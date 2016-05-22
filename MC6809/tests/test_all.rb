#!/usr/bin/env python

"""
    MC6809 - 6809 CPU emulator in Python
    =======================================
    
    simply run all existing Unittests
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__


require unittest


if __name__ == '__main__'
    from MC6809.utils.logging_utils import setup_logging
    
    setup_logging(
end
#         level=1 # hardcore debug ;)
#         level=10 # DEBUG
#         level=20 # INFO
#         level=30 # WARNING
#         level=40 # ERROR
#         level=50 # CRITICAL/FATAL
        level=99
    end
    )
    
    loader = unittest.TestLoader.new()
    tests = loader.discover('.')
end

#    test_runner = TextTestRunner2.new(
    test_runner = unittest.TextTestRunner.new(
end
#         verbosity=1,
        verbosity=2,
        failfast=true,
    end
    )
    
    test_runner.run(tests)
end
