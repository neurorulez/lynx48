//-------------------------------------------------------------------------------------------------
// Linkx48: Lynx 48K implementation for ZX-Uno board by Kyp
// MiSTer version by Yo_Me and rampa.
// https://github.com/Kyp069/lynx48
//-------------------------------------------------------------------------------------------------
// Z80 chip module implementation by Sorgelig
//-------------------------------------------------------------------------------------------------
module lynx48
//-------------------------------------------------------------------------------------------------
(
	input  wire      clock,
	output wire      led,
   input  wire      reset_osd,
	output wire      hSync,
	output wire      vSync,
	output wire      hBlank,
	output wire      vBlank,
	output wire[8:0] rgb,
   output wire      ce_pix,
	output wire[10:0] audio,
	input  wire     ear, 

	input  wire[1:0] ps2
);
//-------------------------------------------------------------------------------------------------



assign ce_pix = ce;

reg[2:0] ce;

always @(negedge clock) ce <= ce+1'd1;

wire ce8n = ~ce[0] & ~ce[1];
wire ce8p = ~ce[0] &  ce[1];

wire ce4n = ~ce[0] & ~ce[1] & ~ce[2];
wire ce4p = ~ce[0] & ~ce[1] &  ce[2];


//-------------------------------------------------------------------------------------------------


wire reset = reset_osd && reset_kbd;

wire[ 7:0] di;
wire[ 7:0] do;
wire[15:0] a;

cpu Cpu
(
	.reset  (reset  ),
	.clock  (clock  ),
	.cep    (ce4p   ),
	.cen    (ce4n   ),
	.int_n  (int_n  ),
	.mreq   (mreq   ),
	.iorq   (iorq   ),
	.wr     (wr     ),
	.di     (di     ),
	.do     (do     ),
	.a      (a      )
);

//-------------------------------------------------------------------------------------------------

wire[ 7:0] romDo;
wire[13:0] romA;

rom #(.AW(14), .FN("48K-1+2.hex")) Rom
(
	.clock  (clock  ),
	.ce     (ce4p   ),
	.do     (romDo  ),
	.a      (romA   )
);

wire[ 7:0] ramDi;
wire[ 7:0] ramDo;
wire[13:0] ramA;

spr #(.AW(14)) Ram
(
	.clock  (clock  ),
	.ce     (ce4p   ),
	.we     (ramWe  ),
	.di     (ramDi  ),
	.do     (ramDo  ),
	.a      (ramA   )
);

wire[ 7:0] vrbDo1;
wire[13:0] vrbA1;
wire[ 7:0] vrbDi2;
wire[ 7:0] vrbDo2;
wire[13:0] vrbA2;

dpr #(.AW(14)) Vrb
(
	.clock  (clock  ),
	.ce1    (ce8n   ),
	.do1    (vrbDo1 ),
	.a1     (vrbA1  ),
	.ce2    (ce4p   ),
	.we2    (vrbWe2 ),
	.di2    (vrbDi2 ),
	.do2    (vrbDo2 ),
	.a2     (vrbA2  )
);

wire[ 7:0] vggDo1;
wire[13:0] vggA1;
wire[ 7:0] vggDi2;
wire[ 7:0] vggDo2;
wire[13:0] vggA2;

dpr #(.AW(14)) Vgg
(
	.clock  (clock  ),
	.ce1    (ce8n   ),
	.do1    (vggDo1 ),
	.a1     (vggA1  ),
	.ce2    (ce4p   ),
	.we2    (vggWe2 ),
	.di2    (vggDi2 ),
	.do2    (vggDo2 ),
	.a2     (vggA2  )
);

//-------------------------------------------------------------------------------------------------

wire io7F = !(!iorq && !wr && a[6:0] == 7'h7F);

reg[7:0] reg7F;
always @(negedge reset, posedge clock) if(!reset) reg7F <= 1'd0; else if(ce4p) if(!io7F) reg7F <= do;
	  

//-------------------------------------------------------------------------------------------------

wire io80 = !(!iorq && !wr && a[7] && !a[6] && !a[2] && !a[1]);

reg[5:2] reg80;
reg motor;
reg speaker;

always @(negedge reset, posedge  clock) if(!reset) reg80 <= 8'h0c; else if(ce4p) if(!io80) 
   begin
	   reg80 <= do[5:2];
		motor <= do[1];
		speaker <= do[0];
	end

//-------------------------------------------------------------------------------------------------

wire io84 = !(!iorq && !wr && a[7] && !a[6] &&  a[2] && !a[1]);

reg[5:0] reg84;
always @(posedge clock) if(ce4p) if(!io84) reg84 <= do[5:0];

//-------------------------------------------------------------------------------------------------

wire altg = reg80[4];

wire[ 7:0] vmmDi;
wire[ 1:0] vmmB;
wire[12:0] vmmA;

video Video
(
	.clock  (clock  ),
	.ce     (ce8n   ),
	.altg   (altg   ),
	.stdn   (stdn   ),
	.sync   (sync   ),
	.hSync  (hSync  ),
	.vSync  (vSync  ),
	.hBlank (hBlank ),
	.vBlank (vBlank ),
	.rgb    (rgb    ),
	.int_n  (int_n  ),
	.d      (vmmDi  ),
	.b      (vmmB   ),
	.a      (vmmA   )
);


//-------------------------------------------------------------------------------------------------

wire[3:0] keybRow = a[11:8];
wire[7:0] keybDo;

keyboard Keyboard
(
	.clock  (clock  ),
	.ce     (ce8p   ),
	.ps2    (ps2    ),
	.reset  (reset_kbd),
	.boot   (boot   ),
	.row    (keybRow),
	.do     (keybDo )
);
//-------------------------------------------------------------------------------------------------

audio Audio
(
        .clock  (clock  ),
        .reset  (reset  ),
        .ear    (!ear   ),
        .dac    (reg84  ),
        .audio  (audio  )
);

//-------------------------------------------------------------------------------------------------



assign romA = { a[13], a[12:0] };

assign ramWe = !(!mreq && !wr && !reg7F[0]);
assign ramDi = do;
assign ramA = { a[14], a[12:0] };

assign vrbA1 = { vmmB[0], vmmA };
assign vrbWe2 = !(!mreq && !wr && reg7F[1] && reg80[5]);
assign vrbDi2 = do;
assign vrbA2 = { a[14], a[12:0] };

assign vggA1 = { vmmB[0], vmmA };
assign vggWe2 = !(!mreq && !wr && reg7F[2] && reg80[5]);
assign vggDi2 = do;
assign vggA2 = { a[14], a[12:0] };

assign vmmDi = vmmB[1] ? vggDo1 : vrbDo1;

//-------------------------------------------------------------------------------------------------


assign di
        = !mreq && !reg7F[4] && a[15:14] == 2'b00  ? romDo
        : !mreq && !reg7F[4] && a[15:13] == 3'b010 ? 8'hFF
        : !mreq && !reg7F[5] ? ramDo
        : !mreq &&  reg7F[6] && !reg80[2] ? vrbDo2
        : !mreq &&  reg7F[6] && !reg80[3] ? vggDo2
        : !iorq &&  a[7:0] == 8'h80 ? { keybDo[7:1], motor ? ear :keybDo[0]}
        : 8'hFF;


assign led=ear;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
