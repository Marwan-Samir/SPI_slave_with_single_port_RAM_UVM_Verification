module SPI_SLAVE (SPI_IF spi_if);

    reg [3:0] counter;
    reg       received_address;

    // state registers
    reg [2:0] cs, ns;

    always @(posedge spi_if.clk) begin
        if (~spi_if.rst_n) begin
            cs <= spi_if.IDLE;
        end
        else begin
            cs <= ns;
        end
    end

    // next state logic
    always @(*) begin
        case (cs)
            spi_if.IDLE: begin
                if (spi_if.SS_n)
                    ns = spi_if.IDLE;
                else
                    ns = spi_if.CHK_CMD;
            end

            spi_if.CHK_CMD: begin
                if (spi_if.SS_n)
                    ns = spi_if.IDLE;
                else begin
                    if (~spi_if.MOSI)
                        ns = spi_if.WRITE;
                    else begin
                        if (received_address)
                            //*****fixed this bug here, from read address to read data*****//
                            ns = spi_if.READ_DATA;
                        else
                            ns = spi_if.READ_ADDRESS;
                    end
                end
            end

            spi_if.WRITE: begin
                if (spi_if.SS_n)
                    ns = spi_if.IDLE;
                else
                    ns = spi_if.WRITE;
            end

            spi_if.READ_ADDRESS: begin
                if (spi_if.SS_n)
                    ns = spi_if.IDLE;
                else
                    ns = spi_if.READ_ADDRESS;
            end

            spi_if.READ_DATA: begin
                if (spi_if.SS_n)
                    ns = spi_if.IDLE;
                else
                    ns = spi_if.READ_DATA;
            end
            //*****added default case to avoid latches*****//
            default: ns = spi_if.IDLE;
        endcase
    end

    always @(posedge spi_if.clk) begin
        if (~spi_if.rst_n) begin
            spi_if.rx_data <= 0;
            spi_if.rx_valid <= 0;
            received_address <= 0;
            spi_if.MISO <= 0;
            spi_if.MOSI <= 0;
            //*****fixed this bug here, counter should be 0 at reset*****//
            counter <= 0;
        end
        else begin
            case (cs)
                spi_if.IDLE: begin
                    spi_if.rx_valid <= 0;
                end

                spi_if.CHK_CMD: begin
                    counter <= 10;
                end

                spi_if.WRITE: begin
                    if (counter > 0) begin
                        spi_if.rx_data[counter-1] <= spi_if.MOSI;
                        counter <= counter - 1;
                    end
                    else begin
                        spi_if.rx_valid <= 1;
                    end
                end

                spi_if.READ_ADDRESS: begin
                    if (counter > 0) begin
                        spi_if.rx_data[counter-1] <= spi_if.MOSI;
                        counter <= counter - 1;
                    end
                    else begin
                        spi_if.rx_valid <= 1;
                        received_address <= 1;
                    end
                end

                spi_if.READ_DATA: begin
                    if (spi_if.tx_valid) begin
                        spi_if.rx_valid <= 0;
                        if (counter > 0) begin
                            spi_if.MISO <= spi_if.tx_data[counter-1];
                            counter <= counter - 1;
                        end
                        else begin
                            received_address <= 0;
                        end
                    end
                    else begin
                        if (counter > 0) begin
                            spi_if.rx_data[counter-1] <= spi_if.MOSI;
                            counter <= counter - 1;
                        end
                        else begin
                            spi_if.rx_valid <= 1;
                            //* fixed the counter reset to get all bits of miso*//
                            counter <= 9; 
                        end
                    end
                end
                default : begin
                    spi_if.rx_data <= 0;
                    spi_if.rx_valid <= 0;
                    received_address <= 0;
                    spi_if.MISO <= 0;
                    spi_if.MOSI <= 0;
                    counter <= 0;      
                end
	
            endcase
        end
    end

`ifdef SIM

    // sequences for command patterns
    sequence write_addr; ((spi_if.MOSI == 0) ##1 (spi_if.MOSI == 0) ##1 (spi_if.MOSI == 0) && counter == 10); endsequence
    sequence write_data; ((spi_if.MOSI == 0) ##1 (spi_if.MOSI == 0) ##1 (spi_if.MOSI == 1) && counter == 10); endsequence
    sequence read_addr;  ((spi_if.MOSI == 1) ##1 (spi_if.MOSI == 1) ##1 (spi_if.MOSI == 0) && counter == 10); endsequence
    sequence read_data;  ((spi_if.MOSI == 1) ##1 (spi_if.MOSI == 1) ##1 (spi_if.MOSI == 1) && counter == 9 && !received_address); endsequence

    // =====================================================
    //                FSM PROPERTIES
    // =====================================================

    // --- reset assertion
    property p_rst;
        @(posedge spi_if.clk)
            (!spi_if.rst_n)
            |=> (spi_if.MISO == 0 && spi_if.rx_valid == 0 && spi_if.rx_data == 0);
    endproperty

    property p_IDLE_to_chk;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.IDLE && !spi_if.SS_n) |=> (cs == spi_if.CHK_CMD);
    endproperty

    property p_chk_to_WRITE;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (cs == spi_if.CHK_CMD && !spi_if.MOSI) |=> (cs == spi_if.WRITE);
    endproperty

    property p_chk_to_READ_ADDRESS;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (cs == spi_if.CHK_CMD && spi_if.MOSI && !received_address) |=> (cs == spi_if.READ_ADDRESS);
    endproperty

    property p_chk_to_READ_DATA;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (cs == spi_if.CHK_CMD && spi_if.MOSI && received_address) |=> (cs == spi_if.READ_DATA);
    endproperty

    property p_WRITE_to_IDLE;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.WRITE && spi_if.SS_n) |=> (cs == spi_if.IDLE);
    endproperty

    property p_readadd_to_IDLE;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.READ_ADDRESS && spi_if.SS_n) |=> (cs == spi_if.IDLE);
    endproperty

    property p_readdata_to_IDLE;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.READ_DATA && spi_if.SS_n) |=> (cs == spi_if.IDLE);
    endproperty

    property p_rx_valid_wr_addr;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (write_addr) |=> ##10 (spi_if.rx_valid);
    endproperty

    property p_rx_valid_wr_data;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (write_data) |=> ##10 (spi_if.rx_valid);
    endproperty

    property p_rx_valid_rd_addr;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (read_addr) |=> ##10 (spi_if.rx_valid);
    endproperty

    property p_rx_valid_rd_data;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n || spi_if.SS_n)
            (read_data) |=> ##10 (spi_if.rx_valid);
    endproperty

    property p_ss_N_rd_data;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.READ_DATA) |=> ##23 (spi_if.SS_n[->1]);
    endproperty

    property p_ss_N_normal;
        @(posedge spi_if.clk) disable iff(!spi_if.rst_n)
            (cs == spi_if.WRITE || cs == spi_if.READ_ADDRESS) |=> ##13 (spi_if.SS_n[->1]);
    endproperty

    // =====================================================
    //                FSM ASSERTIONS
    // =====================================================

    assert property (p_rst)
        else $error("ASSERTION FAILED: reset didn't clear the outputs");

    assert property (p_IDLE_to_chk)
        else $error("FSM Error: Expected spi_if.IDLE → spi_if.CHK_CMD");

    assert property (p_chk_to_WRITE)
        else $error("FSM Error: spi_if.CHK_CMD must go to spi_if.WRITE");

    assert property (p_chk_to_READ_ADDRESS)
        else $error("FSM Error: spi_if.CHK_CMD must go to READ_ADD");

    assert property (p_chk_to_READ_DATA)
        else $error("FSM Error: spi_if.CHK_CMD must go to spi_if.READ_DATA");

    assert property (p_WRITE_to_IDLE)
        else $error("FSM Error: spi_if.WRITE must return to spi_if.IDLE");

    assert property (p_readadd_to_IDLE)
        else $error("FSM Error: READ_ADD must return to spi_if.IDLE");

    assert property (p_readdata_to_IDLE)
        else $error("FSM Error: spi_if.READ_DATA must return to spi_if.IDLE");

    assert property (p_rx_valid_wr_addr)
        else $error("ASSERTION FAILED: rx_valid_wr_addr did not assert after command");

    assert property (p_rx_valid_wr_data)
        else $error("ASSERTION FAILED: rx_valid_wr_data did not assert after command");

    assert property (p_rx_valid_rd_addr)
        else $error("ASSERTION FAILED: rx_valid_rd_addr did not assert after command");

    assert property (p_rx_valid_rd_data)
        else $error("ASSERTION FAILED: rx_valid_rd_data did not assert after command");

    assert property (p_ss_N_rd_data)
        else $error("ASSERTION FAILED: ss_N_rd_data did not assert after command");

    assert property (p_ss_N_normal)
        else $error("ASSERTION FAILED: ss_N_normal did not assert after command");

    // =====================================================
    //                FSM COVERS
    // =====================================================

    cover property (p_rst);
    cover property (p_IDLE_to_chk);
    cover property (p_chk_to_WRITE);
    cover property (p_chk_to_READ_ADDRESS);
    cover property (p_chk_to_READ_DATA);
    cover property (p_WRITE_to_IDLE);
    cover property (p_readadd_to_IDLE);
    cover property (p_readdata_to_IDLE);
    cover property (p_rx_valid_wr_addr);
    cover property (p_rx_valid_wr_data);
    cover property (p_rx_valid_rd_addr);
    cover property (p_rx_valid_rd_data);
    cover property (p_ss_N_rd_data);
    cover property (p_ss_N_normal);

`endif

endmodule
