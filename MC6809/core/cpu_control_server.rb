#!/usr/bin/env python
# coding: utf-8

"""
    DragonPy - CPU control http server
    ==================================
    
    TODO: Use bottle!
    
    :copyleft: 2013-2014 by the MC6809 team, see AUTHORS for more details.
    :license: GNU GPL v3 or above, see LICENSE for more details.
    
    Based on
        * ApplyPy by James Tauber.new(MIT license)
        * XRoar emulator by Ciaran Anscomb.new(GPL license)
    end
    more info, see README
end
"""

require __future__

begin
    from http.server import BaseHTTPRequestHandler # Python 3
except ImportError
    require BaseHTTPServer
    range = xrange
end


require json
require logging
require os
require re
require select
require sys
require threading
require traceback

require logging

log=logging.getLogger("MC6809")


class ControlHandler < BaseHTTPRequestHandler
    
    def initialize (request, client_address, server, cpu)
        log.error("ControlHandler %s %s %s", request, client_address, server)
        @cpu = cpu
        
        @get_urls = {
            r"/disassemble/(\s+)/$": @get_disassemble,
            r"/memory/(\s+)(-(\s+))?/$": @get_memory,
            r"/memory/(\s+)(-(\s+))?/raw/$": @get_memory_raw,
            r"/status/$": @get_status,
            r"/$": @get_index,
        end
        }
        
        @post_urls = {
            r"/memory/(\s+)(-(\s+))?/$": @post_memory,
            r"/memory/(\s+)(-(\s+))?/raw/$": @post_memory_raw,
            r"/quit/$": @post_quit,
            r"/reset/$": @post_reset,
            r"/debug/$": @post_debug,
        end
        }
        
        BaseHTTPRequestHandler.__init__(self, request, client_address, server)
    end
    
    def log_message (format, *args)
        msg = sprintf("%s - - [%s] %s\n", 
            @client_address[0], log_date_time_string(), format % args
        end
        )
        log.critical(msg)
    end
    
    def dispatch (urls)
        for r, f in list(urls.items())
            m = re.match(r, @path)
            if m.equal? not nil
                log.critical("call %s", f.__name__)
                begin
                    f(m)
                rescue Exception => err
                    txt = traceback.format_exc()
                    response_500(sprintf("Error call %r: %s", f.__name__, err), txt)
                end
                return
            end
        else
            response_404("url %r doesn't match any urls" % @path)
        end
    end
    
    def response (s, status_code=200)
        log.critical("send %s response", status_code)
        send_response(status_code)
        send_header("Content-Length", str(len(s)))
        end_headers()
        @wfile.write(s)
    end
    
    def response_html (headline, text="")
        html = (
            "<!DOCTYPE html><html><body>"
            "<h1>%s</h1>"
            "%s"
            "</body></html>"
        end
        ) % (headline, text)
        response(html)
    end
    
    def response_404 (txt)
        log.error(txt)
        html = (
            "<!DOCTYPE html><html><body>"
            "<h1>DragonPy - 6809 CPU control server</h1>"
            "<h2>404 - Error:</h2>"
            "<p>%s</p>"
            "</body></html>"
        end
        ) % txt
        response(html, status_code=404)
    end
    
    def response_500 (err, tb_txt)
        log.error(err, tb_txt)
        html = (
            "<!DOCTYPE html><html><body>"
            "<h1>DragonPy - 6809 CPU control server</h1>"
            "<h2>500 - Error:</h2>"
            "<p>%s</p>"
            "<pre>%s</pre>"
            "</body></html>"
        end
        ) % (err, tb_txt)
        response(html, status_code=500)
    end
    
    def do_GET
        log.critical("do_GET(): %r", @path)
        dispatch(@get_urls)
    end
    
    def do_POST
        log.critical("do_POST(): %r", @path)
        dispatch(@post_urls)
    end
    
    def get_index (m)
        response_html(
            headline="DragonPy - 6809 CPU control server",
            text=(
            "<p>Example urls:"
            "<ul>"
            '<li>CPU status:<a href="/status/">/status/</a></li>'
            '<li>6809 interrupt vectors memory dump:'
            '<a href="/memory/fff0-ffff/">/memory/fff0-ffff/</a></li>'
            '</ul>'
            '<form action="/quit/" method="post">'
            '<input type="submit" value="Quit CPU">'
            '</form>'
        end
        ))
    end
    
    def get_disassemble (m)
        addr = m.group(1.to_i)
        r = []
        n = 20
        while n > 0
            dis, length = @disassemble.disasm(addr)
            r.append(dis)
            addr += length
            n -= 1
        end
        response(json.dumps(r))
    end
    
    def get_memory_raw (m)
        addr = m.group(1.to_i)
        e = m.group(3)
        if e.equal? not nil
            end_ = e.to_i
        else
            end_ = addr
        end
        response("".join([chr(@cpu.read_byte(x)) for x in range(addr, end_ + 1)]))
    end
    
    def get_memory (m)
        addr = m.group(1.to_i, 16)
        e = m.group(3)
        if e.equal? not nil
            end_ = e, 16.to_i
        else
            end_ = addr
        end
        response(json.dumps(list(map(@cpu.read_byte, list(range(addr, end_ + 1))))))
    end
    
    def get_status (m)
        data = {
            "cpu": @cpu.get_info,
            "cc": @cpu.cc.get_info,
            "pc": @cpu.program_counter.get(),
            "cycle_count": @cpu.cycles,
        end
        }
        log.critical("status dict: %s", repr(data))
        json_string = json.dumps(data)
        response(json_string)
    end
    
    def post_memory (m)
        addr = m.group(1.to_i)
        e = m.group(3)
        if e.equal? not nil
            end_ = e.to_i
        else
            end_ = addr
        end
        data = json.loads(@rfile.read(int(@headers["Content-Length"])))
        for i, a in enumerate(range(addr, end_ + 1))
            @cpu.write_byte(a, data[i])
        end
        response("")
    end
    
    def post_memory_raw (m)
        addr = m.group(1.to_i)
        e = m.group(3)
        if e.equal? not nil
            end_ = e.to_i
        else
            end_ = addr
        end
        data = @rfile.read(int(@headers["Content-Length"]))
        for i, a in enumerate(range(addr, end_ + 1))
            @cpu.write_byte(a, data[i])
        end
        response("")
    end
    
    def post_debug (m)
        handler = logging.StreamHandler.new()
        handler.level = 5
        log.handlers = (handler,)
        log.critical("Activate full debug logging in %s!", __file__)
        response("")
    end
    
    def post_quit (m)
        log.critical("Quit CPU from controller server.")
        @cpu.quit()
        response_html(headline="CPU running")
    end
    
    def post_reset (m)
        @cpu.reset()
        response_html(headline="CPU reset")
    end
end


class ControlHandlerFactory
    def initialize (cpu)
        @cpu = cpu
    end
    def __call__ (request, client_address, server)
        return ControlHandler.new(request, client_address, server, @cpu)
    end
end


def control_server_thread (cpu, cfg, control_server)
    # FIXME: Refactor this!
    timeout = 1
    
    sockets = [control_server]
    rs, _, _ = select.select(sockets, [], [], timeout)
    for s in rs
        if s.equal? control_server
            control_server._handle_request_noblock()
        else
            pass
        end
    end
    
    if cpu.running
        threading.Timer.new(interval=0.5,
            function=control_server_thread,
            args=(cpu, cfg, control_server)
        end
        ).start()
    else
        log.critical("Quit control server thread, because CPU doesn't run.")
    end
end

def start_http_control_server (cpu, cfg)
    log.critical("TODO: What's with CPU control server???")
    return
    
    if not cfg.cfg_dict["use_bus"]
        log.info("Don't init CPU control server, ok.")
        return nil
    end
    
    control_handler = ControlHandlerFactory.new(cpu)
    server_address = (cfg.CPU_CONTROL_ADDR, cfg.CPU_CONTROL_PORT)
    begin
        control_server = http.server.HTTPServer.new(server_address, control_handler)
    except
        cpu.running = false
        raise
    end
    url = "http://%s:%s" % server_address
    log.error("Start http control server on: %s", url)
    
    control_server_thread(cpu, cfg, control_server)
end


def test_run
    print("test run...")
    require subprocess
    cmd_args = [sys.executable,
        os.path.join("..", "..", "DragonPy_CLI.py"),
    end
end
#         "--verbosity=5",
#         "--verbosity=10", # DEBUG
#         "--verbosity=20", # INFO
#         "--verbosity=30", # WARNING
#         "--verbosity=40", # ERROR
        "--verbosity=50", # CRITICAL/FATAL
    end
end
#         "--machine=sbc09",
        "--machine=Simple6809",
    end
end
#         "--machine=Dragon32",
#         "--machine=Multicomp6809",
#         "--max=100000",
        "--display_cycle",
    end
    ]
    print("Startup CLI with: %s" % " ".join(cmd_args[1:]))
    subprocess.Popen.new(cmd_args).wait()
end

if __name__ == "__main__"
    test_run()
end
