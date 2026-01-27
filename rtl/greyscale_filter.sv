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



//Register Assignments:
logic [23:0] m_axis_video_tdata_r;
logic [23:0] m_axis_video_tdata_o;

//RGB
assign red = s_axis_video_tdata[23:16];
assign blue = s_axis_video_tdata[15:8];
assign green = s_axis_video_tdata[7:0];

//Port Connections:
assign s_axis_video_tready = m_axis_video_tready; //Accept input only if output block is ready
assign m_axis_video_tvalid = s_axis_video_tvalid;//Valid Output only if Input Data is valid
assign m_axis_video_tdata = m_axis_video_tdata_o;
assign m_axis_video_last = s_axis_video_tlast;
assign m_axis_video_tuser = m_axis_video_tuser;

//Greyscale Formula: G = (0.299R + 0.587G + 0.114B)
//Converting from FP to Integer multiply by 64 (Right shift by 6)
always_comb begin
    gray = (19*red + 38*green + 7*blue) >> 6;

    //Port connections
    // m_axis_video_last = s_axis_video_tlast;
    // m_axis_video_tuser = m_axis_video_tuser;

end

always_ff @(posedge aclk) begin
    if (!aresetn) begin
        m_axis_video_tdata_r <= 24'b0;
    end else begin
        //TX Side
        if (s_axis_video_tvalid && s_axis_video_tready) begin
            m_axis_video_tdata_r <= {gray, gray, gray}; //Transform the Data
        end  
        //RX Side
        if (m_axis_video_tvalid && m_axis_video_tready)  begin  //Only need to set tready high
            m_axis_video_tdata_o <= m_axis_video_tdata_r; //Data is streamed out
        end 
    end
end
endmodule