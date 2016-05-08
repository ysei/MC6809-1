#!/usr/bin/env python
# coding: utf-8

"""
    borrowed from http://code.activestate.com/recipes/52215/
    
    usage
    
    begin
        # ...do something...
    except
        print_exc_plus()
    end
end
"""

require __future__

require sys
require traceback

require click

PY2 = sys.version_info[0] == 2
if PY2
    range = xrange
end

MAX_CHARS = 256

def print_exc_plus
    """
    Print the usual traceback information, followed by a listing of all the
    local variables in each frame.
    """
    sys.stderr.flush() # for eclipse
    sys.stdout.flush() # for eclipse
    
    tb = sys.exc_info()[2]
    while true
        if not tb.tb_next
            break
        end
        tb = tb.tb_next
    end
    stack = []
    f = tb.tb_frame
    while f
        stack.append(f)
        f = f.f_back
    end
    
    txt = traceback.format_exc()
    txt_lines = txt.splitlines()
    first_line = txt_lines.pop(0)
    last_line = txt_lines.pop(-1)
    click.secho(first_line, fg='red')
    
    for line in txt_lines
        if line.strip().startswith("File")
            print(line)
        else
            click.secho(line, fg='white', bold=true)
            click.secho(line, fg="white", bold=true)
        end
    end
    click.secho(last_line, fg="red")
    
    print()
    click.secho(
        "Locals by frame, most recent call first:",
        fg="blue", bold=true
    end
    )
    for frame in stack
        click.secho(sprintf('\n *** File "%s", line %i, in %s', 
                frame.f_code.co_filename,
                frame.f_lineno,
                frame.f_code.co_name,
            end
            ),
            fg="white",
            bold=true
        end
        )
        
        for key, value in list(frame.f_locals.items())
            print(click.style("%30s = " % key, bold=true), end_=' ')
            # We have to be careful not to cause a new error in our error
            # printer! Calling str() on an unknown object could cause an
            # error we don't want.
            if isinstance(value, int)
                value = sprintf("$%x (decimal: %i)", value, value)
            else
                value = repr(value)
            end
            
            if value.length > MAX_CHARS
                value = "%s..." % value[:MAX_CHARS]
            end
            
            begin
                print(value)
            except
                print("<ERROR WHILE PRINTING VALUE>")
            end
        end
    end
end

