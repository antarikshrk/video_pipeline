//Greyscale Filter
module greyscale_filter(
    input wire aclk,
    input wire aresetn,

    //Inputs/Outputs from/to v_vid_in_axi4s_0
    input wire s_axis_video_tvalid,
    input wire [23:0] s_axis_video_tdata,
    input wire s_axis_video_tlast,
    input wire s_axis_video_tuser,
    output wire s_axis_video_tready,

    //Inputs/Outputs to and from v_axi4s_vid_out_0
    output wire [23:0] m_axis_video_tdata,
    output wire m_axis_video_tvalid,
    input wire m_axis_video_tready,
    output wire m_axis_video_tuser,
    output wire m_axis_video_last
);

//RGB Values stored into Registers
logic [7:0] red;
logic [7:0] blue;
logic [7:0] green;
logic [7:0] gray;

//Internal Registers for Sequential Logic
logic s_axis_video_tready_r;
logic [23:0] m_axis_video_tdata_r;
logic m_axis_video_tvalid_r;
logic m_axis_video_last_r;
logic m_axis_video_tuser_r;

//Register Assignments:

//RGB
assign red = s_axis_video_tdata[23:16];
assign blue = s_axis_video_tdata[15:8];
assign green = s_axis_video_tdata[7:0];

//Internal Registers
assign s_axis_video_tready = s_axis_video_tready_r;
assign m_axis_video_tdata  = m_axis_video_tdata_r;
assign m_axis_video_tvalid = m_axis_video_tvalid_r; //Indicates if the Output is ready
assign m_axis_video_last = m_axis_video_last_r;
assign m_axis_video_tuser = m_axis_video_tuser_r;


//Greyscale Formula: G = (0.299R + 0.587G + 0.114B)
//Converting from FP to Integer multiply by 64 (Right shift by 6)
always_comb begin
    gray = (19*red + 38*green + 7*blue) >> 6;
end

always_ff @(posedge aclk) begin
    if (!aresetn) begin
        m_axis_video_tvalid_r <= 1'b0;
        s_axis_video_tready_r <= 1'b0;
        m_axis_video_tdata_r <= 24'b0;
    end else begin
        s_axis_video_tready_r <= 1'b1; //Always Ready

        //Input Handshaking -> Send Data
        if (s_axis_video_tvalid && s_axis_video_tready_r) begin
            m_axis_video_tdata_r <= {gray, gray, gray}; //Get Data
            m_axis_video_last_r <= s_axis_video_tlast;
            m_axis_video_tuser_r <= s_axis_video_tuser;
            m_axis_video_tvalid_r <= 1'b1; //Output is Valid
        end  
        //Output Handshaking -> Confirm Data
        if (m_axis_video_tvalid_r && m_axis_video_tready)  begin 
            m_axis_video_tvalid_r <= 1'b0; //Output not valid anymore
        end 
    end
end
endmodule