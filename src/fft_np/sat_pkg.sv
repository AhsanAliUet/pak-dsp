// saturation package

package sat_pkg;

    `define SATURATE(NAME, N, M, SYMMETRIC)                                                       \
        function automatic [M-1:0] NAME(input [N-1:0] in);                                        \
            logic [M-1:0] out;                                                                    \
                                                                                                  \
            logic [M-1:0] max_pos;                                                                \
            logic [M-1:0] max_neg;                                                                \
            logic [M-1:0] max_neg_asym;                                                           \
            max_pos      = {1'b0, {(M-1){1'b1}}};                                                 \
            max_neg      = SYMMETRIC ? (~max_pos + 1) : {1'b1, {(M-1){1'b0}}};                    \
            max_neg_asym = {1'b1, {(M-1){1'b0}}};                                                 \
                                                                                                  \
            if (&in[N-1:N-(N-M+1)] || &(~in[N-1:N-(N-M+1)]))                                      \
            begin                                                                                 \
                out = (SYMMETRIC && signed'(in) ==                                                \
                    signed'({{(N-M){max_neg_asym[M-1]}}, max_neg_asym})) ? max_neg : in[M-1:0];   \
            end                                                                                   \
            else                                                                                  \
            begin                                                                                 \
                out = (in[N-1] ==1'b1) ? max_neg : max_pos;                                       \
            end                                                                                   \
                                                                                                  \
            return out;                                                                           \
        endfunction

    `SATURATE(sym_sat_9_8, 9, 8, 1)
    
endpackage
