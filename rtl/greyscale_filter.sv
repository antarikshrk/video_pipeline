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

//Register Assignments:

//RGB
assign red = s_axis_video_tdata[23:16];
assign blue = s_axis_video_tdata[15:8];
assign green = s_axis_video_tdata[7:0];

//Internal Registers
assign s_axis_video_tready = s_axis_video_tready_r;
assign m_axis_video_tdata  = m_axis_video_tdata_r;
assign m_axis_video_tvalid = m_axis_video_tvalid_r;
assign m_axis_video_last = m_axis_video_last_r;


//Greyscale Formula: G = (0.299R + 0.587G + 0.114B)
//Converting from FP to Integer multiply by 64 (Right shift by 6)
always_comb begin
    gray = (19*red + 38*green + 7*blue) >> 6;
end

always_ff @(posedge aclk) begin
    if (!aresetn) begin
        m_axis_video_tvalid_r <= 0;
        s_axis_video_tready_r <= 0;
        m_axis_video_tdata_r <= 24'b0;
    end else begin
        if (s_axis_video_tvalid && m_axis_video_tready) begin //If handshaking enabled
            s_axis_video_tready_r <= 1;
            m_axis_video_tvalid_r <= 1;
            m_axis_video_tdata_r <= {gray, gray, gray}; //Concatenate the Grey values
            if (s_axis_video_tlast == 1) begin
                m_axis_video_tdata_r[23:16] <=  gray; //Don't send data over
                m_axis_video_last_r <= 1;
            end
        end else begin
            s_axis_video_tready_r <= 0;
            m_axis_video_tvalid_r <= 0;
            m_axis_video_tdata_r <= 24'b0;
        end
    end
end


endmodule