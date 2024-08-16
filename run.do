# Compile all Verilog modules
vlog PULSE_GEN.v
vlog mux.v
vlog ALU.v
vlog CLK_GATE.v
vlog STOP_Check.v
vlog Deserializer.v
vlog UART.v
vlog Strt_chck.v
vlog ClkDiv.v
vlog tb_sys_tob.v
vlog RegFile.v
vlog Parity_check.v
vlog top_fifo.v
vlog FSM_Rx.v
vlog synchronizer_r.v
vlog Fifo_wPrt.v
vlog RAM.v
vlog Parity.v
vlog serializer.v
vlog Fifo_RPrt.v
vlog Data_sample.v
vlog sys_tob.v
vlog Top.v
vlog synchronizer_w.v
vlog CTRL.v
vlog RST_SYNC.v
vlog FSM.v
vlog DATA_SYNC.v
vlog top_tx.v
vlog Edge_bit_cnt.v
vlog mux_prescale.v

# Simulate tb_sys_tob with full signal access (+acc)
vsim -voptargs=+acc work.tb_sys_tob

# Add waveforms to monitor key signals
add wave -position insertpoint sim:/tb_sys_tob/REF_CLK
add wave -position insertpoint sim:/tb_sys_tob/UART_CLK
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/TX_CLK
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/RX_CLK
add wave -position insertpoint sim:/tb_sys_tob/dut/RST
add wave -position insertpoint sim:/tb_sys_tob/dut/SYNC_RST_1 sim:/tb_sys_tob/dut/SYNC_RST_2

# UART instance signals
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/RX_IN_S
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/RX_OUT_P
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/RX_OUT_V
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/TX_IN_P
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/TX_IN_V
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/TX_OUT_S
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/TX_OUT_V
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/Prescale
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/parity_enable
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/parity_type
add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/parity_error
 add wave -position insertpoint sim:/tb_sys_tob/dut/UART_INST/framing_error

# Data synchronization signals
add wave -position insertpoint sim:/tb_sys_tob/dut/data_sync_inst/unsync_bus
add wave -position insertpoint sim:/tb_sys_tob/dut/data_sync_inst/bus_enable
add wave -position insertpoint sim:/tb_sys_tob/dut/data_sync_inst/sync_bus
add wave -position insertpoint sim:/tb_sys_tob/dut/data_sync_inst/enable_pulse_d

# System control signals
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/fifo_full
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/RdData
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/RdData_Valid
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/RX_P_DATA
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/RX_D_VLD
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/EN
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/CLK_EN
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/address
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/WrEn
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/RdEn
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/WrData
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/TX_P_DATA
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/TX_D_VLD
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/clk_div_en
add wave -position insertpoint sim:/tb_sys_tob/dut/SYS_CTRL_INST/current_state

# Register file signals
add wave -position insertpoint sim:/tb_sys_tob/dut/REGFILE_INST/clk
add wave -position insertpoint sim:/tb_sys_tob/dut/REGFILE_INST/REG0
add wave -position insertpoint sim:/tb_sys_tob/dut/REGFILE_INST/REG1
add wave -position insertpoint sim:/tb_sys_tob/dut/REGFILE_INST/REG2
add wave -position insertpoint sim:/tb_sys_tob/dut/REGFILE_INST/REG3

# ALU instance signals
add wave -position insertpoint sim:/tb_sys_tob/dut/ALU_INST/A
add wave -position insertpoint sim:/tb_sys_tob/dut/ALU_INST/B
add wave -position insertpoint sim:/tb_sys_tob/dut/ALU_INST/ALU_FUN
add wave -position insertpoint sim:/tb_sys_tob/dut/ALU_INST/ALU_OUT
add wave -position insertpoint sim:/tb_sys_tob/dut/ALU_INST/OUT_VALID

# Asynchronous FIFO instance signals
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/wrst_n
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/rrst_n
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/winc
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/rinc
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/wdata
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/rdata
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/wfull
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/empty
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/waddr
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/raddr
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/wptr
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/wq2_rptr
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/rptr
add wave -position insertpoint sim:/tb_sys_tob/dut/ASYNC_FIFO_INST/rq2_wptr

# Pulse generator signal
add wave -position insertpoint sim:/tb_sys_tob/dut/pulse_gen_inst/pulse_sig

# Clock gating signals
add wave -position insertpoint sim:/tb_sys_tob/dut/CLOCK_GATING/CLK_EN
add wave -position insertpoint sim:/tb_sys_tob/dut/CLOCK_GATING/GATED_CLK


# Run the simulation
run -all
