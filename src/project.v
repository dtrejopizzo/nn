//-----------------------------------------------------------------------------
// chip.v
// Ejemplo de chip con una "red neuronal" muy sencilla para TinyTapeout
// Autor: [Tu nombre o alias]
// Fecha: [Fecha actual]
//----------------------------------------------------------------------------- 
`default_nettype none

// MÓDULO TOP: Este es el punto de entrada de tu chip.
// Se asume que el chip cuenta con una señal de reloj (clk),
// 8 bits de entrada (sw, por ejemplo conectados a DIP switches)
// y 8 bits de salida (led, por ejemplo conectados a LEDs).
module chip (
    input  wire        clk,  // reloj principal
    input  wire [7:0]  sw,   // entrada: valor a ingresar (por DIP switches)
    output reg  [7:0]  led   // salida: resultado de la red neuronal (a LEDs)
);

  // Declaramos una señal intermedia para la salida combinacional
  // de la red neuronal.
  wire [7:0] nn_out;
  
  // Instanciamos el módulo de la red neuronal.
  neural_net nn_inst (
      .in_val (sw),
      .out_val(nn_out)
  );
  
  // Sincronizamos la salida al flanco de subida del reloj.
  // Esto ayuda a evitar glitches combinacionales y se ajusta a
  // las recomendaciones de diseño digital.
  always @(posedge clk) begin
      led <= nn_out;
  end

endmodule


//-----------------------------------------------------------------------------
// MÓDULO: neural_net
// Esta es una implementación sencilla de una "red neuronal" con dos
// neuronas en capa oculta y una neurona de salida. La red se implementa
// de forma combinacional; las saturaciones (mínimo con 255) se usan para
// emular la no-linealidad (función de activación).
//-----------------------------------------------------------------------------
module neural_net (
    input  wire [7:0] in_val,   // valor de entrada (8 bits)
    output wire [7:0] out_val   // valor de salida (8 bits)
);

  // -----------------------------
  // Capa Oculta - Neurona 1
  // Calcula: h1 = (2 * in_val + 10), con saturación a 255.
  // Usamos (in_val << 1) en lugar de (in_val * 2).
  // -----------------------------
  wire [15:0] h1_raw;
  assign h1_raw = (in_val << 1) + 10;  // 2 * in_val + 10
  
  // Si h1_raw > 255, h1 = 255; sino se usa el valor calculado.
  wire [7:0] h1;
  assign h1 = (h1_raw > 16'd255) ? 8'd255 : h1_raw[7:0];

  // -----------------------------
  // Capa Oculta - Neurona 2
  // Calcula: h2 = (in_val + 20), con saturación a 255.
  // -----------------------------
  wire [15:0] h2_raw;
  assign h2_raw = in_val + 20;
  
  wire [7:0] h2;
  assign h2 = (h2_raw > 16'd255) ? 8'd255 : h2_raw[7:0];

  // -----------------------------
  // Capa de Salida - Neurona de Salida
  // Calcula: out_val = (h1 + 2*h2 + 5), con saturación a 255.
  // Para 2 * h2 usamos (h2 << 1).
  // -----------------------------
  wire [15:0] out_raw;
  assign out_raw = h1 + (h2 << 1) + 5;
  
  assign out_val = (out_raw > 16'd255) ? 8'd255 : out_raw[7:0];

endmodule

`default_nettype wire
