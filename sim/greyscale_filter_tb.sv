module greyscale_filter_tb;
    //Inputs
    reg aclk;
    reg aresetn;
    reg s_axis_video_tvalid;
    reg [23:0] s_axis_video_tdata;
    reg s_axis_video_tlast;
    reg s_axis_video_tuser;
    reg m_axis_video_tready;

    wire s_axis_video_tready;
    wire [23:0] m_axis_video_tdata;
    wire m_axis_video_tvalid;
    wire m_axis_video_tuser;
    wire m_axis_video_last;

    //Instantiate the DUT
    greyscale_filter dut(
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_video_tvalid(s_axis_video_tvalid),
        .s_axis_video_tdata(s_axis_video_tdata),
        .s_axis_video_tlast(s_axis_video_tlast),
        .s_axis_video_tuser(s_axis_video_tuser),
        .m_axis_video_tready(m_axis_video_tready),
        .s_axis_video_tready(s_axis_video_tready),
        .m_axis_video_tdata(m_axis_video_tdata),
        .m_axis_video_tvalid(m_axis_video_tvalid),
        .m_axis_video_tuser(m_axis_video_tuser),
        .m_axis_video_last(m_axis_video_last)
    );

    always #5 aclk <= ~aclk;
    initial begin
        aclk = 0;
        aresetn = 0;
        s_axis_video_tvalid = 0;
        s_axis_video_tdata = 0;
        s_axis_video_tlast = 0;
        s_axis_video_tuser = 0;
        m_axis_video_tready = 0; 

        #10;
        aresetn = 1;
        m_axis_video_tready = 1;
        s_axis_video_tlast = 0;
        s_axis_video_tuser = 0;
        s_axis_video_tvalid = 1;
        s_axis_video_tdata = 24'hFF0000;

        #90;
        $finish;
    end

    initial begin
        $dumpfile("greyscale_filter_tb.vcd");
        $dumpvars(0, greyscale_filter_tb);
    end

endmodule