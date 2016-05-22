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
    # Python 3
    require queue
    require _thread
except ImportError
    # Python 2
    require Queue as queue
    require thread as _thread
    range = xrange
end

require inspect
require logging
require sys
require threading
require time
require warnings


from MC6809.core.cpu_control_server import start_http_control_server
from MC6809.components.cpu_utils.MC6809_registers import (
    ValueStorage8Bit, ConcatenatedAccumulator,
    ValueStorage16Bit, ConditionCodeRegister, UndefinedRegister
end
)
from MC6809.components.cpu_utils.instruction_caller import OpCollection
from MC6809.utils.bits import is_bit_set, get_bit
from MC6809.utils.byte_word_values import signed8, signed16, signed5
from MC6809.components.MC6809data.MC6809_op_data import (
    REG_A, REG_B, REG_CC, REG_D, REG_DP, REG_PC,
    REG_S, REG_U, REG_X, REG_Y
end
)


log = logging.getLogger("MC6809")


# HTML_TRACE = true
HTML_TRACE = false


def opcode (*opcodes)
    """A decorator for opcodes"""
    def decorator (func)
        setattr(func, "_is_opcode", true)
        setattr(func, "_opcodes", opcodes)
        return func
    end
    return decorator
end




undefined_reg = UndefinedRegister.new()


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


class CPU < object
    
    SWI3_VECTOR = 0xfff2
    SWI2_VECTOR = 0xfff4
    FIRQ_VECTOR = 0xfff6
    IRQ_VECTOR = 0xfff8
    SWI_VECTOR = 0xfffa
    NMI_VECTOR = 0xfffc
    RESET_VECTOR = 0xfffe
    
    STARTUP_BURST_COUNT = 100
    
    def initialize (memory, cfg, cpu_status_queue=nil)
        @memory = memory
        @memory.cpu = self # FIXME
        @cfg = cfg
        
        @running = true
        @cycles = 0
        @last_op_address = 0 # Store the current run opcode memory address
        @outer_burst_op_count = @STARTUP_BURST_COUNT
        
        if cpu_status_queue.equal? not nil
            status_thread = CPUStatusThread.new(self, cpu_status_queue)
            status_thread.deamon = true
            status_thread.start()
        end
        
        start_http_control_server(self, cfg)
        
        @index_x = ValueStorage16Bit.new(REG_X, 0) # X - 16 bit index register
        @index_y = ValueStorage16Bit.new(REG_Y, 0) # Y - 16 bit index register
        
        @user_stack_pointer = ValueStorage16Bit.new(REG_U, 0) # U - 16 bit user-stack pointer
        @user_stack_pointer.counter = 0
        
        # S - 16 bit system-stack pointer
        # Position will be set by ROM code after detection of total installed RAM
        @system_stack_pointer = ValueStorage16Bit.new(REG_S, 0)
        
        # PC - 16 bit program counter register
        @program_counter = ValueStorage16Bit.new(REG_PC, 0)
        
        @accu_a = ValueStorage8Bit.new(REG_A, 0) # A - 8 bit accumulator
        @accu_b = ValueStorage8Bit.new(REG_B, 0) # B - 8 bit accumulator
        
        # D - 16 bit concatenated reg. (A + B)
        @accu_d = ConcatenatedAccumulator.new(REG_D, @accu_a, @accu_b)
        
        # DP - 8 bit direct page register
        @direct_page = ValueStorage8Bit.new(REG_DP, 0)
        
        # 8 bit condition code register bits: E F H I N Z V C
        @cc = ConditionCodeRegister.new()
        
        @register_str2object = {
            REG_X: @index_x,
            REG_Y: @index_y,
            
            REG_U: @user_stack_pointer,
            REG_S: @system_stack_pointer,
            
            REG_PC: @program_counter,
            
            REG_A: @accu_a,
            REG_B: @accu_b,
            REG_D: @accu_d,
            
            REG_DP: @direct_page,
            REG_CC: @cc,
            
            undefined_reg.name: undefined_reg, # for TFR, EXG
        end
        }
    end
end

#         log.debug("Add opcode functions:")
        @opcode_dict = OpCollection.new(self).get_opcode_dict()
    end
end

#         log.debug("illegal ops: %s" % ",".join(["$%x" % c for c in ILLEGAL_OPS]))
        # add illegal instruction
    end
end
#         for opcode in ILLEGAL_OPS
#             @opcode_dict[opcode] = IllegalInstruction.new(self, opcode)
    
    def get_state
        """
        used in unittests
        """
        return {
            REG_X: @index_x.get(),
            REG_Y: @index_y.get(),
            
            REG_U: @user_stack_pointer.get(),
            REG_S: @system_stack_pointer.get(),
            
            REG_PC: @program_counter.get(),
            
            REG_A: @accu_a.get(),
            REG_B: @accu_b.get(),
            
            REG_DP: @direct_page.get(),
            REG_CC: @cc.get(),
            
            "cycles": @cycles,
            "RAM": tuple(@memory._mem) # copy of array.array() values,
        end
        }
    end
    
    def set_state (state)
        """
        used in unittests
        """
        @index_x.set(state[REG_X])
        @index_y.set(state[REG_Y])
        
        @user_stack_pointer.set(state[REG_U])
        @system_stack_pointer.set(state[REG_S])
        
        @program_counter.set(state[REG_PC])
        
        @accu_a.set(state[REG_A])
        @accu_b.set(state[REG_B])
        
        @direct_page.set(state[REG_DP])
        @cc.set(state[REG_CC])
        
        @cycles = state["cycles"]
        @memory.load(address=0x0000, data=state["RAM"])
    end
    
    ####
    
    def reset
        log.info("%04x| CPU reset:", @program_counter.get())
        
        @last_op_address = 0
        
        if @cfg.__class__.__name__ == "SBC09Cfg"
            # first op.equal?
            # E400: 1AFF  reset  orcc #$FF  ;Disable interrupts.
        end
    end
end
#             log.debug("\tset CC register to 0xff")
#             @cc.set(0xff)
            log.info("\tset CC register to 0x00")
            @cc.set(0x00)
        else
    end
end
#             log.info("\tset cc.F=1: FIRQ interrupt masked")
#             @cc.F = 1
#
#             log.info("\tset cc.I=1: IRQ interrupt masked")
#             @cc.I = 1
            
            log.info("\tset E - 0x80 - bit 7 - Entire register state stacked")
            @cc.E = 1
        end
    end
end

#         log.debug("\tset PC to $%x" % @cfg.RESET_VECTOR)
#         @program_counter = @cfg.RESET_VECTOR
        
        log.info("\tread reset vector from $%04x", @RESET_VECTOR)
        ea = @memory.read_word(@RESET_VECTOR)
        log.info("\tset PC to $%04x" % ea)
        if ea == 0x0000
            log.critical("Reset vector.equal? $%04x ??? ROM loading in the right place?!?", ea)
        end
        @program_counter.set(ea)
    end
    
    ####
    
    def get_and_call_next_op
        op_address, opcode = read_pc_byte()
        begin
            call_instruction_func(op_address, opcode)
        rescue Exception => err
            begin
                msg = sprintf("%s - op address: $%04x - opcode: $%02x", err, op_address, opcode)
            except TypeError: # e.g: op_address or opcode.equal? nil
                msg = sprintf("%s - op address: %r - opcode: %r", err, op_address, opcode)
            exception = err.__class__ # Use origin Exception class, e.g.: KeyError
            raise exception(msg)
        end
    end
    
    def quit
        log.critical("CPU quit() called.")
        @running = false
    end
    
    def call_instruction_func (op_address, opcode)
        @last_op_address = op_address
        begin
            cycles, instr_func = @opcode_dict[opcode]
        except KeyError
            msg = sprintf("$%x *** UNKNOWN OP $%x", op_address, opcode)
            log.error(msg)
            sys.exit(msg)
        end
        
        instr_func(opcode)
        @cycles += cycles
    end
    
    
    ####
    
    # TODO: Move to __init__
    quickest_sync_callback_cycles = nil
    sync_callbacks_cyles = {}
    sync_callbacks = []
    def add_sync_callback (callback_cycles, callback)
        """ Add a CPU cycle triggered callback """
        @sync_callbacks_cyles[callback] = 0
        @sync_callbacks.append([callback_cycles, callback])
        if @quickest_sync_callback_cycles.equal? nil or\
                        @quickest_sync_callback_cycles > callback_cycles:
            @quickest_sync_callback_cycles = callback_cycles
        end
    end
    
    def call_sync_callbacks
        """ Call every sync callback with CPU cycles trigger """
        current_cycles = @cycles
        for callback_cycles, callback in @sync_callbacks
            # get the CPU cycles count of the last call
            last_call_cycles = @sync_callbacks_cyles[callback]
            
            if current_cycles - last_call_cycles > callback_cycles
                # this callback should be called
                
                # Save the current cycles, to trigger the next call
                @sync_callbacks_cyles[callback] = @cycles
                
                # Call the callback function
                callback(current_cycles - last_call_cycles)
            end
        end
    end
    
    # TODO: Move to __init__
    inner_burst_op_count = 100 # How many ops calls, before next sync call
    def burst_run
        """ Run CPU as fast as Python can... """
        # https://wiki.python.org/moin/PythonSpeed/PerformanceTips#Avoiding_dots...
        get_and_call_next_op = @get_and_call_next_op
        
        for __ in range(@outer_burst_op_count)
            for __ in range(@inner_burst_op_count)
                get_and_call_next_op()
            end
            
            call_sync_callbacks()
        end
    end
    
    # TODO: Move to __init__
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
    
    # TODO: Move to __init__
    min_burst_count = 10 # minimum outer op count per burst
    max_burst_count = 10000 # maximum outer op count per burst
    def calc_new_count (burst_count, current_value, target_value)
        """
        >>> calc_new_count(burst_count=100, current_value=30, target_value=30)
        100
        >>> calc_new_count(burst_count=100, current_value=40, target_value=20)
        75
        >>> calc_new_count(burst_count=100, current_value=20, target_value=40)
        150
        """
        # log.critical(
        #     "%i op count current: %.4f target: %.4f",
        #     @outer_burst_op_count, current_value, target_value
        # )
        begin
            new_burst_count = float(burst_count) / float(current_value) * target_value
            new_burst_count += 1 # At least we need one loop ;)
        except ZeroDivisionError
            return burst_count * 2
        end
        
        if new_burst_count > @max_burst_count
            return @max_burst_count
        end
        
        burst_count = (burst_count + new_burst_count) / 2
        if burst_count < @min_burst_count
            return @min_burst_count
        else
            return burst_count.to_i
        end
    end
    
    def run (max_run_time=0.1, target_cycles_per_sec=nil)
        now = time.time
        
        start_time = now()
        
        if target_cycles_per_sec.equal? not nil
            # Run CPU not faster than given speedlimit
            delayed_burst_run(target_cycles_per_sec)
        else
            # Run CPU as fast as Python can...
            @delay = 0
            burst_run()
        end
        
        # Calculate the outer_burst_count new, to hit max_run_time
        @outer_burst_op_count = calc_new_count(@outer_burst_op_count,
            current_value=now() - start_time - @delay,
            target_value=max_run_time,
        end
        )
    end
    
    def test_run (start, end_, max_ops=1000000)
end
#        log.warning(sprintf("CPU test_run(): from $%x to $%x", start, end_))
        @program_counter.set(start)
    end
end
#        log.debug("-"*79)
        
        # https://wiki.python.org/moin/PythonSpeed/PerformanceTips#Avoiding_dots...
        get_and_call_next_op = @get_and_call_next_op
        program_counter = @program_counter.get
        
        for __ in range(max_ops)
            if program_counter() == end_
                return
            end
            get_and_call_next_op()
        end
        log.critical("Max ops %i arrived!", max_ops)
        raise RuntimeError.new("Max ops %i arrived!" % max_ops)
    end
    
    
    def test_run2 (start, count)
end
#        log.warning(sprintf("CPU test_run2(): from $%x count: %i", start, count))
        @program_counter.set(start)
    end
end
#        log.debug("-"*79)
        
        _old_burst_count = @outer_burst_op_count
        @outer_burst_op_count = count
        
        _old_sync_count = @inner_burst_op_count
        @inner_burst_op_count = 1
        
        burst_run()
        
        @outer_burst_op_count = _old_burst_count
        @inner_burst_op_count = _old_sync_count
    end
    
    
    ####
    
    
    def get_info
        return sprintf("cc=%02x a=%02x b=%02x dp=%02x x=%04x y=%04x u=%04x s=%04x", 
            @cc.get(),
            @accu_a.get(), @accu_b.get(),
            @direct_page.get(),
            @index_x.get(), @index_y.get(),
            @user_stack_pointer.get(), @system_stack_pointer.get()
        end
        )
    end
    
    ####
    
    def push_byte (stack_pointer, byte)
        """ pushed a byte onto stack """
        # FIXME: @system_stack_pointer -= 1
        stack_pointer.decrement(1)
        addr = stack_pointer.get()
    end
end

#        log.info(
#         log.error(
#            "%x|\tpush $%x to %s stack at $%x\t|%s",
#            @last_op_address, byte, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        @memory.write_byte(addr, byte)
    end
    
    def pull_byte (stack_pointer)
        """ pulled a byte from stack """
        addr = stack_pointer.get()
        byte = @memory.read_byte(addr)
    end
end
#        log.info(
#         log.error(
#            "%x|\tpull $%x from %s stack at $%x\t|%s",
#            @last_op_address, byte, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        
        # FIXME: @system_stack_pointer += 1
        stack_pointer.increment(1)
        
        return byte
    end
    
    def push_word (stack_pointer, word)
        # FIXME: @system_stack_pointer -= 2
        stack_pointer.decrement(2)
        
        addr = stack_pointer.get()
    end
end
#        log.info(
#         log.error(
#            "%x|\tpush word $%x to %s stack at $%x\t|%s",
#            @last_op_address, word, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        
        @memory.write_word(addr, word)
    end
end

#         hi, lo = divmod(word, 0x100)
#         push_byte(hi)
#         push_byte(lo)
    
    def pull_word (stack_pointer)
        addr = stack_pointer.get()
        word = @memory.read_word(addr)
    end
end
#        log.info(
#         log.error(
#            "%x|\tpull word $%x from %s stack at $%x\t|%s",
#            @last_op_address, word, stack_pointer.name, addr,
#            @cfg.mem_info.get_shortest(@last_op_address)
#        )
        # FIXME: @system_stack_pointer += 2
        stack_pointer.increment(2)
        return word
    end
    
    ####
    
    def read_pc_byte
        op_addr = @program_counter.get()
        m = @memory.read_byte(op_addr)
        @program_counter.increment(1)
    end
end
#        log.log(5, "read pc byte: $%02x from $%04x", m, op_addr)
        return op_addr, m
    end
    
    def read_pc_word
        op_addr = @program_counter.get()
        m = @memory.read_word(op_addr)
        @program_counter.increment(2)
    end
end
#        log.log(5, "\tread pc word: $%04x from $%04x", m, op_addr)
        return op_addr, m
    end
    
    ####
    
    def get_m_immediate
        ea, m = read_pc_byte()
    end
end
#        log.debug("\tget_m_immediate(): $%x from $%x", m, ea)
        return m
    end
    
    def get_m_immediate_word
        ea, m = read_pc_word()
    end
end
#        log.debug("\tget_m_immediate_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_direct
        op_addr, m = read_pc_byte()
        dp = @direct_page.get()
        ea = dp << 8 | m
    end
end
#        log.debug("\tget_ea_direct(): ea = dp << 8 | m  =>  $%x=$%x<<8|$%x", ea, dp, m)
        return ea
    end
    
    def get_ea_m_direct
        ea = get_ea_direct()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_ea_m_direct(): ea=$%x m=$%x", ea, m)
        return ea, m
    end
    
    def get_m_direct
        ea = get_ea_direct()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_direct(): $%x from $%x", m, ea)
        return m
    end
    
    def get_m_direct_word
        ea = get_ea_direct()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_direct(): $%x from $%x", m, ea)
        return m
    end
    
    INDEX_POSTBYTE2STR = {
        0x00: REG_X, # 16 bit index register
        0x01: REG_Y, # 16 bit index register
        0x02: REG_U, # 16 bit user-stack pointer
        0x03: REG_S, # 16 bit system-stack pointer
    end
    }
    def get_ea_indexed
        """
        Calculate the address for all indexed addressing modes
        """
        addr, postbyte = read_pc_byte()
    end
end
#        log.debug("\tget_ea_indexed(): postbyte: $%02x(%s) from $%04x",
#             postbyte, byte2bit_string(postbyte), addr
#         )
        
        rr = (postbyte >> 5) & 3
        begin
            register_str = @INDEX_POSTBYTE2STR[rr]
        except KeyError
            raise RuntimeError.new(sprintf("Register $%x doesn't exists! (postbyte: $%x)", rr, postbyte))
        end
        
        register_obj = @register_str2object[register_str]
        register_value = register_obj.get()
    end
end
#        log.debug("\t%02x == register %s: value $%x",
#             rr, register_obj.name, register_value
#         )
        
        if not is_bit_set(postbyte, bit=7): # bit 7 == 0
            # EA = n, R - use 5-bit offset from post-byte
            offset = signed5(postbyte & 0x1f)
            ea = register_value + offset
        end
    end
end
#             log.debug(
#                 "\tget_ea_indexed(): bit 7 == 0: reg.value: $%04x -> ea=$%04x + $%02x = $%04x",
#                 register_value, register_value, offset, ea
#             )
            return ea
        end
        
        addr_mode = postbyte & 0x0f
        @cycles += 1
        offset = nil
        # TODO: Optimized this, maybe use a dict mapping...
        if addr_mode == 0x0
    end
end
#             log.debug("\t0000 0x0 | ,R+ | increment by 1")
            ea = register_value
            register_obj.increment(1)
        end
        elsif addr_mode == 0x1
    end
end
#             log.debug("\t0001 0x1 | ,R++ | increment by 2")
            ea = register_value
            register_obj.increment(2)
            @cycles += 1
        end
        elsif addr_mode == 0x2
    end
end
#             log.debug("\t0010 0x2 | ,R- | decrement by 1")
            ea = register_obj.decrement(1)
        end
        elsif addr_mode == 0x3
    end
end
#             log.debug("\t0011 0x3 | ,R-- | decrement by 2")
            ea = register_obj.decrement(2)
            @cycles += 1
        end
        elsif addr_mode == 0x4
    end
end
#             log.debug("\t0100 0x4 | ,R | No offset")
            ea = register_value
        end
        elsif addr_mode == 0x5
    end
end
#             log.debug("\t0101 0x5 | B, R | B register offset")
            offset = signed8(@accu_b.get())
        end
        elsif addr_mode == 0x6
    end
end
#             log.debug("\t0110 0x6 | A, R | A register offset")
            offset = signed8(@accu_a.get())
        end
        elsif addr_mode == 0x8
    end
end
#             log.debug("\t1000 0x8 | n, R | 8 bit offset")
            offset = signed8(read_pc_byte()[1])
        end
        elsif addr_mode == 0x9
    end
end
#             log.debug("\t1001 0x9 | n, R | 16 bit offset")
            offset = signed16(read_pc_word()[1])
            @cycles += 1
        end
        elsif addr_mode == 0xa
    end
end
#             log.debug("\t1010 0xa | illegal, set ea=0")
            ea = 0
        end
        elsif addr_mode == 0xb
    end
end
#             log.debug("\t1011 0xb | D, R | D register offset")
            # D - 16 bit concatenated reg. (A + B)
            offset = signed16(@accu_d.get()) # FIXME: signed16() ok?
            @cycles += 1
        end
        elsif addr_mode == 0xc
    end
end
#             log.debug("\t1100 0xc | n, PCR | 8 bit offset from program counter")
            __, value = read_pc_byte()
            value_signed = signed8(value)
            ea = @program_counter.get() + value_signed
        end
    end
end
#             log.debug("\tea = pc($%x) + $%x = $%x(dez.: %i + %i = %i)",
#                 @program_counter, value_signed, ea,
#                 @program_counter, value_signed, ea,
#             )
        elsif addr_mode == 0xd
    end
end
#             log.debug("\t1101 0xd | n, PCR | 16 bit offset from program counter")
            __, value = read_pc_word()
            value_signed = signed16(value)
            ea = @program_counter.get() + value_signed
            @cycles += 1
        end
    end
end
#             log.debug("\tea = pc($%x) + $%x = $%x(dez.: %i + %i = %i)",
#                 @program_counter, value_signed, ea,
#                 @program_counter, value_signed, ea,
#             )
        elsif addr_mode == 0xe
    end
end
#             log.error("\tget_ea_indexed(): illegal address mode, use 0xffff")
            ea = 0xffff # illegal
        end
        elsif addr_mode == 0xf
    end
end
#             log.debug("\t1111 0xf | [n] | 16 bit address - extended indirect")
            __, ea = read_pc_word()
        else
            raise RuntimeError.new("Illegal indexed addressing mode: $%x" % addr_mode)
        end
        
        if offset.equal? not nil
            ea = register_value + offset
        end
    end
end
#             log.debug("\t$%x + $%x = $%x (dez: %i + %i = %i)",
#                 register_value, offset, ea,
#                 register_value, offset, ea
#             )
        
        ea = ea & 0xffff
        
        if is_bit_set(postbyte, bit=4): # bit 4.equal? 1 -> Indirect
    end
end
#             log.debug("\tIndirect addressing: get new ea from $%x", ea)
            ea = @memory.read_word(ea)
        end
    end
end
#             log.debug("\tIndirect addressing: new ea.equal? $%x", ea)

#        log.debug("\tget_ea_indexed(): return ea=$%x", ea)
        return ea
    end
    
    def get_m_indexed
        ea = get_ea_indexed()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_indexed(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_m_indexed
        ea = get_ea_indexed()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_ea_m_indexed(): ea = $%x m = $%x", ea, m)
        return ea, m
    end
    
    def get_m_indexed_word
        ea = get_ea_indexed()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_indexed_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_extended
        """
        extended indirect addressing mode takes a 2-byte value from post-bytes
        """
        attr, ea = read_pc_word()
    end
end
#        log.debug("\tget_ea_extended() ea=$%x from $%x", ea, attr)
        return ea
    end
    
    def get_m_extended
        ea = get_ea_extended()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_extended(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_m_extended
        ea = get_ea_extended()
        m = @memory.read_byte(ea)
    end
end
#        log.debug("\tget_m_extended(): ea = $%x m = $%x", ea, m)
        return ea, m
    end
    
    def get_m_extended_word
        ea = get_ea_extended()
        m = @memory.read_word(ea)
    end
end
#        log.debug("\tget_m_extended_word(): $%x from $%x", m, ea)
        return m
    end
    
    def get_ea_relative
        addr, x = read_pc_byte()
        x = signed8(x)
        ea = @program_counter.get() + x
    end
end
#        log.debug("\tget_ea_relative(): ea = $%x + %i = $%x \t| %s",
#            @program_counter, x, ea,
#            @cfg.mem_info.get_shortest(ea)
#        )
        return ea
    end
    
    def get_ea_relative_word
        addr, x = read_pc_word()
        ea = @program_counter.get() + x
    end
end
#        log.debug("\tget_ea_relative_word(): ea = $%x + %i = $%x \t| %s",
#            @program_counter, x, ea,
#            @cfg.mem_info.get_shortest(ea)
#        )
        return ea
    end
    
    #### Op methods
    
    @opcode(
        0x10, # PAGE 2 instructions
        0x11, # PAGE 3 instructions
    end
    )
    def instruction_PAGE (opcode)
        """ call op from page 2 or 3 """
        op_address, opcode2 = read_pc_byte()
        paged_opcode = opcode * 256 + opcode2
    end
end
#        log.debug(sprintf("$%x *** call paged opcode $%x", 
#            @program_counter, paged_opcode
#        ))
        call_instruction_func(op_address - 1, paged_opcode)
    end
    
    @opcode(# Add B accumulator to X (unsigned)
        0x3a, # ABX.new(inherent)
    end
    )
    def instruction_ABX (opcode)
        """
        Add the 8-bit unsigned value in accumulator B into index register X.
        
        source code forms: ABX
        
        CC bits "HNZVC": -----
        """
        old = @index_x.get()
        b = @accu_b.get()
        new = @index_x.increment(b)
    end
end
#        log.debug(sprintf("%x %02x ABX: X($%x) += B($%x) = $%x", 
#            @program_counter, opcode,
#            old, b, new
#        ))
    
    @opcode(# Add memory to accumulator with carry
        0x89, 0x99, 0xa9, 0xb9, # ADCA.new(immediate, direct, indexed, extended)
        0xc9, 0xd9, 0xe9, 0xf9, # ADCB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADC (opcode, m, register)
        """
        Adds the contents of the C(carry) bit and the memory byte into an 8-bit
        accumulator.
        
        source code forms: ADCA P; ADCB P
        
        CC bits "HNZVC": aaaaa
        """
        a = register.get()
        r = a + m + @cc.C
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x ADC %s: %i + %i + %i = %i (=$%x)", 
#            @program_counter, opcode, register.name,
#            a, m, @cc.C, r, r
#        ))
        @cc.clear_HNZVC()
        @cc.update_HNZVC_8(a, m, r)
    end
    
    @opcode(# Add memory to D accumulator
        0xc3, 0xd3, 0xe3, 0xf3, # ADDD.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADD16 (opcode, m, register)
        """
        Adds the 16-bit memory value into the 16-bit accumulator
        
        source code forms: ADDD P
        
        CC bits "HNZVC": -aaaa
        """
        assert register.WIDTH == 16
        old = register.get()
        r = old + m
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x %02x ADD16 %s: $%02x + $%02x = $%02x", 
#            @program_counter, opcode, m,
#            register.name,
#            old, m, r
#        ))
        @cc.clear_NZVC()
        @cc.update_NZVC_16(old, m, r)
    end
    
    @opcode(# Add memory to accumulator
        0x8b, 0x9b, 0xab, 0xbb, # ADDA.new(immediate, direct, indexed, extended)
        0xcb, 0xdb, 0xeb, 0xfb, # ADDB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_ADD8 (opcode, m, register)
        """
        Adds the memory byte into an 8-bit accumulator.
        
        source code forms: ADDA P; ADDB P
        
        CC bits "HNZVC": aaaaa
        """
        assert register.WIDTH == 8
        old = register.get()
        r = old + m
        register.set(r)
    end
end
#         log.debug(sprintf("$%x %02x %02x ADD8 %s: $%02x + $%02x = $%02x", 
#             @program_counter, opcode, m,
#             register.name,
#             old, m, r
#         ))
        @cc.clear_HNZVC()
        @cc.update_HNZVC_8(old, m, r)
    end
    
    @opcode(0xf, 0x6f, 0x7f) # CLR.new(direct, indexed, extended)
    def instruction_CLR_memory (opcode, ea)
        """
        Clear memory location
        source code forms: CLR
        CC bits "HNZVC": -0100
        """
        @cc.update_0100()
        return ea, 0x00
    end
    
    @opcode(0x4f, 0x5f) # CLRA / CLRB.new(inherent)
    def instruction_CLR_register (opcode, register)
        """
        Clear accumulator A or B
        
        source code forms: CLRA; CLRB
        CC bits "HNZVC": -0100
        """
        register.set(0x00)
        @cc.update_0100()
    end
    
    def COM.new(self, value)
        """
        CC bits "HNZVC": -aa01
        """
        value = ~value # the bits of m inverted
        @cc.clear_NZ()
        @cc.update_NZ01_8(value)
        return value
    end
    
    @opcode(# Complement memory location
        0x3, 0x63, 0x73, # COM.new(direct, indexed, extended)
    end
    )
    def instruction_COM_memory (opcode, ea, m)
        """
        Replaces the contents of memory location M with its logical complement.
        source code forms: COM Q
        """
        r = @COM.new(value=m)
    end
end
#        log.debug(sprintf("$%x COM memory $%x to $%x", 
#            @program_counter, m, r,
#        ))
        return ea, r & 0xff
    end
    
    @opcode(# Complement accumulator
        0x43, # COMA.new(inherent)
        0x53, # COMB.new(inherent)
    end
    )
    def instruction_COM_register (opcode, register)
        """
        Replaces the contents of accumulator A or B with its logical complement.
        source code forms: COMA; COMB
        """
        register.set(@COM.new(value=register.get()))
    end
end
#        log.debug(sprintf("$%x COM %s", 
#            @program_counter, register.name,
#        ))
    
    @opcode(# Decimal adjust A accumulator
        0x19, # DAA.new(inherent)
    end
    )
    def instruction_DAA (opcode)
        """
        The sequence of a single-byte add instruction on accumulator A (either
        ADDA or ADCA) and a following decimal addition adjust instruction
        results in a BCD addition with an appropriate carry bit. Both values to
        be added must be in proper BCD form (each nibble such that: 0 <= nibble
        <= 9). Multiple-precision addition must add the carry generated by this
        decimal addition adjust into the next higher digit during the add
        operation(ADCA) immediately prior to the next decimal addition adjust.
        
        source code forms: DAA
        
        CC bits "HNZVC": -aa0a
        
        Operation
            ACCA' <- ACCA + CF.new(MSN):CF.new(LSN)
        end
        
        where CF.equal? a Correction Factor, as follows
        the CF for each nibble(BCD) digit.equal? determined separately,
        and.equal? either 6 or 0.
        
        Least Significant Nibble
        CF.new(LSN) = 6 IFF 1)    C = 1
                     or 2)    LSN > 9
                 end
             end
         end
     end
        
        Most Significant Nibble
        CF.new(MSN) = 6 IFF 1)    C = 1
                     or 2)    MSN > 9
                     or 3)    MSN > 8 and LSN > 9
                 end
             end
         end
     end
        
        Condition Codes
        H    -    Not affected.
        N    -    Set if the result.equal? negative; cleared otherwise.
        Z    -    Set if the result.equal? zero; cleared otherwise.
        V    -    Undefined.
        C    -    Set if a carry.equal? generated or if the carry bit was set before the operation; cleared otherwise.
        """
        a = @accu_a.get()
        
        correction_factor = 0
        a_hi = a & 0xf0 # MSN - Most Significant Nibble
        a_lo = a & 0x0f # LSN - Least Significant Nibble
        
        if a_lo > 0x09 or @cc.H: # cc & 0x20
            correction_factor |= 0x06
        end
        
        if a_hi > 0x80 and a_lo > 0x09
            correction_factor |= 0x60
        end
        
        if a_hi > 0x90 or @cc.C: # cc & 0x01
            correction_factor |= 0x60
        end
        
        new_value = correction_factor + a
        @accu_a.set(new_value)
        
        @cc.clear_NZ() # V.equal? undefined
        @cc.update_NZC_8(new_value)
    end
    
    def DEC.new(self, a)
        """
        Subtract one from the register. The carry bit.equal? not affected, thus
        allowing this instruction to be used as a loop counter in multiple-
        precision computations. When operating on unsigned values, only BEQ and
        BNE branches can be expected to behave consistently. When operating on
        twos complement values, all signed branches are available.
        
        source code forms: DEC Q; DECA; DECB
        
        CC bits "HNZVC": -aaa-
        """
        r = a - 1
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
        if r == 0x7f
            @cc.V = 1
        end
        return r
    end
    
    @opcode(0xa, 0x6a, 0x7a) # DEC.new(direct, indexed, extended)
    def instruction_DEC_memory (opcode, ea, m)
        """ Decrement memory location """
        r = @DEC.new(m)
    end
end
#        log.debug(sprintf("$%x DEC memory value $%x -1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x4a, 0x5a) # DECA / DECB.new(inherent)
    def instruction_DEC_register (opcode, register)
        """ Decrement accumulator """
        a = register.get()
        r = @DEC.new(a)
    end
end
#        log.debug(sprintf("$%x DEC %s value $%x -1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def INC.new(self, a)
        r = a + 1
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
        if r == 0x80
            @cc.V = 1
        end
        return r
    end
    
    @opcode(# Increment accumulator
        0x4c, # INCA.new(inherent)
        0x5c, # INCB.new(inherent)
    end
    )
    def instruction_INC_register (opcode, register)
        """
        Adds to the register. The carry bit.equal? not affected, thus allowing this
        instruction to be used as a loop counter in multiple-precision
        computations. When operating on unsigned values, only the BEQ and BNE
        branches can be expected to behave consistently. When operating on twos
        complement values, all signed branches are correctly available.
        
        source code forms: INC Q; INCA; INCB
        
        CC bits "HNZVC": -aaa-
        """
        a = register.get()
        r = @INC.new(a)
        r = register.set(r)
    end
    
    @opcode(# Increment memory location
        0xc, 0x6c, 0x7c, # INC.new(direct, indexed, extended)
    end
    )
    def instruction_INC_memory (opcode, ea, m)
        """
        Adds to the register. The carry bit.equal? not affected, thus allowing this
        instruction to be used as a loop counter in multiple-precision
        computations. When operating on unsigned values, only the BEQ and BNE
        branches can be expected to behave consistently. When operating on twos
        complement values, all signed branches are correctly available.
        
        source code forms: INC Q; INCA; INCB
        
        CC bits "HNZVC": -aaa-
        """
        r = @INC.new(m)
        return ea, r & 0xff
    end
    
    @opcode(# Load effective address into an indexable register
        0x32, # LEAS.new(indexed)
        0x33, # LEAU.new(indexed)
    end
    )
    def instruction_LEA_pointer (opcode, ea, register)
        """
        Calculates the effective address from the indexed addressing mode and
        places the address in an indexable register.
        
        LEAU and LEAS do not affect the Z bit to allow cleaning up the stack
        while returning the Z bit as a parameter to a calling routine, and also
        for MC6800 INS/DES compatibility.
        
        LEAU -10,U   U-10 -> U     Subtracts 10 from U
        LEAS -10,S   S-10 -> S     Used to reserve area on stack
        LEAS 10,S    S+10 -> S     Used to 'clean up' stack
        LEAX 5,S     S+5 -> X      Transfers as well as adds
        
        source code forms: LEAS, LEAU
        
        CC bits "HNZVC": -----
        """
    end
end
#         log.debug(
#             sprintf("$%04x LEA %s: Set %s to $%04x \t| %s", 
#             @program_counter,
#             register.name, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        register.set(ea)
    end
    
    @opcode(# Load effective address into an indexable register
        0x30, # LEAX.new(indexed)
        0x31, # LEAY.new(indexed)
    end
    )
    def instruction_LEA_register (opcode, ea, register)
        """ see instruction_LEA_pointer
        
        LEAX and LEAY affect the Z(zero) bit to allow use of these registers
        as counters and for MC6800 INX/DEX compatibility.
        
        LEAX 10,X    X+10 -> X     Adds 5-bit constant 10 to X
        LEAX 500,X   X+500 -> X    Adds 16-bit constant 500 to X
        LEAY A,Y     Y+A -> Y      Adds 8-bit accumulator to Y
        LEAY D,Y     Y+D -> Y      Adds 16-bit D accumulator to Y
        
        source code forms: LEAX, LEAY
        
        CC bits "HNZVC": --a--
        """
    end
end
#         log.debug(sprintf("$%04x LEA %s: Set %s to $%04x \t| %s", 
#             @program_counter,
#             register.name, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        register.set(ea)
        @cc.Z = 0
        @cc.set_Z16(ea)
    end
    
    @opcode(# Unsigned multiply (A * B ? D)
        0x3d, # MUL.new(inherent)
    end
    )
    def instruction_MUL (opcode)
        """
        Multiply the unsigned binary numbers in the accumulators and place the
        result in both accumulators (ACCA contains the most-significant byte of
        the result). Unsigned multiply allows multiple-precision operations.
        
        The C(carry) bit allows rounding the most-significant byte through the
        sequence: MUL, ADCA #0.
        
        source code forms: MUL
        
        CC bits "HNZVC": --a-a
        """
        r = @accu_a.get() * @accu_b.get()
        @accu_d.set(r)
        @cc.Z = 1 if r == 0 else 0
        @cc.C = 1 if r & 0x80 else 0
    end
    
    @opcode(# Negate accumulator
        0x40, # NEGA.new(inherent)
        0x50, # NEGB.new(inherent)
    end
    )
    def instruction_NEG_register (opcode, register)
        """
        Replaces the register with its twos complement. The C(carry) bit
        represents a borrow and.equal? set to the inverse of the resulting binary
        carry. Note that 80 16.equal? replaced by itself and only in this case.equal?
        the V(overflow) bit set. The value 00 16.equal? also replaced by itself,
        and only in this case.equal? the C(carry) bit cleared.
        
        source code forms: NEG Q; NEGA; NEG B
        
        CC bits "HNZVC": uaaaa
        """
        x = register.get()
        r = x * -1 # same as: r = ~x + 1
        register.set(r)
    end
end
#        log.debug(sprintf("$%04x NEG %s $%02x to $%02x", 
#            @program_counter, register.name, x, r,
#        ))
        @cc.clear_NZVC()
        @cc.update_NZVC_8(0, x, r)
    end
    
    _wrong_NEG = 0
    @opcode(0x0, 0x60, 0x70) # NEG.new(direct, indexed, extended)
    def instruction_NEG_memory (opcode, ea, m)
        """ Negate memory """
        if opcode == 0x0 and ea == 0x0 and m == 0x0
            @wrong_NEG += 1
            if @wrong_NEG > 10
                raise RuntimeError.new("Wrong PC ???")
            end
        else
            @wrong_NEG = 0
        end
        
        r = m * -1 # same as: r = ~m + 1
    end
end

#        log.debug(sprintf("$%04x NEG $%02x from %04x to $%02x", 
#             @program_counter, m, ea, r,
#         ))
        @cc.clear_NZVC()
        @cc.update_NZVC_8(0, m, r)
        return ea, r & 0xff
    end
    
    @opcode(0x12) # NOP.new(inherent)
    def instruction_NOP (opcode)
        """
        No operation
        
        source code forms: NOP
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.debug("\tNOP")
    
    
    
    @opcode(# Push A, B, CC, DP, D, X, Y, U, or PC onto stack
        0x36, # PSHU.new(immediate)
        0x34, # PSHS.new(immediate)
    end
    )
    def instruction_PSH (opcode, m, register)
        """
        All, some, or none of the processor registers are pushed onto stack
        (with the exception of stack pointer itself).
        
        A single register may be placed on the stack with the condition codes
        set by doing an autodecrement store onto the stack(example: STX ,--S).
        
        source code forms: b7 b6 b5 b4 b3 b2 b1 b0 PC U Y X DP B A CC push order
        ->
        
        CC bits "HNZVC": -----
        """
        assert register in(@system_stack_pointer, @user_stack_pointer)
        
        def push (register_str, stack_pointer)
            register_obj = @register_str2object[register_str]
            data = register_obj.get()
        end
    end
end

#             log.debug("\tpush %s with data $%x", register_obj.name, data)
            
            if register_obj.WIDTH == 8
                push_byte(register, data)
            else
                assert register_obj.WIDTH == 16
                push_word(register, data)
            end
        end
    end
end

#        log.debug("$%x PSH%s post byte: $%x", @program_counter, register.name, m)
        
        # m = postbyte
        if m & 0x80: push(REG_PC, register) # 16 bit program counter register
        if m & 0x40: push(REG_U, register) #  16 bit user-stack pointer
        if m & 0x20: push(REG_Y, register) #  16 bit index register
        if m & 0x10: push(REG_X, register) #  16 bit index register
        if m & 0x08: push(REG_DP, register) #  8 bit direct page register
        if m & 0x04: push(REG_B, register) #   8 bit accumulator
        if m & 0x02: push(REG_A, register) #   8 bit accumulator
        if m & 0x01: push(REG_CC, register) #  8 bit condition code register
    end
    
    
    @opcode(# Pull A, B, CC, DP, D, X, Y, U, or PC from stack
        0x37, # PULU.new(immediate)
        0x35, # PULS.new(immediate)
    end
    )
    def instruction_PUL (opcode, m, register)
        """
        All, some, or none of the processor registers are pulled from stack
        (with the exception of stack pointer itself).
        
        A single register may be pulled from the stack with condition codes set
        by doing an autoincrement load from the stack(example: LDX ,S++).
        
        source code forms: b7 b6 b5 b4 b3 b2 b1 b0 PC U Y X DP B A CC = pull
        order
        
        CC bits "HNZVC": ccccc
        """
        assert register in(@system_stack_pointer, @user_stack_pointer)
        
        def pull (register_str, stack_pointer)
            reg_obj = @register_str2object[register_str]
            
            reg_width = reg_obj.WIDTH # 8 / 16
            if reg_width == 8
                data = pull_byte(stack_pointer)
            else
                assert reg_width == 16
                data = pull_word(stack_pointer)
            end
            
            reg_obj.set(data)
        end
    end
end

#        log.debug("$%x PUL%s:", @program_counter, register.name)
        
        # m = postbyte
        if m & 0x01: pull(REG_CC, register) # 8 bit condition code register
        if m & 0x02: pull(REG_A, register) # 8 bit accumulator
        if m & 0x04: pull(REG_B, register) # 8 bit accumulator
        if m & 0x08: pull(REG_DP, register) # 8 bit direct page register
        if m & 0x10: pull(REG_X, register) # 16 bit index register
        if m & 0x20: pull(REG_Y, register) # 16 bit index register
        if m & 0x40: pull(REG_U, register) # 16 bit user-stack pointer
        if m & 0x80: pull(REG_PC, register) # 16 bit program counter register
    end
    
    @opcode(# Subtract memory from accumulator with borrow
        0x82, 0x92, 0xa2, 0xb2, # SBCA.new(immediate, direct, indexed, extended)
        0xc2, 0xd2, 0xe2, 0xf2, # SBCB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_SBC (opcode, m, register)
        """
        Subtracts the contents of memory location M and the borrow (in the C
        (carry) bit) from the contents of the designated 8-bit register, and
        places the result in that register. The C bit represents a borrow and.equal?
        set to the inverse of the resulting binary carry.
        
        source code forms: SBCA P; SBCB P
        
        CC bits "HNZVC": uaaaa
        """
        a = register.get()
        r = a - m - @cc.C
        register.set(r)
    end
end
#        log.debug(sprintf("$%x %02x SBC %s: %i - %i - %i = %i (=$%x)", 
#            @program_counter, opcode, register.name,
#            a, m, @cc.C, r, r
#        ))
        @cc.clear_NZVC()
        @cc.update_NZVC_8(a, m, r)
    end
    
    @opcode(# Sign Extend B accumulator into A accumulator
        0x1d, # SEX.new(inherent)
    end
    )
    def instruction_SEX (opcode)
        """
        This instruction transforms a twos complement 8-bit value in accumulator
        B into a twos complement 16-bit value in the D accumulator.
        
        source code forms: SEX
        
        CC bits "HNZVC": -aa0-
            
            // 0x1d SEX inherent
            case 0x1d
                WREG_A = (RREG_B & 0x80) ? 0xff : 0;
                CLR_NZ;
                SET_NZ16.new(REG_D);
                peek_byte(cpu, REG_PC);
            end
        end
        
        #define SIGNED.new(b) ((Word)(b&0x80?b|0xff00:b))
        case 0x1D: /* SEX */ tw=SIGNED.new(ibreg); SETNZ16.new(tw) SETDREG.new(tw) break;
        """
        b = @accu_b.get()
        if b & 0x80 == 0
            @accu_a.set(0x00)
        end
        
        d = @accu_d.get()
    end
end

#        log.debug("SEX: b=$%x ; $%x&0x80=$%x ; d=$%x", b, b, (b & 0x80), d)
        
        @cc.clear_NZ()
        @cc.update_NZ_16(d)
    end
    
    
    
    @opcode(# Subtract memory from accumulator
        0x80, 0x90, 0xa0, 0xb0, # SUBA.new(immediate, direct, indexed, extended)
        0xc0, 0xd0, 0xe0, 0xf0, # SUBB.new(immediate, direct, indexed, extended)
        0x83, 0x93, 0xa3, 0xb3, # SUBD.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_SUB (opcode, m, register)
        """
        Subtracts the value in memory location M from the contents of a
        register. The C(carry) bit represents a borrow and.equal? set to the
        inverse of the resulting binary carry.
        
        source code forms: SUBA P; SUBB P; SUBD P
        
        CC bits "HNZVC": uaaaa
        """
        r = register.get()
        r_new = r - m
        register.set(r_new)
    end
end
#        log.debug(sprintf("$%x SUB8 %s: $%x - $%x = $%x (dez.: %i - %i = %i)", 
#            @program_counter, register.name,
#            r, m, r_new,
#            r, m, r_new,
#        ))
        @cc.clear_NZVC()
        if register.WIDTH == 8
            @cc.update_NZVC_8(r, m, r_new)
        else
            assert register.WIDTH == 16
            @cc.update_NZVC_16(r, m, r_new)
        end
    end
    
    
    # ---- Register Changes - FIXME: Better name for this section?!? ----
    
    REGISTER_BIT2STR = {
        0x0: REG_D, # 0000 - 16 bit concatenated reg.(A B)
        0x1: REG_X, # 0001 - 16 bit index register
        0x2: REG_Y, # 0010 - 16 bit index register
        0x3: REG_U, # 0011 - 16 bit user-stack pointer
        0x4: REG_S, # 0100 - 16 bit system-stack pointer
        0x5: REG_PC, # 0101 - 16 bit program counter register
        0x6: undefined_reg.name, # undefined
        0x7: undefined_reg.name, # undefined
        0x8: REG_A, # 1000 - 8 bit accumulator
        0x9: REG_B, # 1001 - 8 bit accumulator
        0xa: REG_CC, # 1010 - 8 bit condition code register as flags
        0xb: REG_DP, # 1011 - 8 bit direct page register
        0xc: undefined_reg.name, # undefined
        0xd: undefined_reg.name, # undefined
        0xe: undefined_reg.name, # undefined
        0xf: undefined_reg.name, # undefined
    end
    }
    
    def _get_register_obj (addr)
        addr_str = @REGISTER_BIT2STR[addr]
        reg_obj = @register_str2object[addr_str]
    end
end
#         log.debug(sprintf("get register obj: addr: $%x addr_str: %s -> register: %s", 
#             addr, addr_str, reg_obj.name
#         ))
#         log.debug(repr(@register_str2object))
        return reg_obj
    end
    
    def _get_register_and_value (addr)
        reg = _get_register_obj(addr)
        reg_value = reg.get()
        return reg, reg_value
    end
    
    def _convert_differend_width (src_reg, src_value, dst_reg)
        """
        e.g.
         8bit   $cd TFR into 16bit, results in: $cd00
     end
        16bit $1234 TFR into  8bit, results in:   $34
        
        TODO: verify this behaviour on real hardware
        see: http://archive.worldofdragon.org/phpBB3/viewtopic.php?f=8&t=4886
        """
        if src_reg.WIDTH == 8 and dst_reg.WIDTH == 16
            # e.g.: $cd -> $ffcd
            src_value += 0xff00
        end
        elsif src_reg.WIDTH == 16 and dst_reg.WIDTH == 8
            # e.g.: $1234 -> $34
            src_value = src_value | 0xff00
        end
        return src_value
    end
    
    @opcode(0x1f) # TFR.new(immediate)
    def instruction_TFR (opcode, m)
        """
        source code forms: TFR R1, R2
        CC bits "HNZVC": ccccc
        """
        high, low = divmod(m, 16)
        src_reg, src_value = _get_register_and_value(high)
        dst_reg = _get_register_obj(low)
        src_value = _convert_differend_width(src_reg, src_value, dst_reg)
        dst_reg.set(src_value)
    end
end
#         log.debug("\tTFR: Set %s to $%x from %s",
#             dst_reg, src_value, src_reg.name
#         )
    
    @opcode(# Exchange R1 with R2
        0x1e, # EXG.new(immediate)
    end
    )
    def instruction_EXG (opcode, m)
        """
        source code forms: EXG R1,R2
        CC bits "HNZVC": ccccc
        """
        high, low = divmod(m, 0x10)
        reg1, reg1_value = _get_register_and_value(high)
        reg2, reg2_value = _get_register_and_value(low)
        
        new_reg1_value = _convert_differend_width(reg2, reg2_value, reg1)
        new_reg2_value = _convert_differend_width(reg1, reg1_value, reg2)
        
        reg1.set(new_reg1_value)
        reg2.set(new_reg2_value)
    end
end

#         log.debug("\tEXG: %s($%x) <-> %s($%x)",
#             reg1.name, reg1_value, reg2.name, reg2_value
#         )
    
    # ---- Store / Load ----
    
    
    @opcode(# Load register from memory
        0xcc, 0xdc, 0xec, 0xfc, # LDD.new(immediate, direct, indexed, extended)
        0x10ce, 0x10de, 0x10ee, 0x10fe, # LDS.new(immediate, direct, indexed, extended)
        0xce, 0xde, 0xee, 0xfe, # LDU.new(immediate, direct, indexed, extended)
        0x8e, 0x9e, 0xae, 0xbe, # LDX.new(immediate, direct, indexed, extended)
        0x108e, 0x109e, 0x10ae, 0x10be, # LDY.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_LD16 (opcode, m, register)
        """
        Load the contents of the memory location M:M+1 into the designated
        16-bit register.
        
        source code forms: LDD P; LDX P; LDY P; LDS P; LDU P
        
        CC bits "HNZVC": -aa0-
        """
    end
end
#        log.debug(sprintf("$%x LD16 set %s to $%x \t| %s", 
#            @program_counter,
#            register.name, m,
#            @cfg.mem_info.get_shortest(m)
#        ))
        register.set(m)
        @cc.clear_NZV()
        @cc.update_NZ_16(m)
    end
    
    @opcode(# Load accumulator from memory
        0x86, 0x96, 0xa6, 0xb6, # LDA.new(immediate, direct, indexed, extended)
        0xc6, 0xd6, 0xe6, 0xf6, # LDB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_LD8 (opcode, m, register)
        """
        Loads the contents of memory location M into the designated register.
        
        source code forms: LDA P; LDB P
        
        CC bits "HNZVC": -aa0-
        """
    end
end
#        log.debug(sprintf("$%x LD8 %s = $%x", 
#            @program_counter,
#            register.name, m,
#        ))
        register.set(m)
        @cc.clear_NZV()
        @cc.update_NZ_8(m)
    end
    
    @opcode(# Store register to memory
        0xdd, 0xed, 0xfd, # STD.new(direct, indexed, extended)
        0x10df, 0x10ef, 0x10ff, # STS.new(direct, indexed, extended)
        0xdf, 0xef, 0xff, # STU.new(direct, indexed, extended)
        0x9f, 0xaf, 0xbf, # STX.new(direct, indexed, extended)
        0x109f, 0x10af, 0x10bf, # STY.new(direct, indexed, extended)
    end
    )
    def instruction_ST16 (opcode, ea, register)
        """
        Writes the contents of a 16-bit register into two consecutive memory
        locations.
        
        source code forms: STD P; STX P; STY P; STS P; STU P
        
        CC bits "HNZVC": -aa0-
        """
        value = register.get()
    end
end
#        log.debug(sprintf("$%x ST16 store value $%x from %s at $%x \t| %s", 
#             @program_counter,
#             value, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        @cc.clear_NZV()
        @cc.update_NZ_16(value)
        return ea, value # write word to Memory
    end
    
    @opcode(# Store accumulator to memory
        0x97, 0xa7, 0xb7, # STA.new(direct, indexed, extended)
        0xd7, 0xe7, 0xf7, # STB.new(direct, indexed, extended)
    end
    )
    def instruction_ST8 (opcode, ea, register)
        """
        Writes the contents of an 8-bit register into a memory location.
        
        source code forms: STA P; STB P
        
        CC bits "HNZVC": -aa0-
        """
        value = register.get()
    end
end
#        log.debug(sprintf("$%x ST8 store value $%x from %s at $%x \t| %s", 
#             @program_counter,
#             value, register.name, ea,
#             @cfg.mem_info.get_shortest(ea)
#         ))
        @cc.clear_NZV()
        @cc.update_NZ_8(value)
        return ea, value # write byte to Memory
    end
    
    
    # ---- Logical Operations ----
    
    
    @opcode(# AND memory with accumulator
        0x84, 0x94, 0xa4, 0xb4, # ANDA.new(immediate, direct, indexed, extended)
        0xc4, 0xd4, 0xe4, 0xf4, # ANDB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_AND (opcode, m, register)
        """
        Performs the logical AND operation between the contents of an
        accumulator and the contents of memory location M and the result.equal?
        stored in the accumulator.
        
        source code forms: ANDA P; ANDB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.get()
        r = a & m
        register.set(r)
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
    end
end
#        log.debug("\tAND %s: %i & %i = %i",
#            register.name, a, m, r
#        )
    
    @opcode(# Exclusive OR memory with accumulator
        0x88, 0x98, 0xa8, 0xb8, # EORA.new(immediate, direct, indexed, extended)
        0xc8, 0xd8, 0xe8, 0xf8, # EORB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_EOR (opcode, m, register)
        """
        The contents of memory location M.equal? exclusive ORed into an 8-bit
        register.
        
        source code forms: EORA P; EORB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.get()
        r = a ^ m
        register.set(r)
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
    end
end
#        log.debug("\tEOR %s: %i ^ %i = %i",
#            register.name, a, m, r
#        )
    
    @opcode(# OR memory with accumulator
        0x8a, 0x9a, 0xaa, 0xba, # ORA.new(immediate, direct, indexed, extended)
        0xca, 0xda, 0xea, 0xfa, # ORB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_OR (opcode, m, register)
        """
        Performs an inclusive OR operation between the contents of accumulator A
        or B and the contents of memory location M and the result.equal? stored in
        accumulator A or B.
        
        source code forms: ORA P; ORB P
        
        CC bits "HNZVC": -aa0-
        """
        a = register.get()
        r = a | m
        register.set(r)
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
    end
end
#         log.debug("$%04x OR %s: %02x | %02x = %02x",
#             @program_counter, register.name, a, m, r
#         )
    
    
    # ---- CC manipulation ----
    
    
    @opcode(# AND condition code register
        0x1c, # ANDCC.new(immediate)
    end
    )
    def instruction_ANDCC (opcode, m, register)
        """
        Performs a logical AND between the condition code register and the
        immediate byte specified in the instruction and places the result in the
        condition code register.
        
        source code forms: ANDCC #xx
        
        CC bits "HNZVC": ddddd
        """
        assert register == @cc
        
        old_cc = @cc.get()
        new_cc = old_cc & m
        @cc.set(new_cc)
    end
end
#        log.debug("\tANDCC: $%x AND $%x = $%x | set CC to %s",
#             old_cc, m, new_cc, @cc.get_info
#         )
    
    @opcode(# OR condition code register
        0x1a, # ORCC.new(immediate)
    end
    )
    def instruction_ORCC (opcode, m, register)
        """
        Performs an inclusive OR operation between the contents of the condition
        code registers and the immediate value, and the result.equal? placed in the
        condition code register. This instruction may be used to set interrupt
        masks(disable interrupts) or any other bit(s).
        
        source code forms: ORCC #XX
        
        CC bits "HNZVC": ddddd
        """
        assert register == @cc
        
        old_cc = @cc.get()
        new_cc = old_cc | m
        @cc.set(new_cc)
    end
end
#        log.debug("\tORCC: $%x OR $%x = $%x | set CC to %s",
#             old_cc, m, new_cc, @cc.get_info
#         )
    
    # ---- Test Instructions ----
    
    
    @opcode(# Compare memory from stack pointer
        0x1083, 0x1093, 0x10a3, 0x10b3, # CMPD.new(immediate, direct, indexed, extended)
        0x118c, 0x119c, 0x11ac, 0x11bc, # CMPS.new(immediate, direct, indexed, extended)
        0x1183, 0x1193, 0x11a3, 0x11b3, # CMPU.new(immediate, direct, indexed, extended)
        0x8c, 0x9c, 0xac, 0xbc, # CMPX.new(immediate, direct, indexed, extended)
        0x108c, 0x109c, 0x10ac, 0x10bc, # CMPY.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_CMP16 (opcode, m, register)
        """
        Compares the 16-bit contents of the concatenated memory locations M:M+1
        to the contents of the specified register and sets the appropriate
        condition codes. Neither the memory locations nor the specified register
        .equal? modified unless autoincrement or autodecrement are used. The carry
        flag represents a borrow and.equal? set to the inverse of the resulting
        binary carry.
        
        source code forms: CMPD P; CMPX P; CMPY P; CMPU P; CMPS P
        
        CC bits "HNZVC": -aaaa
        """
        r = register.get()
        r_new = r - m
    end
end
#        log.warning(sprintf("$%x CMP16 %s $%x - $%x = $%x", 
#             @program_counter,
#             register.name,
#             r, m, r_new,
#         ))
        @cc.clear_NZVC()
        @cc.update_NZVC_16(r, m, r_new)
    end
    
    @opcode(# Compare memory from accumulator
        0x81, 0x91, 0xa1, 0xb1, # CMPA.new(immediate, direct, indexed, extended)
        0xc1, 0xd1, 0xe1, 0xf1, # CMPB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_CMP8 (opcode, m, register)
        """
        Compares the contents of memory location to the contents of the
        specified register and sets the appropriate condition codes. Neither
        memory location M nor the specified register.equal? modified. The carry flag
        represents a borrow and.equal? set to the inverse of the resulting binary
        carry.
        
        source code forms: CMPA P; CMPB P
        
        CC bits "HNZVC": uaaaa
        """
        r = register.get()
        r_new = r - m
    end
end
#         log.warning(sprintf("$%x CMP8 %s $%x - $%x = $%x", 
#             @program_counter,
#             register.name,
#             r, m, r_new,
#         ))
        @cc.clear_NZVC()
        @cc.update_NZVC_8(r, m, r_new)
    end
    
    
    @opcode(# Bit test memory with accumulator
        0x85, 0x95, 0xa5, 0xb5, # BITA.new(immediate, direct, indexed, extended)
        0xc5, 0xd5, 0xe5, 0xf5, # BITB.new(immediate, direct, indexed, extended)
    end
    )
    def instruction_BIT (opcode, m, register)
        """
        Performs the logical AND of the contents of accumulator A or B and the
        contents of memory location M and modifies the condition codes
        accordingly. The contents of accumulator A or B and memory location M
        are not affected.
        
        source code forms: BITA P; BITB P
        
        CC bits "HNZVC": -aa0-
        """
        x = register.get()
        r = m & x
    end
end
#        log.debug(sprintf("$%x BIT update CC with $%x (m:%i & %s:%i)", 
#            @program_counter,
#            r, m, register.name, x
#        ))
        @cc.clear_NZV()
        @cc.update_NZ_8(r)
    end
    
    @opcode(# Test accumulator
        0x4d, # TSTA.new(inherent)
        0x5d, # TSTB.new(inherent)
    end
    )
    def instruction_TST_register (opcode, register)
        """
        Set the N(negative) and Z(zero) bits according to the contents of
        accumulator A or B, and clear the V(overflow) bit. The TST instruction
        provides only minimum information when testing unsigned values; since no
        unsigned value.equal? less than zero, BLO and BLS have no utility. While BHI
        could be used after TST, it provides exactly the same control as BNE,
        which.equal? preferred. The signed branches are available.
        
        The MC6800 processor clears the C(carry) bit.
        
        source code forms: TST Q; TSTA; TSTB
        
        CC bits "HNZVC": -aa0-
        """
        x = register.get()
        @cc.clear_NZV()
        @cc.update_NZ_8(x)
    end
    
    @opcode(0xd, 0x6d, 0x7d) # TST.new(direct, indexed, extended)
    def instruction_TST_memory (opcode, m)
        """ Test memory location """
    end
end
#         log.debug(sprintf("$%x TST m=$%02x", 
#             @program_counter, m
#         ))
        @cc.clear_NZV()
        @cc.update_NZ_8(m)
    end
    
    # ---- Programm Flow Instructions ----
    
    
    @opcode(# Jump
        0xe, 0x6e, 0x7e, # JMP.new(direct, indexed, extended)
    end
    )
    def instruction_JMP (opcode, ea)
        """
        Program control.equal? transferred to the effective address.
        
        source code forms: JMP EA
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("%x|\tJMP to $%x \t| %s", 
#            @last_op_address,
#            ea, @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(# Return from subroutine
        0x39, # RTS.new(inherent)
    end
    )
    def instruction_RTS (opcode)
        """
        Program control.equal? returned from the subroutine to the calling program.
        The return address.equal? pulled from the stack.
        
        source code forms: RTS
        
        CC bits "HNZVC": -----
        """
        ea = pull_word(@system_stack_pointer)
    end
end
#        log.info(sprintf("%x|\tRTS to $%x \t| %s", 
#            @last_op_address,
#            ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(
        # Branch to subroutine
        0x8d, # BSR.new(relative)
        0x17, # LBSR.new(relative)
        # Jump to subroutine
        0x9d, 0xad, 0xbd, # JSR.new(direct, indexed, extended)
    end
    )
    def instruction_BSR_JSR (opcode, ea)
        """
        Program control.equal? transferred to the effective address after storing
        the return address on the hardware stack.
        
        A return from subroutine(RTS) instruction.equal? used to reverse this
        process and must be the last instruction executed in a subroutine.
        
        source code forms: BSR dd; LBSR DDDD; JSR EA
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("%x|\tJSR/BSR to $%x \t| %s", 
#            @last_op_address,
#            ea, @cfg.mem_info.get_shortest(ea)
#        ))
        push_word(@system_stack_pointer, @program_counter.get())
        @program_counter.set(ea)
    end
    
    
    # ---- Branch Instructions ----
    
    
    @opcode(# Branch if equal
        0x27, # BEQ.new(relative)
        0x1027, # LBEQ.new(relative)
    end
    )
    def instruction_BEQ (opcode, ea)
        """
        Tests the state of the Z(zero) bit and causes a branch if it.equal? set.
        When used after a subtract or compare operation, this instruction will
        branch if the compared values, signed or unsigned, were exactly the
        same.
        
        source code forms: BEQ dd; LBEQ DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.Z == 1
    end
end
#            log.info(sprintf("$%x BEQ branch to $%x, because Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BEQ: don't branch to $%x, because Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if greater than or equal (signed)
        0x2c, # BGE.new(relative)
        0x102c, # LBGE.new(relative)
    end
    )
    def instruction_BGE (opcode, ea)
        """
        Causes a branch if the N(negative) bit and the V(overflow) bit are
        either both set or both clear. That.equal?, branch if the sign of a valid
        twos complement result.equal?, or would be, positive. When used after a
        subtract or compare operation on twos complement values, this
        instruction will branch if the register was greater than or equal to the
        memory register.
        
        source code forms: BGE dd; LBGE DDDD
        
        CC bits "HNZVC": -----
        """
        # Note these variantes are the same
        #    @cc.N == @cc.V
        #    (@cc.N ^ @cc.V) == 0
        #    not operator.xor(@cc.N, @cc.V)
        if @cc.N == @cc.V
    end
end
#            log.info(sprintf("$%x BGE branch to $%x, because N XOR V == 0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#             log.debug(sprintf("$%x BGE: don't branch to $%x, because N XOR V != 0 \t| %s", 
#                 @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#             ))
    
    @opcode(# Branch if greater (signed)
        0x2e, # BGT.new(relative)
        0x102e, # LBGT.new(relative)
    end
    )
    def instruction_BGT (opcode, ea)
        """
        Causes a branch if the N(negative) bit and V(overflow) bit are either
        both set or both clear and the Z(zero) bit.equal? clear. In other words,
        branch if the sign of a valid twos complement result.equal?, or would be,
        positive and not zero. When used after a subtract or compare operation
        on twos complement values, this instruction will branch if the register
        was greater than the memory register.
        
        source code forms: BGT dd; LBGT DDDD
        
        CC bits "HNZVC": -----
        """
        # Note these variantes are the same
        #    not((@cc.N ^ @cc.V) == 1 or @cc.Z == 1)
        #    not((@cc.N ^ @cc.V) | @cc.Z)
        #    @cc.N == @cc.V and @cc.Z == 0
        # ;)
        if not @cc.Z and @cc.N == @cc.V
    end
end
#            log.info(sprintf("$%x BGT branch to $%x, because (N==V and Z==0) \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BGT: don't branch to $%x, because (N==V and Z==0) .equal? false \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if higher (unsigned)
        0x22, # BHI.new(relative)
        0x1022, # LBHI.new(relative)
    end
    )
    def instruction_BHI (opcode, ea)
        """
        Causes a branch if the previous operation caused neither a carry nor a
        zero result. When used after a subtract or compare operation on unsigned
        binary values, this instruction will branch if the register was higher
        than the memory register.
        
        Generally not useful after INC/DEC, LD/TST, and TST/CLR/COM
        instructions.
        
        source code forms: BHI dd; LBHI DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.C == 0 and @cc.Z == 0
    end
end
#            log.info(sprintf("$%x BHI branch to $%x, because C==0 and Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BHI: don't branch to $%x, because C and Z not 0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if less than or equal (signed)
        0x2f, # BLE.new(relative)
        0x102f, # LBLE.new(relative)
    end
    )
    def instruction_BLE (opcode, ea)
        """
        Causes a branch if the exclusive OR of the N(negative) and V(overflow)
        bits.equal? 1 or if the Z(zero) bit.equal? set. That.equal?, branch if the sign of
        a valid twos complement result.equal?, or would be, negative. When used
        after a subtract or compare operation on twos complement values, this
        instruction will branch if the register was less than or equal to the
        memory register.
        
        source code forms: BLE dd; LBLE DDDD
        
        CC bits "HNZVC": -----
        """
        if(@cc.N ^ @cc.V) == 1 or @cc.Z == 1
    end
end
#            log.info(sprintf("$%x BLE branch to $%x, because N^V==1 or Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLE: don't branch to $%x, because N^V!=1 and Z!=1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower or same (unsigned)
        0x23, # BLS.new(relative)
        0x1023, # LBLS.new(relative)
    end
    )
    def instruction_BLS (opcode, ea)
        """
        Causes a branch if the previous operation caused either a carry or a
        zero result. When used after a subtract or compare operation on unsigned
        binary values, this instruction will branch if the register was lower
        than or the same as the memory register.
        
        Generally not useful after INC/DEC, LD/ST, and TST/CLR/COM instructions.
        
        source code forms: BLS dd; LBLS DDDD
        
        CC bits "HNZVC": -----
        """
    end
end
#         if(@cc.C|@cc.Z) == 0
        if @cc.C == 1 or @cc.Z == 1
    end
end
#            log.info(sprintf("$%x BLS branch to $%x, because C|Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLS: don't branch to $%x, because C|Z!=1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if less than (signed)
        0x2d, # BLT.new(relative)
        0x102d, # LBLT.new(relative)
    end
    )
    def instruction_BLT (opcode, ea)
        """
        Causes a branch if either, but not both, of the N(negative) or V
        (overflow) bits.equal? set. That.equal?, branch if the sign of a valid twos
        complement result.equal?, or would be, negative. When used after a subtract
        or compare operation on twos complement binary values, this instruction
        will branch if the register was less than the memory register.
        
        source code forms: BLT dd; LBLT DDDD
        
        CC bits "HNZVC": -----
        """
        if(@cc.N ^ @cc.V) == 1: # N xor V
    end
end
#            log.info(sprintf("$%x BLT branch to $%x, because N XOR V == 1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLT: don't branch to $%x, because N XOR V != 1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if minus
        0x2b, # BMI.new(relative)
        0x102b, # LBMI.new(relative)
    end
    )
    def instruction_BMI (opcode, ea)
        """
        Tests the state of the N(negative) bit and causes a branch if set. That
        .equal?, branch if the sign of the twos complement result.equal? negative.
        
        When used after an operation on signed binary values, this instruction
        will branch if the result.equal? minus. It.equal? generally preferred to use the
        LBLT instruction after signed operations.
        
        source code forms: BMI dd; LBMI DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.N == 1
    end
end
#            log.info(sprintf("$%x BMI branch to $%x, because N==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BMI: don't branch to $%x, because N==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if not equal
        0x26, # BNE.new(relative)
        0x1026, # LBNE.new(relative)
    end
    )
    def instruction_BNE (opcode, ea)
        """
        Tests the state of the Z(zero) bit and causes a branch if it.equal? clear.
        When used after a subtract or compare operation on any binary values,
        this instruction will branch if the register.equal?, or would be, not equal
        to the memory register.
        
        source code forms: BNE dd; LBNE DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.Z == 0
    end
end
#            log.info(sprintf("$%x BNE branch to $%x, because Z==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BNE: don't branch to $%x, because Z==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if plus
        0x2a, # BPL.new(relative)
        0x102a, # LBPL.new(relative)
    end
    )
    def instruction_BPL (opcode, ea)
        """
        Tests the state of the N(negative) bit and causes a branch if it.equal?
        clear. That.equal?, branch if the sign of the twos complement result.equal?
        positive.
        
        When used after an operation on signed binary values, this instruction
        will branch if the result(possibly invalid) .equal? positive. It.equal?
        generally preferred to use the BGE instruction after signed operations.
        
        source code forms: BPL dd; LBPL DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.N == 0
    end
end
#            log.info(sprintf("$%x BPL branch to $%x, because N==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BPL: don't branch to $%x, because N==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch always
        0x20, # BRA.new(relative)
        0x16, # LBRA.new(relative)
    end
    )
    def instruction_BRA (opcode, ea)
        """
        Causes an unconditional branch.
        
        source code forms: BRA dd; LBRA DDDD
        
        CC bits "HNZVC": -----
        """
    end
end
#        log.info(sprintf("$%x BRA branch to $%x \t| %s", 
#            @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#        ))
        @program_counter.set(ea)
    end
    
    @opcode(# Branch never
        0x21, # BRN.new(relative)
        0x1021, # LBRN.new(relative)
    end
    )
    def instruction_BRN (opcode, ea)
        """
        Does not cause a branch. This instruction.equal? essentially a no operation,
        but has a bit pattern logically related to branch always.
        
        source code forms: BRN dd; LBRN DDDD
        
        CC bits "HNZVC": -----
        """
        pass
    end
    
    @opcode(# Branch if valid twos complement result
        0x28, # BVC.new(relative)
        0x1028, # LBVC.new(relative)
    end
    )
    def instruction_BVC (opcode, ea)
        """
        Tests the state of the V(overflow) bit and causes a branch if it.equal?
        clear. That.equal?, branch if the twos complement result was valid. When
        used after an operation on twos complement binary values, this
        instruction will branch if there was no overflow.
        
        source code forms: BVC dd; LBVC DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.V == 0
    end
end
#            log.info(sprintf("$%x BVC branch to $%x, because V==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BVC: don't branch to $%x, because V==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if invalid twos complement result
        0x29, # BVS.new(relative)
        0x1029, # LBVS.new(relative)
    end
    )
    def instruction_BVS (opcode, ea)
        """
        Tests the state of the V(overflow) bit and causes a branch if it.equal?
        set. That.equal?, branch if the twos complement result was invalid. When
        used after an operation on twos complement binary values, this
        instruction will branch if there was an overflow.
        
        source code forms: BVS dd; LBVS DDDD
        
        CC bits "HNZVC": -----
        """
        if @cc.V == 1
    end
end
#            log.info(sprintf("$%x BVS branch to $%x, because V==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BVS: don't branch to $%x, because V==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower (unsigned)
        0x25, # BLO/BCS.new(relative)
        0x1025, # LBLO/LBCS.new(relative)
    end
    )
    def instruction_BLO (opcode, ea)
        """
        CC bits "HNZVC": -----
        case 0x5: cond = REG_CC & CC_C; break; // BCS, BLO, LBCS, LBLO
        """
        if @cc.C == 1
    end
end
#            log.info(sprintf("$%x BLO/BCS/LBLO/LBCS branch to $%x, because C==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#         else
#            log.debug(sprintf("$%x BLO/BCS/LBLO/LBCS: don't branch to $%x, because C==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    @opcode(# Branch if lower (unsigned)
        0x24, # BHS/BCC.new(relative)
        0x1024, # LBHS/LBCC.new(relative)
    end
    )
    def instruction_BHS (opcode, ea)
        """
        CC bits "HNZVC": -----
        case 0x4: cond = !(REG_CC & CC_C); break; // BCC, BHS, LBCC, LBHS
        """
        if @cc.C == 0
    end
end
#            log.info(sprintf("$%x BHS/BCC/LBHS/LBCC branch to $%x, because C==0 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
            @program_counter.set(ea)
        end
    end
end
#        else
#            log.debug(sprintf("$%x BHS/BCC/LBHS/LBCC: don't branch to $%x, because C==1 \t| %s", 
#                @program_counter, ea, @cfg.mem_info.get_shortest(ea)
#            ))
    
    
    # ---- Logical shift: LSL, LSR ----
    
    
    def LSL.new(self, a)
        """
        Shifts all bits of accumulator A or B or memory location M one place to
        the left. Bit zero.equal? loaded with a zero. Bit seven of accumulator A or
        B or memory location M.equal? shifted into the C(carry) bit.
        
        This.equal? a duplicate assembly-language mnemonic for the single machine
        instruction ASL.
        
        source code forms: LSL Q; LSLA; LSLB
        
        CC bits "HNZVC": naaas
        """
        r = a << 1
        @cc.clear_NZVC()
        @cc.update_NZVC_8(a, a, r)
        return r
    end
    
    @opcode(0x8, 0x68, 0x78) # LSL/ASL.new(direct, indexed, extended)
    def instruction_LSL_memory (opcode, ea, m)
        """
        Logical shift left memory location / Arithmetic shift of memory left
        """
        r = @LSL.new(m)
    end
end
#        log.debug(sprintf("$%x LSL memory value $%x << 1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x48, 0x58) # LSLA/ASLA / LSLB/ASLB.new(inherent)
    def instruction_LSL_register (opcode, register)
        """
        Logical shift left accumulator / Arithmetic shift of accumulator
        """
        a = register.get()
        r = @LSL.new(a)
    end
end
#        log.debug(sprintf("$%x LSL %s value $%x << 1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def LSR.new(self, a)
        """
        Performs a logical shift right on the register. Shifts a zero into bit
        seven and bit zero into the C(carry) bit.
        
        source code forms: LSR Q; LSRA; LSRB
        
        CC bits "HNZVC": -0a-s
        """
        r = a >> 1
        @cc.clear_NZC()
        @cc.C = get_bit(a, bit=0) # same as: @cc.C |= (a & 1)
        @cc.set_Z8(r)
        return r
    end
    
    @opcode(0x4, 0x64, 0x74) # LSR.new(direct, indexed, extended)
    def instruction_LSR_memory (opcode, ea, m)
        """ Logical shift right memory location """
        r = @LSR.new(m)
    end
end
#        log.debug(sprintf("$%x LSR memory value $%x >> 1 = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x44, 0x54) # LSRA / LSRB.new(inherent)
    def instruction_LSR_register (opcode, register)
        """ Logical shift right accumulator """
        a = register.get()
        r = @LSR.new(a)
    end
end
#        log.debug(sprintf("$%x LSR %s value $%x >> 1 = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def ASR.new(self, a)
        """
        ASR.new(Arithmetic Shift Right) alias LSR.new(Logical Shift Right)
        
        Shifts all bits of the register one place to the right. Bit seven.equal? held
        constant. Bit zero.equal? shifted into the C(carry) bit.
        
        source code forms: ASR Q; ASRA; ASRB
        
        CC bits "HNZVC": uaa-s
        """
        r = (a >> 1) | (a & 0x80)
        @cc.clear_NZC()
        @cc.C = get_bit(a, bit=0) # same as: @cc.C |= (a & 1)
        @cc.update_NZ_8(r)
        return r
    end
    
    @opcode(0x7, 0x67, 0x77) # ASR.new(direct, indexed, extended)
    def instruction_ASR_memory (opcode, ea, m)
        """ Arithmetic shift memory right """
        r = @ASR.new(m)
    end
end
#        log.debug(sprintf("$%x ASR memory value $%x >> 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x47, 0x57) # ASRA/ASRB.new(inherent)
    def instruction_ASR_register (opcode, register)
        """ Arithmetic shift accumulator right """
        a = register.get()
        r = @ASR.new(a)
    end
end
#        log.debug(sprintf("$%x ASR %s value $%x >> 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    
    # ---- Rotate: ROL, ROR ----
    
    
    def ROL.new(self, a)
        """
        Rotates all bits of the register one place left through the C(carry)
        bit. This.equal? a 9-bit rotation.
        
        source code forms: ROL Q; ROLA; ROLB
        
        CC bits "HNZVC": -aaas
        """
        r = (a << 1) | @cc.C
        @cc.clear_NZVC()
        @cc.update_NZVC_8(a, a, r)
        return r
    end
    
    @opcode(0x9, 0x69, 0x79) # ROL.new(direct, indexed, extended)
    def instruction_ROL_memory (opcode, ea, m)
        """ Rotate memory left """
        r = @ROL.new(m)
    end
end
#        log.debug(sprintf("$%x ROL memory value $%x << 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x49, 0x59) # ROLA / ROLB.new(inherent)
    def instruction_ROL_register (opcode, register)
        """ Rotate accumulator left """
        a = register.get()
        r = @ROL.new(a)
    end
end
#        log.debug(sprintf("$%x ROL %s value $%x << 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    def ROR.new(self, a)
        """
        Rotates all bits of the register one place right through the C(carry)
        bit. This.equal? a 9-bit rotation.
        
        moved the carry flag into bit 8
        moved bit 7 into carry flag
        
        source code forms: ROR Q; RORA; RORB
        
        CC bits "HNZVC": -aa-s
        """
        r = (a >> 1) | (@cc.C << 7)
        @cc.clear_NZ()
        @cc.update_NZ_8(r)
        @cc.C = get_bit(a, bit=0) # same as: @cc.C = (a & 1)
        return r
    end
    
    @opcode(0x6, 0x66, 0x76) # ROR.new(direct, indexed, extended)
    def instruction_ROR_memory (opcode, ea, m)
        """ Rotate memory right """
        r = @ROR.new(m)
    end
end
#        log.debug(sprintf("$%x ROR memory value $%x >> 1 | Carry = $%x and write it to $%x \t| %s", 
#            @program_counter,
#            m, r, ea,
#            @cfg.mem_info.get_shortest(ea)
#        ))
        return ea, r & 0xff
    end
    
    @opcode(0x46, 0x56) # RORA/RORB.new(inherent)
    def instruction_ROR_register (opcode, register)
        """ Rotate accumulator right """
        a = register.get()
        r = @ROR.new(a)
    end
end
#        log.debug(sprintf("$%x ROR %s value $%x >> 1 | Carry = $%x", 
#            @program_counter,
#            register.name, a, r
#        ))
        register.set(r)
    end
    
    
    # ---- Not Implemented, yet. ----
    
    
    @opcode(# AND condition code register, then wait for interrupt
        0x3c, # CWAI.new(immediate)
    end
    )
    def instruction_CWAI (opcode, m)
        """
        This instruction ANDs an immediate byte with the condition code register
        which may clear the interrupt mask bits I and F, stacks the entire
        machine state on the hardware stack and then looks for an interrupt.
        When a non-masked interrupt occurs, no further machine state information
        need be saved before vectoring to the interrupt handling routine. This
        instruction replaced the MC6800 CLI WAI sequence, but does not place the
        buses in a high-impedance state. A FIRQ.new(fast interrupt request) may
        enter its interrupt handler with its entire machine state saved. The RTI
        (return from interrupt) instruction will automatically return the entire
        machine state after testing the E(entire) bit of the recovered
        condition code register.
        
        The following immediate values will have the following results: FF =
        enable neither EF = enable IRQ BF = enable FIRQ AF = enable both
        
        source code forms: CWAI #$XX E F H I N Z V C
        
        CC bits "HNZVC": ddddd
        """
    end
end
#        log.error("$%x CWAI not implemented, yet!", opcode)
        # Update CC bits: ddddd
    end
    
    @opcode(# Undocumented opcode!
        0x3e, # RESET.new(inherent)
    end
    )
    def instruction_RESET (opcode)
        """
        Build the ASSIST09 vector table and setup monitor defaults, then invoke
        the monitor startup routine.
        
        source code forms
        
        CC bits "HNZVC": *****
        """
        raise NotImplementedError.new("$%x RESET" % opcode)
        # Update CC bits: *****
    end
    
    # ---- Interrupt handling ----
    
    irq_enabled = false
    def irq
        if not @irq_enabled or @cc.I == 1
            # log.critical(sprintf("$%04x *** IRQ, ignore!\t%s", 
            #     @program_counter.get(), @cc.get_info
            # ))
            return
        end
        
        if @cc.E
            push_irq_registers()
        else
            push_firq_registers()
        end
        
        ea = @memory.read_word(@IRQ_VECTOR)
        # log.critical(sprintf("$%04x *** IRQ, set PC to $%04x\t%s", 
        #     @program_counter.get(), ea, @cc.get_info
        # ))
        @program_counter.set(ea)
    end
    
    def push_irq_registers
        """
        push PC, U, Y, X, DP, B, A, CC on System stack pointer
        """
        @cycles += 1
        push_word(@system_stack_pointer, @program_counter.get()) # PC
        push_word(@system_stack_pointer, @user_stack_pointer.get()) # U
        push_word(@system_stack_pointer, @index_y.get()) # Y
        push_word(@system_stack_pointer, @index_x.get()) # X
        push_byte(@system_stack_pointer, @direct_page.get()) # DP
        push_byte(@system_stack_pointer, @accu_b.get()) # B
        push_byte(@system_stack_pointer, @accu_a.get()) # A
        push_byte(@system_stack_pointer, @cc.get()) # CC
    end
    
    def push_firq_registers
        """
        FIRQ - Fast Interrupt Request
        push PC and CC on System stack pointer
        """
        @cycles += 1
        push_word(@system_stack_pointer, @program_counter.get()) # PC
        push_byte(@system_stack_pointer, @cc.get()) # CC
    end
    
    @opcode(# Return from interrupt
        0x3b, # RTI.new(inherent)
    end
    )
    def instruction_RTI (opcode)
        """
        The saved machine state.equal? recovered from the hardware stack and control
        .equal? returned to the interrupted program. If the recovered E(entire) bit
        .equal? clear, it indicates that only a subset of the machine state was saved
        (return address and condition codes) and only that subset.equal? recovered.
        
        source code forms: RTI
        
        CC bits "HNZVC": -----
        """
        cc = pull_byte(@system_stack_pointer) # CC
        @cc.set(cc)
        if @cc.E
            @accu_a.set(
                pull_byte(@system_stack_pointer) # A
            end
            )
            @accu_b.set(
                pull_byte(@system_stack_pointer) # B
            end
            )
            @direct_page.set(
                pull_byte(@system_stack_pointer) # DP
            end
            )
            @index_x.set(
                pull_word(@system_stack_pointer) # X
            end
            )
            @index_y.set(
                pull_word(@system_stack_pointer) # Y
            end
            )
            @user_stack_pointer.set(
                pull_word(@system_stack_pointer) # U
            end
            )
        end
        
        @program_counter.set(
            pull_word(@system_stack_pointer) # PC
        end
        )
    end
end
#         log.critical("RTI to $%04x", @program_counter.get())
    
    
    @opcode(# Software interrupt (absolute indirect)
        0x3f, # SWI.new(inherent)
    end
    )
    def instruction_SWI (opcode)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt vector. Both the normal and
        fast interrupts are masked(disabled).
        
        source code forms: SWI
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI" % opcode)
    end
    
    @opcode(# Software interrupt (absolute indirect)
        0x103f, # SWI2.new(inherent)
    end
    )
    def instruction_SWI2 (opcode, ea, m)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt 2 vector. This interrupt.equal?
        available to the end_ user and must not be used in packaged software.
        This interrupt does not mask(disable) the normal and fast interrupts.
        
        source code forms: SWI2
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI2" % opcode)
    end
    
    @opcode(# Software interrupt (absolute indirect)
        0x113f, # SWI3.new(inherent)
    end
    )
    def instruction_SWI3 (opcode, ea, m)
        """
        All of the processor registers are pushed onto the hardware stack (with
        the exception of the hardware stack pointer itself), and control.equal?
        transferred through the software interrupt 3 vector. This interrupt does
        not mask(disable) the normal and fast interrupts.
        
        source code forms: SWI3
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SWI3" % opcode)
    end
    
    @opcode(# Synchronize with interrupt line
        0x13, # SYNC.new(inherent)
    end
    )
    def instruction_SYNC (opcode)
        """
        FAST SYNC WAIT FOR DATA Interrupt! LDA DISC DATA FROM DISC AND CLEAR
        INTERRUPT STA ,X+ PUT IN BUFFER DECB COUNT IT, DONE? BNE FAST GO AGAIN
        IF NOT.
        
        source code forms: SYNC
        
        CC bits "HNZVC": -----
        """
        raise NotImplementedError.new("$%x SYNC" % opcode)
    end
end



class TypeAssert < CPU
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
        super(TypeAssert, self).__init__(*args, **kwargs)
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

# CPU = TypeAssert # Should be only activated for debugging!


#------------------------------------------------------------------------------


def test_run
    require sys
    require os
    require subprocess
    cmd_args = [
        sys.executable,
        os.path.join("..", "DragonPy_CLI.py"),
    end
end
#        "--verbosity", "5",
        "--log", "dragonpy.components.cpu6809,50",
        
        "--machine", "Dragon32", "run",
    end
end
#        "--machine", "Vectrex", "run",
#        "--max_ops", "1",
#        "--trace",
    ]
    print("Startup CLI with: %s" % " ".join(cmd_args[1:]))
    subprocess.Popen.new(cmd_args, cwd="..").wait()
end

if __name__ == "__main__"
    test_run()
end
