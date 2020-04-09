import m5
from m5.objects import *

# Create parent system object
system = System()

# Set system clock
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '1GHz'
system.clk_domain.voltage_domain = VoltageDomain()

# Setup memory 
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('512MB')]

# Setup CPU
system.cpu = TimingSimpleCPU()

# Setup memory bus
system.membus = SystemXBar()

# Connect the memory bus to the CPU
system.cpu.icache_port = system.membus.slave
system.cpu.dcache_port = system.membus.slave

# Create I/O controller and connect it to the memory bus
system.cpu.createInterruptController()
system.system_port = system.membus.slave

# Create memory controller and connect it to the memory bus
system.mem_ctrl = DDR3_1600_8x8()
system.mem_ctrl.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.master

# Set executable
process = Process()
process.cmd = ['hello']
system.cpu.workload = process
system.cpu.createThreads()

# Setup root object to run the symulation
root = Root(full_system = False, system = system)
m5.instantiate()

# Run the symulation
exit_event = m5.simulate()
print('Exiting @ tick {} because {}'.format(m5.curTick(), exit_event.getCause()))