module SPI_REF (SPI_GM_IF spi_gm_if);

reg [3:0] counter;
reg       received_address;
// state registers
reg [2:0] cs, ns;
always @(posedge spi_gm_if.clk) begin
    if (~spi_gm_if.rst_n) begin
        cs <= spi_gm_if.IDLE;
    end
    else begin
        cs <= ns;
    end
end

// next state logic
always @(*) begin
    case (cs)
        spi_gm_if.IDLE : begin
            if (spi_gm_if.SS_n)
                ns = spi_gm_if.IDLE;
            else
                ns = spi_gm_if.CHK_CMD;
        end
        spi_gm_if.CHK_CMD : begin
            if (spi_gm_if.SS_n)
                ns = spi_gm_if.IDLE;
            else begin
                if (~spi_gm_if.MOSI)
                    ns = spi_gm_if.WRITE;
                else begin
                    if (received_address)
                    //*****fixed this bug here, from read address to read data*****//
                        ns = spi_gm_if.READ_DATA;
                    else
                        ns = spi_gm_if.READ_ADDRESS;
                end
            end
        end
        spi_gm_if.WRITE : begin
            if (spi_gm_if.SS_n)
                ns = spi_gm_if.IDLE;
            else
                ns = spi_gm_if.WRITE;
        end
        spi_gm_if.READ_ADDRESS : begin
            if (spi_gm_if.SS_n)
                ns = spi_gm_if.IDLE;
            else
                ns = spi_gm_if.READ_ADDRESS;
        end
        spi_gm_if.READ_DATA : begin
            if (spi_gm_if.SS_n)
                ns = spi_gm_if.IDLE;
            else
                ns = spi_gm_if.READ_DATA;
        end
        //*****added default case to avoid latches*****//
        default : ns = spi_gm_if.IDLE;
    endcase
end

always @(posedge spi_gm_if.clk) begin
    if (~spi_gm_if.rst_n) begin 
        spi_gm_if.rx_data <= 0;
        spi_gm_if.rx_valid <= 0;
        received_address <= 0;
        spi_gm_if.MISO <= 0;
        //*****fixed this bug here, counter should be 0 at reset*****//
        counter <= 0;
    end
    else begin
        case (cs)
            spi_gm_if.IDLE : begin
                spi_gm_if.rx_valid <= 0;
            end
            spi_gm_if.CHK_CMD : begin
                counter <= 10;      
            end
            spi_gm_if.WRITE : begin
                if (counter > 0) begin
                    spi_gm_if.rx_data[counter-1] <= spi_gm_if.MOSI;
                    counter <= counter - 1;
                end
                else begin
                    spi_gm_if.rx_valid <= 1;
                end
            end
            spi_gm_if.READ_ADDRESS : begin
                if (counter > 0) begin
                    spi_gm_if.rx_data[counter-1] <= spi_gm_if.MOSI;
                    counter <= counter - 1;
                end
                else begin
                    spi_gm_if.rx_valid <= 1;
                    received_address <= 1;
                end
            end
            spi_gm_if.READ_DATA : begin

                if (spi_gm_if.tx_valid) begin
                    spi_gm_if.rx_valid <= 0;
                    if (counter > 0) begin
                        spi_gm_if.MISO <= spi_gm_if.tx_data[counter-1];
                        counter <= counter - 1;
                    end
                    else begin
                        received_address <= 0;
                    end
                end
                else begin
                    if (counter > 0) begin
                        spi_gm_if.rx_data[counter-1] <= spi_gm_if.MOSI;
                        counter <= counter - 1;
                    end
                    else begin
                        spi_gm_if.rx_valid <= 1;
                        counter <= 9;
                    end
                end
            end
        endcase
    end
end

endmodule