`timescale 1ns / 1ps
module tb_spi;

    reg clk = 0;
    reg reset = 0;
    reg load_data = 0;
    reg [7:0] data_in = 8'hA5;
    wire done_send;
    wire spi_clk;
    wire spi_data;

    spi uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .load_data(load_data),
        .done_send(done_send),
        .spi_clk(spi_clk),
        .spi_data(spi_data)
    );

    always #5 clk = ~clk; // 100 MHz clock

    initial begin
        $dumpfile("spi.vcd");
        $dumpvars(0, tb_spi);

        // Reset
        reset = 1;
        #20;
        reset = 0;

        // Load data
        #20;
        load_data = 1;
        #10;
        load_data = 0;

        // Wait for transmission to finish
        wait(done_send);
        #100;

        $finish;
    end
endmodule
