/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
/* This is a dummy I/O cell which acts as a template for user hardware.       */
/* It can accommodate 16 KiW (64 KiB) of I/O registers: currently two 32-bit  */
/* registers {yyy, zzz} are implemented, aliased throughout the address space.*/
/* The template is provided with 32 I/O lines which can be routed through to  */
/* the PCB I/O connectors on a bitwise basis in software.                     */
/* Four expansion interrupt signals are also provided.                        */
/* Currently uncommitted outputs are wired to constant values.                */
/*                                                          AMM/JDG Feb. 2025 */
/* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/

module User_Peripheral (input  wire        clk,           /* System clock     */
                        input  wire        reset,         /* System reset     */
                        input  wire        cs_i,          /* Device select    */
                        input  wire        read_i,        /* Bus read select  */
                        input  wire  [1:0] size_i,        /* Transfer size    */
                        input  wire        write_i,       /* Bus write select */
                        input  wire  [1:0] mode_i,        /* Privilege mode   */
                        input  wire [31:0] address_i,     /* Processor address*/
                        output wire        stall_o,       /* Bus wait output  */
                        output wire  [2:0] abort_o,       /* Bus error        */
                        input  wire [31:0] data_in,       /* Store data bus   */
                        output reg  [31:0] data_out,      /* Load data bus    */

                        input  wire [31:0] port_in,       /*Connections towards 
                                                          /*      pin_fn      */
                        output wire [31:0] port_out, 
                        output wire [31:0] port_direction,/* 1nput or 0utput  */
                        output wire  [7:0] LED_o,         /* Connections towards
                                                          /*   PCB LEDs       */
                                                           
                        output wire  [7:0] LCD_data_o,    /* Outputs to LCD   */
                        input  wire  [7:0] LCD_data_i,    /* Inputs from LCD  */
                        output wire        LCD_RW_o,      /* Read Not write   */
                        output wire        LCD_RS_o,      /* LCD Reg select   */
                        output wire        LCD_E_o,       /* LCD Enable       */
                        output wire        LCD_BL_o,      /* LCD Backlight,   */
                                                          /* Active high      */
                                                          
                        input  wire  [3:0] switch_i,      /* PCB switch states*/
                        output wire  [3:0] irq_o);        /*Interrupt requests*/
  
reg  [15:0] addr;  /* Note : if read needed the appropriate address bits must */
                   /* be kept for the output multiplexer in the -next- cycle. */

/* Buzzer */
typedef struct packed {
  logic [23:0] unused2;
  
  // Byte 1 (read only)
  logic terminal1;          // Bit 9
  logic terminal0;          // Bit 8

  // Byte 0 (read/write)
  logic unused1;            // Bit 7
  logic [5:0] note;         // Bits 1-6 (only uses 51/64)
  logic enable;             // Bit 0
} buzzer_reg_t;             // 32 bits total

buzzer_reg_t buzzer;

assign port_out[6] = buzzer.terminal0;
assign port_out[7] = buzzer.terminal1;

reg [16:0] half_period;                   // needs 17 bits to store up to 76k
reg [16:0] buzzer_counter;

assign stall_o =    cs_i   && 1'b0;       /* Unlikely to want to change these */
assign abort_o = {3{cs_i}} && 3'h0;     /* Aborts done at 'MMU' level already */

assign LED_o   = 8'h00;                        /* Wire off the LED outputs    */

always @ (posedge clk)                         /* Address bits hold           */
if (cs_i && read_i) addr <= address_i[7:0];    /* Delay for next cycle        */

always @ (*)                                   /* Read from selected register */
  case (addr[3:2])                /* Select (word) address here (later cycle) */
    2'h0: data_out = buzzer;
    default: data_out = 32'hxxxx_xxxx;
  endcase


// Note to frequency conversion table
// Calculated using excel, hardwired to reduce cycles as notes are fixed
always @ (*) 
  case (buzzer.note)
    6'd1: half_period = 17'd76445; // C4 (261.63Hz)
    6'd2: half_period = 17'd72155; // C#4 (277.18Hz)
    6'd3: half_period = 17'd68105; // D4 (293.66Hz)
    6'd4: half_period = 17'd64282; // D#4 (311.13Hz)
    6'd5: half_period = 17'd60675; // E4 (329.63Hz)
    6'd6: half_period = 17'd57269; // F4 (349.23Hz)
    6'd7: half_period = 17'd54055; // F#4 (369.99Hz)
    6'd8: half_period = 17'd51021; // G4 (392Hz)
    6'd9: half_period = 17'd48157; // G#4 (415.3Hz)
    6'd10: half_period = 17'd45455; // A4 (440Hz)
    6'd11: half_period = 17'd42903; // A#4 (466.16Hz)
    6'd12: half_period = 17'd40495; // B4 (493.88Hz)
    6'd13: half_period = 17'd38223; // C5 (523.25Hz)
    6'd14: half_period = 17'd36077; // C#5 (554.37Hz)
    6'd15: half_period = 17'd34052; // D5 (587.33Hz)
    6'd16: half_period = 17'd32141; // D#5 (622.25Hz)
    6'd17: half_period = 17'd30337; // E5 (659.26Hz)
    6'd18: half_period = 17'd28635; // F5 (698.46Hz)
    6'd19: half_period = 17'd27027; // F#5 (739.99Hz)
    6'd20: half_period = 17'd25511; // G5 (783.99Hz)
    6'd21: half_period = 17'd24079; // G#5 (830.61Hz)
    6'd22: half_period = 17'd22727; // A5 (880Hz)
    6'd23: half_period = 17'd21452; // A#5 (932.33Hz)
    6'd24: half_period = 17'd20248; // B5 (987.77Hz)
    6'd25: half_period = 17'd19111; // C6 (1046.5Hz)
    6'd26: half_period = 17'd18039; // C#6 (1108.73Hz)
    6'd27: half_period = 17'd17026; // D6 (1174.66Hz)
    6'd28: half_period = 17'd16071; // D#6 (1244.51Hz)
    6'd29: half_period = 17'd15169; // E6 (1318.51Hz)
    6'd30: half_period = 17'd14317; // F6 (1396.91Hz)
    6'd31: half_period = 17'd13514; // F#6 (1479.98Hz)
    6'd32: half_period = 17'd12755; // G6 (1567.98Hz)
    6'd33: half_period = 17'd12039; // G#6 (1661.22Hz)
    6'd34: half_period = 17'd11364; // A6 (1760Hz)
    6'd35: half_period = 17'd10726; // A#6 (1864.66Hz)
    6'd36: half_period = 17'd10124; // B6 (1975.53Hz)
    6'd37: half_period = 17'd9556; // C7 (2093Hz)
    6'd38: half_period = 17'd9019; // C#7 (2217.46Hz)
    6'd39: half_period = 17'd8513; // D7 (2349.32Hz)
    6'd40: half_period = 17'd8035; // D#7 (2489.02Hz)
    6'd41: half_period = 17'd7584; // E7 (2637.02Hz)
    6'd42: half_period = 17'd7159; // F7 (2793.83Hz)
    6'd43: half_period = 17'd6757; // F#7 (2959.96Hz)
    6'd44: half_period = 17'd6378; // G7 (3135.96Hz)
    6'd45: half_period = 17'd6020; // G#7 (3322.44Hz)
    6'd46: half_period = 17'd5682; // A7 (3520Hz)
    6'd47: half_period = 17'd5363; // A#7 (3729.31Hz)
    6'd48: half_period = 17'd5062; // B7 (3951.07Hz)
    6'd49: half_period = 17'd4778; // C8 (4186.01Hz)
    default: half_period = 17'd0;
  endcase


// Buzzer driving logic
always @ (posedge clk or posedge reset) 
begin
if (reset) 
  begin
  buzzer <= 32'h0000_0000;
  buzzer_counter <= 17'd0; 
  end
else if (cs_i && write_i)                     /* Write to selected register  */
  case (address_i[3:2])                       /* Select (word) address here  */
    2'h0: begin                               /* Mask writes to only bits 0-6 */
      buzzer.enable <= data_in[0];
      buzzer.note <= data_in[6:1]; 
    end
  endcase
else if (buzzer.enable && half_period != 0 )
  begin
  if (buzzer_counter >= half_period - 1) 
    begin
    buzzer_counter <= 17'd0;
    buzzer.terminal1 <= ~buzzer.terminal1;
    end
  else
    begin
    buzzer_counter <= buzzer_counter + 1;
    end
  end
else 
  begin
  buzzer_counter <= 17'd0;
  buzzer.terminal1 <= 1'b0;
  end
end


assign port_direction = 32'hFFFF_FF3F;        /* Output to bits 6 & 7 for buzzer */
assign irq_o          =  4'b0000;             /* Potential interrupt requests (tied off) */

// LCD Defaults
assign LCD_data_o = 1'b0; 
assign LCD_RW_o = 1'b1;        
assign LCD_RS_o = 1'b0;
assign LCD_E_o = 1'b0;
assign LCD_BL_o = 1'b0;

endmodule  // user_periph

/*============================================================================*/