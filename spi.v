`timescale 1ns / 1ps

module spi (
    input        clk,           // 100 MHz system clock
    input        reset,         // Synchronous reset
    input  [7:0] data_in,       // 8-bit parallel data
    input        load_data,     // Load signal
    output       done_send,     // Transmission complete flag
    output       spi_clk,       // SPI clock output (10 MHz)
    output reg   spi_data       // MOSI line
);

    // FSM States (replaced typedef enum with parameters)
    parameter IDLE = 2'b00;
    parameter SEND = 2'b01;
    parameter DONE = 2'b10;

    reg [1:0] state = IDLE;

    // SPI Clock Divider (10 MHz from 100 MHz)
    reg [2:0] clk_div = 0;
    wire ce = (state == SEND);
    assign spi_clk = clk_div[2] & ce;

    always @(posedge clk) begin
        if (reset)
            clk_div <= 0;
        else if (ce)
            clk_div <= clk_div + 1;
    end

    reg [2:0] bit_cnt = 0;
    reg [7:0] shift_reg = 8'b0;
    reg done_flag = 0;
    assign done_send = done_flag;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            bit_cnt <= 0;
            done_flag <= 0;
            spi_data <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done_flag <= 0;
                    if (load_data) begin
                        shift_reg <= data_in;
                        bit_cnt <= 7;
                        state <= SEND;
                    end
                end

                SEND: begin
                    if (clk_div == 3'b100) begin  // 10 MHz rising edge
                        spi_data <= shift_reg[bit_cnt];
                        if (bit_cnt == 0) begin
                            state <= DONE;
                        end else begin
                            bit_cnt <= bit_cnt - 1;
                        end
                    end
                end

                DONE: begin
                    done_flag <= 1;
                    if (!load_data)
                        state <= IDLE;
                end
            endcase
        end
    end
endmodule
