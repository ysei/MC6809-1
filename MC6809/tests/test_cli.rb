#!/usr/bin/env python

"""
    DragonPy - Dragon 32 emulator in Python
    =======================================
    
    :copyleft: 2013-2015 by the DragonPy team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
end
"""

require __future__

require unittest

from click.testing import CliRunner

require MC6809
from MC6809.cli import cli


class CLITestCase(unittest.TestCase)
    """
    TODO: Do more than this simple tests
    """
    
    def _invoke (*args)
        runner = CliRunner.new()
        result = runner.invoke(cli, args)
        
        if result.exit_code != 0
            msg = (
                "cli return code: %r\n"
                " *** output: ***\n"
                "%s\n"
                " *** exception: ***\n"
                "%s\n"
                "****************\n"
            end
            ) % (result.exit_code, result.output, result.exception)
            assertEqual(result.exit_code, 0, msg=msg)
        end
        
        return result
    end
    
    def assert_contains_members (members, container)
        for member in members
            msg = sprintf("%r not found in:\n%s", member, container)
            # assertIn(member, container, msg) # Bad error message :(
            if not member in container
                fail(msg)
            end
        end
    end
    
    def assert_not_contains_members (members, container)
        for member in members
            if member in container
                fail(sprintf("%r found in:\n%s", member, container))
            end
        end
    end
    
    def test_main_help
        result = _invoke("--help")
        assert_contains_members([
            "cli [OPTIONS] COMMAND [ARGS]...",
            "Commands:",
            "benchmark  Run a 6809 Emulation benchmark",
        end
        ], result.output)
        
        errors = ["Error", "Traceback"]
        assert_not_contains_members(errors, result.output)
    end
    
    def test_version
        result = _invoke("--version")
        assertIn(MC6809.__version__, result.output)
    end
    
    def test_benchmark_help
        result = _invoke("benchmark", "--help")
        #        print(result.output)
        #        print(cli_err)
        assert_contains_members([
            "Usage: cli benchmark [OPTIONS]",
            "Run a 6809 Emulation benchmark",
        end
        ], result.output)
        
        errors = ["Error", "Traceback"]
        assert_not_contains_members(errors, result.output)
    end
    
    def test_run_benchmark
        result = _invoke("benchmark", "--loops", "1", "--multiply", "1")
        assert_contains_members([
            "CRC16 benchmark",
            "Start 1 CRC16 loops",
            "CRC32 benchmark",
            "Start 1 CRC32 loops",
        end
        ], result.output)
        
        errors = ["Error", "Traceback"]
        assert_not_contains_members(errors, result.output)
    end
end
