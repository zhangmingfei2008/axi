// Copyright (c) 2014-2018 ETH Zurich, University of Bologna
//
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Fabian Schuiki <fschuiki@iis.ee.ethz.ch>
// Andreas Kurth  <akurth@iis.ee.ethz.ch>

package axi_pkg;

  typedef logic [1:0] burst_t;
  typedef logic [1:0] resp_t;
  typedef logic [3:0] cache_t;
  typedef logic [2:0] prot_t;
  typedef logic [3:0] qos_t;
  typedef logic [3:0] region_t;
  typedef logic [7:0] len_t;
  typedef logic [2:0] size_t;
  typedef logic [5:0] atop_t; // atomic operations
  typedef logic [3:0] nsaid_t; // non-secure address identifier

  localparam BURST_FIXED = 2'b00;
  localparam BURST_INCR  = 2'b01;
  localparam BURST_WRAP  = 2'b10;

  localparam RESP_OKAY   = 2'b00;
  localparam RESP_EXOKAY = 2'b01;
  localparam RESP_SLVERR = 2'b10;
  localparam RESP_DECERR = 2'b11;

  localparam CACHE_BUFFERABLE = 4'b0001;
  localparam CACHE_MODIFIABLE = 4'b0010;
  localparam CACHE_RD_ALLOC   = 4'b0100;
  localparam CACHE_WR_ALLOC   = 4'b1000;

  // Maximum number of bytes per burst, as specified by `size` (see Table A3-2).
  function shortint unsigned num_bytes(size_t size);
    return 1 << size;
  endfunction

  // An overly long address type lets us define functions that work generically for shorter
  // addresses.  We rely on the synthesizer to optimize the unused bits away.
  typedef logic [127:0] largest_addr_t;

  // Aligned address of burst (see A3-51).
  function largest_addr_t aligned_addr(largest_addr_t addr, size_t size);
    return (addr >> size) << size;
  endfunction

  // Address of beat (see A3-51).
  function automatic largest_addr_t
  beat_addr(largest_addr_t addr, size_t size, shortint unsigned i_beat);
    if (i_beat == 0) begin
      return addr;
    end else begin
      return aligned_addr(addr, size) + i_beat * num_bytes(size);
    end
  endfunction

  // Index of lowest beat in byte (see A3-51).
  function automatic shortint unsigned
  beat_lower_byte(largest_addr_t addr, size_t size, shortint unsigned strobe_width,
      shortint unsigned i_beat);
    largest_addr_t _addr = beat_addr(addr, size, i_beat);
    return _addr - (_addr / strobe_width) * strobe_width;
  endfunction

  // Index of highest beat in byte (see A3-51).
  function automatic shortint unsigned
  beat_upper_byte(largest_addr_t addr, size_t size, shortint unsigned strobe_width,
      shortint unsigned i_beat);
    if (i_beat == 0) begin
      return aligned_addr(addr, size) + (num_bytes(size) - 1) - (addr / strobe_width) * strobe_width;
    end else begin
      return beat_lower_byte(addr, size, strobe_width, i_beat) + num_bytes(size) - 1;
    end
  endfunction

  // ATOP[5:0]
  localparam ATOP_ATOMICSWAP  = 6'b110000;
  localparam ATOP_ATOMICCMP   = 6'b110001;
  // ATOP[5:4]
  localparam ATOP_NONE        = 2'b00;
  localparam ATOP_ATOMICSTORE = 2'b01;
  localparam ATOP_ATOMICLOAD  = 2'b10;
  // ATOP[3]
  localparam ATOP_LITTLE_END  = 1'b0;
  localparam ATOP_BIG_END     = 1'b1;
  // ATOP[2:0]
  localparam ATOP_ADD   = 3'b000;
  localparam ATOP_CLR   = 3'b001;
  localparam ATOP_EOR   = 3'b010;
  localparam ATOP_SET   = 3'b011;
  localparam ATOP_SMAX  = 3'b100;
  localparam ATOP_SMIN  = 3'b101;
  localparam ATOP_UMAX  = 3'b110;
  localparam ATOP_UMIN  = 3'b111;

endpackage
